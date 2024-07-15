use ec_groups::ECOperations;
pub use pairing::{PPrecompute, Groth16MillerG1, Groth16MillerG2, Groth16PreCompute, Groth16Circuit};
use bn254_u256::{
    Fq, Fq2, Fq12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve, CubicScale,
    pairing::{
        schzip_miller_runner::Miller_Bn254_U256,
        utils::{SZCommitment, SZPreCompute, SZAccumulator, LnArrays, ICArrayInput},
    }
};
use bn_ate_loop::{ate_miller_loop};
use ec_groups::{LineFn, StepLinesGet, LinesArrayGet};
use pairing::PairingUtils;


pub type InputConstraintPoints = Array<PtG1>;
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
    setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, Fq12>,
    schzip: SZCommitment,
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
    let mut q_acc = SZAccumulator { g2: q, schzip: (0, 0_u256.into()) };

    ate_miller_loop(ref curve, precomp, q_acc)
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
    schzip_remainders: Array<u256>,
    schzip_qrlc: Array<u256>,
) {
    let schzip = SZCommitment { remainders: schzip_remainders, q_rlc_sum: schzip_qrlc };

    // miller loop result
    schzip_miller(
        ref curve, pi_a, pi_b, pi_c, inputs, residue_witness, residue_witness_inv, setup, schzip
    );
}