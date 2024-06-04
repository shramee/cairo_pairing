use bn::groth16::utils_line::LineResult01234Trait;
use bn::fields::fq_12::Fq12FrobeniusTrait;
use bn::traits::FieldUtils;
use bn::fields::{FS034, FS01234, fq_sparse::FqSparseTrait};
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, Fq6, print::{FqDisplay, Fq12Display, F034Display, F01234Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
use bn::curve::{pairing, get_field_nz};
use bn::traits::{MillerPrecompute, MillerSteps};
use pairing::optimal_ate::{ate_miller_loop_steps};
use pairing::optimal_ate_utils::{p_precompute, line_fn_at_p, LineFn};
use pairing::optimal_ate_utils::{step_double, step_dbl_add, correction_step};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{ICProcess, G16CircuitSetup, Groth16PrecomputedStep};
use bn::groth16::utils::{StepLinesGet, StepLinesTrait, fq12_034_034_034};
use bn::groth16::utils::{Groth16MillerG1, Groth16MillerG2, PPrecomputeX3, LineResult,};

type F034X2 = (FS034, FS034);
type Lines = (FS034, FS034, FS034);
type LinesDbl = (F034X2, F034X2, F034X2);
type NZ256 = NonZero<u256>;

#[derive(Copy, Drop)]
pub struct SchZipAccumulator {
    g2: Groth16MillerG2,
    coeff_i: u32,
}

#[derive(Copy, Drop)]
pub struct Groth16PreCompute<TLines, TSchZip> {
    p: Groth16MillerG1,
    q: Groth16MillerG2,
    ppc: PPrecomputeX3,
    neg_q: Groth16MillerG2,
    lines: TLines,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    schzip: TSchZip,
    field_nz: NZ256,
}

// All changes to f: Fq12 are made via the SchZipProcess implementation
pub trait SchZipProcess<T> {
    fn sz_init(self: @T, ref f: Fq12, f_nz: NZ256);
    fn sz_sqr(self: @T, ref f: Fq12, i: u32, f_nz: NZ256);
    fn sz_zero_bit(self: @T, ref f: Fq12, i: u32, lines: Lines, f_nz: NZ256);
    fn sz_non_zero_bit(self: @T, ref f: Fq12, i: u32, lines: LinesDbl, witness: Fq12, f_nz: NZ256);
    fn sz_last_step(self: @T, ref f: Fq12, i: u32, lines: LinesDbl, f_nz: NZ256);
}

#[derive(Drop)]
pub struct SchZipInputPoly {}

pub impl SchZipInputPolyImpl of SchZipProcess<SchZipInputPoly> {
    #[inline(always)]
    fn sz_init(self: @SchZipInputPoly, ref f: Fq12, f_nz: NZ256) { //
    }
    #[inline(always)]
    fn sz_sqr(self: @SchZipInputPoly, ref f: Fq12, i: u32, f_nz: NZ256) { //
    // Handled in individual bit operation functions
    // f = f.sqr();
    }
    #[inline(always)]
    fn sz_zero_bit(self: @SchZipInputPoly, ref f: Fq12, i: u32, lines: Lines, f_nz: NZ256) {
        f = f.sqr();
        let (l1, l2, l3) = lines;
        let l1_l2 = l1.mul_034_by_034(l2, f_nz);
        f = f.mul(l1_l2.mul_01234_034(l3, f_nz));
    // println!("sz_zero_bit(\n{}\n{}\n{}\n)", f, l1_l2, l3);
    }
    #[inline(always)]
    fn sz_non_zero_bit(
        self: @SchZipInputPoly, ref f: Fq12, i: u32, lines: LinesDbl, witness: Fq12, f_nz: NZ256
    ) {
        f = f.sqr();
        let (l1, l2, l3) = lines;
        let l1 = l1.as_01234(f_nz);
        let l2 = l2.as_01234(f_nz);
        let l3 = l3.as_01234(f_nz);
        f = f.mul_01234(l1, f_nz);
        f = f.mul_01234(l2, f_nz);
        f = f.mul_01234(l3, f_nz);
        f = f.mul(witness);
    // println!("sz_non_zero_bit(\n{}\n{}\n{}\n{}\n{}\n)", f, l1, l2, l3, witness);
    }
    #[inline(always)]
    fn sz_last_step(self: @SchZipInputPoly, ref f: Fq12, i: u32, lines: LinesDbl, f_nz: NZ256) {
        let (l1, l2, l3) = lines;
        let l1 = l1.as_01234(f_nz);
        let l2 = l2.as_01234(f_nz);
        let l3 = l3.as_01234(f_nz);
        f = f.mul_01234(l1, f_nz);
        f = f.mul_01234(l2, f_nz);
        f = f.mul_01234(l3, f_nz);
    // println!("sz_last_step(\n{}\n{}\n{}\n{}\n)", f, l1, l2, l3);
    }
}

// This loop doesn't make any updates to f: Fq12
// All updates are made via the SchZipProcess implementation
pub impl Groth16MillerSteps<
    TLines, TSchZip, +StepLinesGet<TLines>, +SchZipProcess<TSchZip>
> of MillerSteps<Groth16PreCompute<TLines, TSchZip>, SchZipAccumulator, Fq12> {
    #[inline(always)]
    fn sqr_target(
        self: @Groth16PreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        self.schzip.sz_sqr(ref f, i, *self.field_nz);
    }

    fn miller_first_second(
        self: @Groth16PreCompute<TLines, TSchZip>, i1: u32, i2: u32, ref acc: SchZipAccumulator
    ) -> Fq12 { //
        let mut f = *self.residue_witness_inv;
        self.schzip.sz_init(ref f, *self.field_nz);

        self.sqr_target(i1, ref acc, ref f);

        // step 0, run step double
        self.miller_bit_o(i1, ref acc, ref f);

        self.sqr_target(i2, ref acc, ref f);

        // step -1, the next negative one step
        self.miller_bit_n(i2, ref acc, ref f);
        f
    }

    // 0 bit
    fn miller_bit_o(
        self: @Groth16PreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        let (pi_a_ppc, _, _) = self.ppc;
        let f_nz = *self.field_nz;
        let l1 = step_double(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_line(self.ppc, ref acc.g2, i, f_nz);
        self.schzip.sz_zero_bit(ref f, i, (l1, l2, l3), f_nz);
    }

    // 1 bit
    fn miller_bit_p(
        self: @Groth16PreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        let Groth16MillerG2 { pi_b, delta: _, gamma: _, line_count: _ } = self.q;
        let f_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let l1 = step_dbl_add(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc.g2, i, f_nz);
        self.schzip.sz_non_zero_bit(ref f, i, (l1, l2, l3), *self.residue_witness_inv, f_nz);
    }

    // -1 bit
    fn miller_bit_n(
        self: @Groth16PreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        // use neg q
        let Groth16MillerG2 { pi_b, delta: _, gamma: _, line_count: _ } = self.neg_q;
        let f_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let l1 = step_dbl_add(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc.g2, i, f_nz);
        self.schzip.sz_non_zero_bit(ref f, i, (l1, l2, l3), *self.residue_witness, f_nz);
    }

    // last step
    fn miller_last(
        self: @Groth16PreCompute<TLines, TSchZip>, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        // let Groth16PreCompute { p, q, ppc: _, neg_q: _, lines: _, field_nz, } = self;
        let f_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let l1 = correction_step(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, *self.q.pi_b, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc.g2, 'last', f_nz);
        self.schzip.sz_last_step(ref f, 'last', (l1, l2, l3), f_nz);
    }
}

// Does the verification
fn verify_miller<
    TLines, TSchZip, +SchZipProcess<TSchZip>, +StepLinesGet<TLines>, +Drop<TLines>, +Drop<TSchZip>
>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    setup: G16CircuitSetup<TLines>,
    schzip: TSchZip,
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
        schzip,
        residue_witness,
        residue_witness_inv,
        field_nz,
    };

    // q points accumulator
    let mut acc = SchZipAccumulator { g2: q, coeff_i: 0 };
    // run miller steps
    let miller_loop_result = ate_miller_loop_steps(precomp, ref acc);

    // multiply precomputed alphabeta_miller with the pairings
    miller_loop_result * alpha_beta
}

// Does the verification
pub fn schzip_verify<
    TLines, TSchZip, +SchZipProcess<TSchZip>, +StepLinesGet<TLines>, +Drop<TLines>, +Drop<TSchZip>
>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    cubic_scale: Fq6,
    setup: G16CircuitSetup<TLines>,
    schzip: TSchZip,
) -> bool {
    let one = Fq12Utils::one();
    assert(residue_witness_inv * residue_witness == one, 'incorrect residue witness');
    // residue_witness_inv as starter to incorporate  6 * x + 2 in the miller loop

    // miller loop result
    let Fq12 { c0, c1 } = verify_miller(
        pi_a, pi_b, pi_c, inputs, residue_witness, residue_witness_inv, setup, schzip
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
