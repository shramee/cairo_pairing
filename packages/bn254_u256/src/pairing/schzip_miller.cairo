use ec_groups::ECOperations;
use bn_ate_loop::{PPrecompute, Groth16MillerG1, Groth16MillerG2, Groth16PreCompute, Groth16Circuit};
use bn254_u256::{Fq, Fq2, Fq12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve, pairing, CubicScale};
use bn254_u256::pairing::schzip_miller_runner::Miller_Bn254_U256;
use bn254_u256::pairing::utils::{SZCommitment, SZPreCompute, SZAccumulator, LnArray};
use bn254_u256::pairing::utils::{ICArrayInput, p_precompute};
use bn_ate_loop::{MillerRunner, ate_miller_loop};
use ec_groups::{LineFn, StepLinesGet, LinesArrayGet};


pub type InputConstraintPoints = Array<PtG1>;

type SchzipAccumulator = felt252;
type LnFn = LineFn<Fq>;

// Does the verification
fn schzip_miller(
    ref curve: Bn254U256Curve,
    pi_a: PtG1,
    pi_b: PtG2,
    pi_c: PtG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    setup: Groth16Circuit<PtG1, PtG2, LnArray, InputConstraintPoints, Fq12>,
    schzip_remainders: Array<u256>,
    schzip_qrlc: Array<u256>,
) -> (Fq12, Fq12, SZPreCompute<LnArray>, SZAccumulator) { //
    // Compute k from ic and public_inputs
    let Groth16Circuit { alpha_beta, gamma, gamma_neg, delta, delta_neg, lines, ic, } = setup;

    let k: PtG1 = curve.process_inputs_and_ic(ic, inputs);

    let pi_a = curve.pt_neg(pi_a);

    // build precompute
    let p = Groth16MillerG1 { pi_a, pi_c, k, };
    let q = Groth16MillerG2 { pi_b, gamma, delta };
    let neg_q = Groth16MillerG2 { pi_b: curve.pt_neg(pi_b), gamma: gamma_neg, delta: delta_neg };
    let ppc = Groth16MillerG1 {
        pi_a: p_precompute(ref curve, pi_a),
        pi_c: p_precompute(ref curve, pi_c),
        k: p_precompute(ref curve, k),
    };
    let g16_precompute = Groth16PreCompute {
        p, q, ppc, neg_q, lines, residue_witness, residue_witness_inv,
    };

    let precomp = SZPreCompute {
        g16_precompute,
        schzip: SZCommitment { remainders: schzip_remainders, q_rlc_sum: schzip_qrlc },
    };

    // miller accumulator
    let mut q_acc = SZAccumulator { g2: q, schzip_i: 0, lhs_rhs: 0_u256.into() };

    ate_miller_loop(ref curve, precomp, ref q_acc);
}

// Does the verification
pub fn schzip_base_verify(
    ref curve: Bn254U256Curve,
    pi_a: PtG1,
    pi_b: PtG2,
    pi_c: PtG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    cubic_scale: CubicScale,
    setup: Groth16Circuit<PtG1, PtG2, LnArray, InputConstraintPoints, Fq12>,
    schzip_remainders: Array<u256>,
    schzip_qrlc: Array<u256>,
) {
    // residue_witness_inv as starter to incorporate  6 * x + 2 in the miller loop

    // miller loop result
    schzip_miller(
        ref curve,
        pi_a,
        pi_b,
        pi_c,
        inputs,
        residue_witness,
        residue_witness_inv,
        setup,
        schzip_remainders,
        schzip_qrlc
    );
}
