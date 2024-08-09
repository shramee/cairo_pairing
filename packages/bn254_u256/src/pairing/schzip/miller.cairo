use fq_types::FieldOps;
use ec_groups::ECOperations;
pub use pairing::{PPrecompute, Groth16MillerG1, Groth16MillerG2, Groth16PreCompute, Groth16Circuit};
use bn254_u256::print::{FqDisplay, Fq12Display, G1Display, G2Display};
use bn254_u256::{
    fq, Fq, Fq2, FqD12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve,
    pairing::{
        schzip::miller_runner::Miller_Bn254_U256,
        utils::{
            SZCommitment, SZMillerRunner, SZCommitmentAccumulator, SZAccumulator, LnArrays,
            ICArrayInput
        },
    },
    {fq12_frobenius_map, FrobFq12, direct_to_tower_fq12, tower_to_direct_fq12}, // Frobenius
    Bn254SchwartzZippelSteps,
};
use bn_ate_loop::{ate_miller_loop};
use pairing::{LineFn, StepLinesGet, LinesArrayGet};
use pairing::{PairingUtils, CubicScale};
use core::hash::HashStateTrait;
use core::poseidon::{PoseidonImpl, HashState};
use schwartz_zippel::{SchZipSteps, Residue};


pub type InputConstraintPoints = Array<PtG1>;
type LnFn = LineFn<Fq>;

// Does the verification
fn schzip_miller<
    TSchZip,
    +SchZipSteps<Bn254U256Curve, TSchZip, SZCommitmentAccumulator, Fq, FqD12>,
    +Drop<TSchZip>
>(
    ref curve: Bn254U256Curve,
    pi_a: PtG1,
    pi_b: PtG2,
    pi_c: PtG1,
    inputs: Array<u256>,
    residue_witness: FqD12,
    residue_witness_inv: FqD12,
    cubic_scale: CubicScale,
    setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, FqD12>,
    schzip: TSchZip,
    schzip_acc: SZCommitmentAccumulator,
) -> SZAccumulator { //
    // Compute k from ic and public_inputs
    let Groth16Circuit { alpha_beta, gamma, gamma_neg, delta, delta_neg, lines, ic, } = setup;

    let k: PtG1 = curve.process_inputs_and_ic(ic, inputs);

    // build precompute
    let p = Groth16MillerG1 { pi_a, pi_c, k, };
    let q = Groth16MillerG2 { pi_b, gamma, delta };
    let neg_q = Groth16MillerG2 { pi_b: curve.pt_neg(pi_b), gamma: gamma_neg, delta: delta_neg };
    let ppc = Groth16MillerG1 {
        pi_a: curve.p_precompute(pi_a), pi_c: curve.p_precompute(pi_c), k: curve.p_precompute(k),
    };
    let g16 = Groth16PreCompute { p, q, ppc, neg_q, lines, residue_witness, residue_witness_inv, };

    // miller accumulator
    let mut acc = SZAccumulator {
        f: residue_witness_inv, g2: q, line_index: 0, schzip: schzip_acc
    };

    let mut runner = SZMillerRunner { g16: @g16, schzip: @schzip, acc };

    ate_miller_loop(ref curve, ref runner);

    let mut q_acc = runner.acc;

    core::internal::revoke_ap_tracking();
    let frobenius_maps = fq12_frobenius_map();
    let witness_fq12 = direct_to_tower_fq12(ref curve, residue_witness);
    let witness_inv_fq12 = direct_to_tower_fq12(ref curve, residue_witness_inv);
    let r_pow_q = curve.frob1(witness_inv_fq12, @frobenius_maps);
    let r_inv_q2 = curve.frob2(witness_fq12, @frobenius_maps);
    let r_pow_q3 = curve.frob3(witness_inv_fq12, @frobenius_maps);

    curve
        .sz_final(
            runner.schzip,
            ref q_acc.schzip,
            ref q_acc.f,
            alpha_beta,
            tower_to_direct_fq12(ref curve, r_pow_q),
            tower_to_direct_fq12(ref curve, r_inv_q2),
            tower_to_direct_fq12(ref curve, r_pow_q3),
            cubic_scale
        );
    q_acc
}

fn hash_fq2(ref hasher: HashState, a: Fq, b: Fq) {
    hasher = hasher.update(a.c0.low.into());
    hasher = hasher.update(a.c0.high.into());
    hasher = hasher.update(b.c0.low.into());
    hasher = hasher.update(b.c0.high.into());
}

// Prepares SZ commitment
// ----------------------
// Remainders Fiat Shamir is used for RLC (Random Linear Combination).
// The commitment for Schwartz Zippel lemma includes all remainders and an RLC of all quotients
// (QRLC).
// The verifier accumulates all the remainders and RHS from miller loop with same RLC as the QRLC.
// Quotient terms are accumulated in QRLC for all individual equations, and cannot change the terms
// of remainders in the final clubbed equation.
// The terms of remainders are between x^0 to x^11, and QRLC terms are all x^12 and up.
// This is because the terms in the QRLC are all multiplied by a polynomial of degree 12, x^12 +
// 18x^6 + 82 So  Any changes in the remainders will change the RLC and equation will not be
// satisfiable with any QRLC.
// Fiat Shamir for the final Schwartz Zippel includes all remainders and QRLC for soundness.
pub fn prepare_sz_commitment(
    ref curve: Bn254U256Curve, remainders: Array<FqD12>, qrlc: Array<Fq>,
) -> (SZCommitment, SZCommitmentAccumulator) {
    core::internal::revoke_ap_tracking();
    let mut rem_coeff_i = 0;
    let mut hasher = PoseidonImpl::new();
    let rem_coeffs_count = remainders.len();
    let rem_snap = @remainders;
    while rem_coeff_i != rem_coeffs_count {
        let rem: FqD12 = *rem_snap[rem_coeff_i];
        let ((r0, r1, r2, r3), (r4, r5, r6, r7), (r8, r9, r10, r11)) = rem;

        hash_fq2(ref hasher, r0, r1);
        hash_fq2(ref hasher, r2, r3);
        hash_fq2(ref hasher, r4, r5);
        hash_fq2(ref hasher, r6, r7);
        hash_fq2(ref hasher, r8, r9);
        hash_fq2(ref hasher, r10, r11);
        rem_coeff_i += 1;
    };
    let remainders_fiat_shamir_felt = hasher.finalize();
    let remainders_fiat_shamir: u256 = remainders_fiat_shamir_felt.into();
    core::internal::revoke_ap_tracking();

    let mut qrlc_coeff_i = 0;
    let qrlc_count = qrlc.len();
    let qrlc_snap = @qrlc;
    // continue with the rest of the coefficients from quotient RLC
    while qrlc_coeff_i != qrlc_count {
        let c = *(qrlc_snap[qrlc_coeff_i]);
        hasher = hasher.update(c.c0.low.into());
        hasher = hasher.update(c.c0.high.into());
        qrlc_coeff_i += 1;
    };
    let fiat_shamir: u256 = hasher.finalize().into();
    let fiat_shamir_powers = fs_pow(ref curve, fq(fiat_shamir), 76);

    // x^12 - 18x^6 + 82
    let _18x6 = curve.mul(fq(18), *fiat_shamir_powers[6]); // 18x^6
    let _x12_18x6 = curve.sub(*fiat_shamir_powers[12], _18x6); // x^12 - 18x^6
    let p12_x = curve.add(_x12_18x6, fq(82));

    (
        SZCommitment {
            remainders,
            fiat_shamir_powers,
            rlc_fiat_shamir: fs_pow(ref curve, fq(remainders_fiat_shamir), 68),
            p12_x,
            qrlc
        },
        SZCommitmentAccumulator { index: 0, rhs_lhs: 0_u256.into(), rem_cache: 0_u256.into() }
    )
}

pub fn fs_pow(ref curve: Bn254U256Curve, x: Fq, powers: u32) -> Array<Fq> {
    let mut arr: Array<Fq> = array![1_u256.into(), x];
    let mut i = 1;
    let powers = powers / 2;
    while i != powers {
        let even_power = curve.sqr(*arr[i]);
        arr.append(even_power); // even i * 2 power
        arr.append(curve.mul(even_power, x)); // odd i * 2 + 1 power
        i += 1;
    };
    arr
}
// Does the verification
pub fn schzip_verify(
    ref curve: Bn254U256Curve,
    pi_a: PtG1,
    pi_b: PtG2,
    pi_c: PtG1,
    inputs: Array<u256>,
    residue_witness: FqD12,
    residue_witness_inv: FqD12,
    cubic_scale: CubicScale,
    setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, FqD12>,
    schzip_remainders: Array<FqD12>,
    schzip_qrlc: Array<Fq>,
) -> bool {
    // let p = fs_pow(ref curve, fq(2), 6);
    // println!("{} {} {} {} {} {}", p[0], p[1], p[2], p[3], p[4], p[5]);
    let (sz, sz_acc) = prepare_sz_commitment(ref curve, schzip_remainders, schzip_qrlc);
    let sz_snap = @sz;

    // miller loop result
    let mut acc = schzip_miller(
        ref curve,
        pi_a,
        pi_b,
        pi_c,
        inputs,
        residue_witness,
        residue_witness_inv,
        cubic_scale,
        setup,
        sz,
        sz_acc
    );

    curve.sz_verify(sz_snap, ref acc.schzip, acc.f, residue_witness, residue_witness_inv,)
}
