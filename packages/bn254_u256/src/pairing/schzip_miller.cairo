use fq_types::FieldOps;
use ec_groups::ECOperations;
pub use pairing::{PPrecompute, Groth16MillerG1, Groth16MillerG2, Groth16PreCompute, Groth16Circuit};
use bn254_u256::{
    Fq, Fq2, Fq12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve,
    pairing::{
        schzip_miller_runner::Miller_Bn254_U256,
        utils::{
            SZCommitment, SZPreCompute, SZCommitmentAccumulator, SZAccumulator, LnArrays,
            ICArrayInput
        },
    },
    Bn254SchwartzZippelSteps,
};
use bn_ate_loop::{ate_miller_loop};
use pairing::{LineFn, StepLinesGet, LinesArrayGet};
use pairing::{PairingUtils, CubicScale};
use core::hash::HashStateTrait;
use schwartz_zippel::SchZipSteps;


pub type InputConstraintPoints = Array<PtG1>;
type LnFn = LineFn<Fq>;

// Does the verification
fn schzip_miller<
    TSchZip, +SchZipSteps<Bn254U256Curve, TSchZip, SZCommitmentAccumulator, Fq>, +Drop<TSchZip>
>(
    ref curve: Bn254U256Curve,
    pi_a: PtG1,
    pi_b: PtG2,
    pi_c: PtG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, Fq12>,
    schzip: TSchZip,
) -> SZAccumulator { //
    // Compute k from ic and public_inputs
    let Groth16Circuit { alpha_beta: _, gamma, gamma_neg, delta, delta_neg, lines, ic, } = setup;

    let k: PtG1 = curve.process_inputs_and_ic(ic, inputs);

    let pi_a = curve.pt_neg(pi_a);

    // build precompute
    let p = Groth16MillerG1 { pi_a, pi_c, k, };
    let q = Groth16MillerG2 { pi_b, gamma, delta };
    let neg_q = Groth16MillerG2 { pi_b: curve.pt_neg(pi_b), gamma: gamma_neg, delta: delta_neg };
    let ppc = Groth16MillerG1 {
        pi_a: curve.p_precompute(pi_a), pi_c: curve.p_precompute(pi_c), k: curve.p_precompute(k),
    };
    let g16 = Groth16PreCompute { p, q, ppc, neg_q, lines, residue_witness, residue_witness_inv, };

    let precomp = SZPreCompute { g16, schzip, };

    // miller accumulator
    let mut q_acc = SZAccumulator {
        f: residue_witness_inv, g2: q, line_index: 0, schzip: (0, 0_u256.into())
    };

    ate_miller_loop(ref curve, precomp, q_acc)
}

// Prepares SZ commitment
// ----------------------
// Remainders Fiat Shamir is used for RLC (Random Linear Combination).
// The commitment for Schwartz Zippel lemma includes all remainders and an RLC of all quotients (QRLC).
// The verifier accumulates all the remainders and RHS from miller loop with same RLC as the QRLC.
// Quotient terms are accumulated in QRLC for all individual equations, and cannot change the terms
// of remainders in the final clubbed equation.
// The terms of remainders are between x^0 to x^11, and QRLC terms are all x^12 and up.
// This is because the terms in the QRLC are all multiplied by a polynomial of degree 12, x^12 + 18x^6 + 82
// So  Any changes in the remainders will change the RLC and equation will not be satisfiable with any QRLC.
// Fiat Shamir for the final Schwartz Zippel includes all remainders and QRLC for soundness.
pub fn prepare_sz_commitment(
    ref curve: Bn254U256Curve, remainders: Array<Fq>, qrlc: Array<Fq>,
) -> SZCommitment {
    let mut rem_coeff_i = 0;
    let mut hasher = core::poseidon::PoseidonImpl::new();
    let rem_coeffs_count = remainders.len();
    let rem_snap = @remainders;
    while rem_coeff_i != rem_coeffs_count {
        let c = *(rem_snap[rem_coeff_i]);
        hasher = hasher.update(c.c0.low.into());
        hasher = hasher.update(c.c0.high.into());
        rem_coeff_i += 1;
    };
    let remainders_fiat_shamir: u256 = hasher.finalize().into();

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

    // @TODO
    let p12_x = 1_u256.into();

    SZCommitment {
        remainders,
        fiat_shamir_powers: fs_pow(ref curve, fiat_shamir, 40),
        rem_fiat_shamir_powers: fs_pow(ref curve, remainders_fiat_shamir, 68),
        p12_x,
        qrlc
    }
}

pub fn fs_pow(ref curve: Bn254U256Curve, x: u256, powers: u32) -> Array<Fq> {
    let x_fq: Fq = x.into();
    let mut arr: Array<Fq> = array![x_fq];
    let mut i = 0;
    let powers = powers / 2 + 1;
    while i != powers {
        let even_power = curve.sqr(*arr[i]);
        arr.append(even_power); // even i * 2 power
        arr.append(curve.mul(even_power, x_fq)); // odd i * 2 + 1 power
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
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    cubic_scale: CubicScale,
    setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, Fq12>,
    schzip_remainders: Array<Fq>,
    schzip_qrlc: Array<Fq>,
) {
    let schzip = prepare_sz_commitment(ref curve, schzip_remainders, schzip_qrlc);

    // miller loop result
    schzip_miller(
        ref curve, pi_a, pi_b, pi_c, inputs, residue_witness, residue_witness_inv, setup, schzip
    );
}
