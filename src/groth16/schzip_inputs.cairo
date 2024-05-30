use bn::fields::fq_12::Fq12FrobeniusTrait;
use bn::traits::FieldUtils;
use bn::fields::fq_sparse::FqSparseTrait;
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, Fq6, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
use bn::curve::{pairing, get_field_nz};
use bn::traits::{MillerPrecompute, MillerSteps};
use pairing::optimal_ate::{ate_miller_loop_steps};
use pairing::optimal_ate_utils::{p_precompute, line_fn_at_p, LineFn};
use pairing::optimal_ate_utils::{step_double, step_dbl_add, correction_step};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{ICProcess, G16CircuitSetup, Groth16PrecomputedStep};
use bn::groth16::utils::{StepLinesGet, StepLinesTrait, fq12_034_034_034};
use bn::groth16::utils::{
    Groth16MillerG1, Groth16MillerG2, PPrecomputeX3, F034, F01234, LineResult,
};

#[derive(Copy, Drop)]
struct Groth16PreCompute<T> {
    p: Groth16MillerG1,
    q: Groth16MillerG2,
    ppc: PPrecomputeX3,
    neg_q: Groth16MillerG2,
    lines: T,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    field_nz: NonZero<u256>,
}

impl Groth16MillerSteps<
    T, +StepLinesGet<T>
> of MillerSteps<Groth16PreCompute<T>, Groth16MillerG2, Fq12> {
    #[inline(always)]
    fn sqr_target(self: @Groth16PreCompute<T>, i: u32, ref acc: Groth16MillerG2, ref f: Fq12) {
        f = f.sqr();
    }

    fn miller_first_second(
        self: @Groth16PreCompute<T>, i1: u32, i2: u32, ref acc: Groth16MillerG2
    ) -> Fq12 { //
        let mut f = (*self.residue_witness_inv).sqr();
        // step 0, run step double
        self.miller_bit_o(i1, ref acc, ref f);

        f = f.sqr();

        // step -1, the next negative one step
        self.miller_bit_n(i2, ref acc, ref f);
        f
    }

    // 0 bit
    fn miller_bit_o(self: @Groth16PreCompute<T>, i: u32, ref acc: Groth16MillerG2, ref f: Fq12) {
        let (pi_a_ppc, _, _) = self.ppc;
        let field_nz = *self.field_nz;
        let l1 = step_double(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, field_nz);
        let (l2, l3) = self.lines.with_fxd_pt_line(self.ppc, ref acc, i, field_nz);
        fq12_034_034_034(ref f, l1, l2, l3, *self.field_nz);
    }

    // 1 bit
    fn miller_bit_p(self: @Groth16PreCompute<T>, i: u32, ref acc: Groth16MillerG2, ref f: Fq12) {
        let Groth16MillerG2 { pi_b, delta: _, gamma: _, line_count: _ } = self.q;
        let field_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let (l1_1, l1_2) = step_dbl_add(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, field_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc, i, field_nz);
        let (l2_1, l2_2) = l2;
        let (l3_1, l3_2) = l3;

        // 2x fq12 * s012345 * s034 ir cheaper than fq12 * (s012345 * s012345) * (s034 * s034)
        fq12_034_034_034(ref f, l1_1, l2_1, l3_1, *self.field_nz);
        fq12_034_034_034(ref f, l1_2, l2_2, l3_2, *self.field_nz);
        f = f.mul(*self.residue_witness_inv);
    }

    // -1 bit
    fn miller_bit_n(self: @Groth16PreCompute<T>, i: u32, ref acc: Groth16MillerG2, ref f: Fq12) {
        // use neg q
        let Groth16MillerG2 { pi_b, delta: _, gamma: _, line_count: _ } = self.neg_q;
        let field_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let (l1_1, l1_2) = step_dbl_add(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, field_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc, i, field_nz);
        let (l2_1, l2_2) = l2;
        let (l3_1, l3_2) = l3;
        fq12_034_034_034(ref f, l1_1, l2_1, l3_1, *self.field_nz);
        fq12_034_034_034(ref f, l1_2, l2_2, l3_2, *self.field_nz);
        f = f.mul(*self.residue_witness);
    }

    // last step
    fn miller_last(self: @Groth16PreCompute<T>, ref acc: Groth16MillerG2, ref f: Fq12) {
        // let Groth16PreCompute { p, q, ppc: _, neg_q: _, lines: _, field_nz, } = self;
        let field_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let (l1_1, l1_2) = correction_step(
            ref acc.pi_b, pi_a_ppc, *self.p.pi_a, *self.q.pi_b, field_nz
        );
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc, 'last', field_nz);
        let (l2_1, l2_2) = l2;
        let (l3_1, l3_2) = l3;

        fq12_034_034_034(ref f, l1_1, l2_1, l3_1, *self.field_nz);
        fq12_034_034_034(ref f, l1_2, l2_2, l3_2, *self.field_nz);
    }
}

// Does the verification
fn verify_miller<TLines, +StepLinesGet<TLines>, +Drop<TLines>>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    setup: G16CircuitSetup<TLines>,
) -> Fq12 { //
    // Compute k from ic and public_inputs
    let G16CircuitSetup { alpha_beta, gamma, gamma_neg, delta, delta_neg, lines, ic, } = setup;

    let (ic0, ics) = ic;
    let k = (ics, inputs).process_inputs_and_ic(ic0);

    // let pi_a = pi_a.neg();

    // build precompute
    let field_nz = get_field_nz();
    let line_count = 0;
    let q = Groth16MillerG2 { pi_b, gamma, delta, line_count };
    let neg_q = Groth16MillerG2 {
        pi_b: pi_b.neg(), gamma: gamma_neg, delta: delta_neg, line_count
    };
    let ppc = (
        p_precompute(pi_a, field_nz), p_precompute(pi_c, field_nz), p_precompute(k, field_nz)
    );
    let precomp = Groth16PreCompute {
        p: Groth16MillerG1 { pi_a: pi_a, pi_c, k, },
        q,
        ppc,
        neg_q,
        lines,
        residue_witness,
        residue_witness_inv,
        field_nz,
    };

    // q points accumulator
    let mut acc = q;
    // run miller steps
    let miller_loop_result = ate_miller_loop_steps(precomp, ref acc);

    // multiply precomputed alphabeta_miller with the pairings
    miller_loop_result * alpha_beta
}

// @TODO
// Fix Groth16 verify function for negative G2 and not neg pi_a
// Does the verification
fn verify<TLines, +StepLinesGet<TLines>, +Drop<TLines>>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    cubic_scale: Fq6,
    setup: G16CircuitSetup<TLines>,
) -> bool {
    let one = Fq12Utils::one();
    assert(residue_witness_inv * residue_witness == one, 'incorrect residue witness');
    // residue_witness_inv as starter to incorporate  6 * x + 2 in the miller loop

    // miller loop result
    let Fq12 { c0, c1 } = verify_miller(
        pi_a, pi_b, pi_c, inputs, residue_witness, residue_witness_inv, setup
    );

    // add cubic scale
    let result = Fq12 { c0: c0 * cubic_scale, c1: c1 * cubic_scale };

    // Finishing up `q - q**2 + q**3` of `6 * x + 2 + q - q**2 + q**3`
    // result^(q + q**3) * (1/residue)^(q**2)
    let result = result
        * residue_witness_inv.frob1()
        * residue_witness.frob2()
        * residue_witness_inv.frob3();

    // final exponentiation
    // let result = miller_loop_result.final_exponentiation();

    // return result == 1
    result == one
}
