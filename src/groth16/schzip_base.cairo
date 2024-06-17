use core::array::SpanTrait;
use bn::groth16::utils_line::LineResult01234Trait;
use bn::fields::fq_12::Fq12FrobeniusTrait;
use bn::traits::FieldUtils;
use bn::curve::{u512, U512BnAdd, U512Ops, scale_9 as x9, groups::ECOperations};
use bn::math::fast_mod::{sqr_nz, mul_nz, mul_u, u512_add, u512_add_u256, u512_reduce};
use bn::fields::fq_12_direct::{FS034Direct, Fq12DirectIntoFq12, Fq12Direct};
use bn::fields::fq_12_direct::{
    tower_to_direct, tower01234_to_direct, tower034_to_direct, direct_to_tower,
};
use bn::fields::{FS034, FS01234, FS01, fq_sparse::FqSparseTrait};
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, Fq6, print::{FqDisplay, Fq12Display, F034Display, F01234Display}};
use bn::fields::{fq, fq12, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
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

// All changes to f: Fq12 are made via the SchZipSteps implementation
pub trait SchZipSteps<T> {
    fn sz_init(self: @T, ref f: Fq12, f_nz: NZ256);
    fn sz_sqr(self: @T, ref f: Fq12, ref i: u32, f_nz: NZ256);
    fn sz_zero_bit(self: @T, ref f: Fq12, ref i: u32, lines: Lines, f_nz: NZ256);
    fn sz_nz_bit(self: @T, ref f: Fq12, ref i: u32, lines: LinesDbl, witness: Fq12, f_nz: NZ256);
    fn sz_last_step(self: @T, ref f: Fq12, ref i: u32, lines: LinesDbl, f_nz: NZ256);
}

#[derive(Drop)]
pub struct SchZipMock {
    print: bool,
}

pub impl SchZipMockSteps of SchZipSteps<SchZipMock> {
    #[inline(always)]
    fn sz_init(self: @SchZipMock, ref f: Fq12, f_nz: NZ256) {
        if *self.print {
            println!(
                "from schzip_runner import fq12, f01234, f034, sz_zero_bit, sz_nz_bit, sz_last_step"
            );
        }
    }

    #[inline(always)]
    // Handled in individual bit operation functions
    fn sz_sqr(self: @SchZipMock, ref f: Fq12, ref i: u32, f_nz: NZ256) {}

    #[inline(always)]
    fn sz_zero_bit(self: @SchZipMock, ref f: Fq12, ref i: u32, lines: Lines, f_nz: NZ256) {
        let (l1, l2, l3) = lines;
        let l1_l2 = l1.mul_034_by_034(l2, f_nz);
        if *self.print {
            println!("sz_zero_bit(\n{}\n{}\n{}\n)", f, l1_l2, l3);
        }
        f = f.sqr();
        f = f.mul(l1_l2.mul_01234_034(l3, f_nz));
    }

    #[inline(always)]
    fn sz_nz_bit(
        self: @SchZipMock, ref f: Fq12, ref i: u32, lines: LinesDbl, witness: Fq12, f_nz: NZ256
    ) {
        let (l1, l2, l3) = lines;
        let l1 = l1.as_01234(f_nz);
        let l2 = l2.as_01234(f_nz);
        let l3 = l3.as_01234(f_nz);
        if *self.print {
            println!("sz_nz_bit(\n{}\n{}\n{}\n{}\n{}\n)", f, l1, l2, l3, witness);
        }
        f = f.sqr();
        f = f.mul_01234(l1, f_nz);
        f = f.mul_01234(l2, f_nz);
        f = f.mul_01234(l3, f_nz);
        f = f.mul(witness);
    }

    #[inline(always)]
    fn sz_last_step(self: @SchZipMock, ref f: Fq12, ref i: u32, lines: LinesDbl, f_nz: NZ256) {
        let (l1, l2, l3) = lines;
        let l1 = l1.as_01234(f_nz);
        let l2 = l2.as_01234(f_nz);
        let l3 = l3.as_01234(f_nz);

        if *self.print {
            println!("sz_last_step(\n{}\n{}\n{}\n{}\n)", f, l1, l2, l3);
        }
        f = f.mul_01234(l1, f_nz);
        f = f.mul_01234(l2, f_nz);
        f = f.mul_01234(l3, f_nz);
    }
}

// This loop doesn't make any updates to f: Fq12
// All updates are made via the SchZipSteps implementation
pub impl Groth16MillerSteps<
    TLines, TSchZip, +StepLinesGet<TLines>, +SchZipSteps<TSchZip>
> of MillerSteps<Groth16PreCompute<TLines, TSchZip>, SchZipAccumulator, Fq12> {
    #[inline(always)]
    fn sqr_target(
        self: @Groth16PreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        self.schzip.sz_sqr(ref f, ref acc.coeff_i, *self.field_nz);
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
        core::internal::revoke_ap_tracking();
        let (pi_a_ppc, _, _) = self.ppc;
        let f_nz = *self.field_nz;
        let l1 = step_double(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_line(self.ppc, ref acc.g2, i, f_nz);
        self.schzip.sz_zero_bit(ref f, ref acc.coeff_i, (l1, l2, l3), f_nz);
    // println!("o_bit {i}: {}", f);
    // println!("o_bit direct {i}: {}", tower_to_direct(f));
    }

    // 1 bit
    fn miller_bit_p(
        self: @Groth16PreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        core::internal::revoke_ap_tracking();
        let Groth16MillerG2 { pi_b, delta: _, gamma: _, line_count: _ } = self.q;
        let f_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let l1 = step_dbl_add(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc.g2, i, f_nz);
        self
            .schzip
            .sz_nz_bit(ref f, ref acc.coeff_i, (l1, l2, l3), *self.residue_witness_inv, f_nz);
    }

    // -1 bit
    fn miller_bit_n(
        self: @Groth16PreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        core::internal::revoke_ap_tracking();
        // use neg q
        let Groth16MillerG2 { pi_b, delta: _, gamma: _, line_count: _ } = self.neg_q;
        let f_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let l1 = step_dbl_add(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc.g2, i, f_nz);
        self.schzip.sz_nz_bit(ref f, ref acc.coeff_i, (l1, l2, l3), *self.residue_witness, f_nz);
    // println!("n_bit {i}: {}", f);
    // println!("n_bit direct {i}: {}", tower_to_direct(f));
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
        self.schzip.sz_last_step(ref f, ref acc.coeff_i, (l1, l2, l3), f_nz);
    }
}

#[generate_trait]
impl SchZipEval of SchZipEvalTrait {
    fn eval_01234(a: FS01234, fiat_shamir_pow: @Array<u256>, f_nz: NZ256) -> Fq { //
        // a tower_to_direct
        let ((c0, c1, c2, c3, c4), (c6, c7, c8, c9, c10)) = tower01234_to_direct(a);

        // evaluate FS01234 polynomial at fiat_shamir with precomputed powers
        let term_1 = mul_u((*fiat_shamir_pow[1]), c1.c0);
        let term_2 = mul_u((*fiat_shamir_pow[2]), c2.c0);
        let term_3 = mul_u((*fiat_shamir_pow[3]), c3.c0);
        let term_4 = mul_u((*fiat_shamir_pow[4]), c4.c0);
        let term_6 = mul_u((*fiat_shamir_pow[6]), c6.c0);
        let term_7 = mul_u((*fiat_shamir_pow[7]), c7.c0);
        let term_8 = mul_u((*fiat_shamir_pow[8]), c8.c0);
        let term_9 = mul_u((*fiat_shamir_pow[9]), c9.c0);
        let term_10 = mul_u((*fiat_shamir_pow[10]), c10.c0);

        // return the reduced sum of the terms
        let eval = u512_add_u256(term_1, c0.c0) // term x^1 + x^0
            .u_add(term_2) // term x^2
            .u_add(term_3) // term x^3
            .u_add(term_4) // term x^4
            .u_add(term_6) // term x^6
            .u_add(term_7) // term x^7
            .u_add(term_8) // term x^8
            .u_add(term_9) // term x^9
            .u_add(term_10); // term x^10
        fq(u512_reduce(eval, f_nz))
    }

    fn eval_fq12_direct_u(a: Fq12Direct, fiat_shamir_pow: @Array<u256>, f_nz: NZ256) -> u512 { //
        let (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11) = a;
        // evaluate FS01234 polynomial at fiat_shamir with precomputed powers
        let term_0 = a0.c0;
        let term_1 = mul_u((*fiat_shamir_pow[1]), a1.c0);
        let term_2 = mul_u((*fiat_shamir_pow[2]), a2.c0);
        let term_3 = mul_u((*fiat_shamir_pow[3]), a3.c0);
        let term_4 = mul_u((*fiat_shamir_pow[4]), a4.c0);
        let term_5 = mul_u((*fiat_shamir_pow[5]), a5.c0);
        let term_6 = mul_u((*fiat_shamir_pow[6]), a6.c0);
        let term_7 = mul_u((*fiat_shamir_pow[7]), a7.c0);
        let term_8 = mul_u((*fiat_shamir_pow[8]), a8.c0);
        let term_9 = mul_u((*fiat_shamir_pow[9]), a9.c0);
        let term_10 = mul_u((*fiat_shamir_pow[10]), a10.c0);
        let term_11 = mul_u((*fiat_shamir_pow[11]), a11.c0);

        // return the reduced sum of the terms
        u512_add_u256(term_1, term_0) // term x^1 + x^0
            .u_add(term_2) // term x^2
            .u_add(term_3) // term x^3
            .u_add(term_4) // term x^4
            .u_add(term_5) // term x^5
            .u_add(term_6) // term x^6
            .u_add(term_7) // term x^7
            .u_add(term_8) // term x^8
            .u_add(term_9) // term x^9
            .u_add(term_10) // term x^10
            .u_add(term_11) // term x^11
    }

    fn eval_fq12_direct(a: Fq12Direct, fiat_shamir_pow: @Array<u256>, f_nz: NZ256) -> Fq { //
        fq(u512_reduce(SchZipEval::eval_fq12_direct_u(a, fiat_shamir_pow, f_nz), f_nz))
    }

    fn eval_fq12(a: Fq12, fiat_shamir_pow: @Array<u256>, f_nz: NZ256) -> Fq { //
        SchZipEval::eval_fq12_direct(tower_to_direct(a), fiat_shamir_pow, f_nz)
    }

    fn eval_034(a: FS034, fiat_shamir_pow: @Array<u256>, f_nz: NZ256) -> Fq { //
        // a tower_to_direct
        let FS034Direct { c1, c3, c7, c9 } = tower034_to_direct(a);
        // evaluate FS01234 polynomial at fiat_shamir with precomputed powers
        let term_1 = mul_u(*fiat_shamir_pow[1], c1.c0);
        let term_3 = mul_u(*fiat_shamir_pow[3], c3.c0);
        let term_7 = mul_u(*fiat_shamir_pow[7], c7.c0);
        let term_9 = mul_u(*fiat_shamir_pow[9], c9.c0);
        // return the reduced sum of the terms
        let eval = u512_add_u256(term_1, 1) // term x^1 + x^0
            .u_add(term_3) // term x^3
            .u_add(term_7) // term x^7
            .u_add(term_9); // term x^9
        fq(u512_reduce(eval, f_nz))
    }

    #[inline(always)]
    fn eval_poly_30(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NZ256
    ) -> u256 {
        u512_reduce(SchZipEval::eval_poly_30_u(polynomial, i, fiat_shamir_pow, f_nz), f_nz)
    }

    fn eval_poly_30_u(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NZ256
    ) -> u512 {
        // We can do 16 additions without overflow
        let mut acc1 = u512_add_u256(
            mul_u(*fiat_shamir_pow[1], *polynomial[i + 1]), *polynomial[i]
        );
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[2], *polynomial[i + 2]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[3], *polynomial[i + 3]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[4], *polynomial[i + 4]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[5], *polynomial[i + 5]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[6], *polynomial[i + 6]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[7], *polynomial[i + 7]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[8], *polynomial[i + 8]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[9], *polynomial[i + 9]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[10], *polynomial[i + 10]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[11], *polynomial[i + 11]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[12], *polynomial[i + 12]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[13], *polynomial[i + 13]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[14], *polynomial[i + 14]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[15], *polynomial[i + 15]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[16], *polynomial[i + 16]));

        // After next 16 additions we do U512BnAdd to reduce if needed

        let mut acc2 = mul_u(*fiat_shamir_pow[17], *polynomial[i + 17]);
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[18], *polynomial[i + 18]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[19], *polynomial[i + 19]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[20], *polynomial[i + 20]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[21], *polynomial[i + 21]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[22], *polynomial[i + 22]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[23], *polynomial[i + 23]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[24], *polynomial[i + 24]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[25], *polynomial[i + 25]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[26], *polynomial[i + 26]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[27], *polynomial[i + 27]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[28], *polynomial[i + 28]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[29], *polynomial[i + 29]));

        acc1 + acc2
    }

    fn eval_poly_52(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NZ256
    ) -> u256 { //
        core::internal::revoke_ap_tracking();
        // Process first 30 terms
        let acc1 = SchZipEval::eval_poly_30_u(polynomial, i, fiat_shamir_pow, f_nz);

        // Process next 16 terms, i 30 - 45
        let mut acc2 = mul_u(*fiat_shamir_pow[30], *polynomial[i + 30]);
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[31], *polynomial[i + 31]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[32], *polynomial[i + 32]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[33], *polynomial[i + 33]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[34], *polynomial[i + 34]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[35], *polynomial[i + 35]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[36], *polynomial[i + 36]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[37], *polynomial[i + 37]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[38], *polynomial[i + 38]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[39], *polynomial[i + 39]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[40], *polynomial[i + 40]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[41], *polynomial[i + 41]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[42], *polynomial[i + 42]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[43], *polynomial[i + 43]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[44], *polynomial[i + 44]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[45], *polynomial[i + 45]));

        let mut acc3 = mul_u(*fiat_shamir_pow[46], *polynomial[i + 46]);
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[47], *polynomial[i + 47]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[48], *polynomial[i + 48]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[49], *polynomial[i + 49]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[50], *polynomial[i + 50]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[51], *polynomial[i + 51]));

        u512_reduce(acc1 + acc2 + acc3, f_nz)
    }

    fn eval_polynomial_u(
        mut polynomial: Span<u256>, fiat_shamir_pow: @Array<u256>, f_nz: NZ256
    ) -> u512 { //
        let c0 = polynomial.pop_front().unwrap();
        let mut acc = u512 { limb0: *c0.low, limb1: *c0.high, limb2: 0, limb3: 0 };
        let mut term_i = 0;
        let poly_len = polynomial.len();
        loop {
            term_i += 1;
            if poly_len == term_i {
                break;
            }
            acc = u512_add(acc, mul_u(*fiat_shamir_pow[term_i], *polynomial[term_i]));
        };

        acc
    }
}

// Does the verification
fn schzip_miller<
    TLines, TSchZip, +SchZipSteps<TSchZip>, +StepLinesGet<TLines>, +Drop<TLines>, +Drop<TSchZip>
>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    setup: G16CircuitSetup<TLines>,
    schzip: TSchZip,
    field_nz: NonZero<u256>,
) -> Fq12 { //
    // Compute k from ic and public_inputs
    let G16CircuitSetup { alpha_beta, gamma, gamma_neg, delta, delta_neg, lines, ic, } = setup;

    let (ic0, ics) = ic;
    let k = (ics, inputs).process_inputs_and_ic(ic0);

    // let pi_a = pi_a.neg();

    // build precompute
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

    // let miller_loop_result = precomp.miller_first_second(64, 65, ref acc);
    let miller_loop_result = ate_miller_loop_steps(precomp, ref acc);

    // multiply precomputed alphabeta_miller with the pairings
    miller_loop_result * alpha_beta
}

// Does the verification
pub fn schzip_verify<
    TLines, TSchZip, +SchZipSteps<TSchZip>, +StepLinesGet<TLines>, +Drop<TLines>, +Drop<TSchZip>
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
    field_nz: NonZero<u256>,
) -> bool {
    let one = Fq12Utils::one();
    assert(residue_witness_inv * residue_witness == one, 'incorrect residue witness');
    // residue_witness_inv as starter to incorporate  6 * x + 2 in the miller loop

    // miller loop result
    let Fq12 { c0, c1 } = schzip_miller(
        pi_a, pi_b, pi_c, inputs, residue_witness, residue_witness_inv, setup, schzip, field_nz
    );

    // add cubic scale
    let result = Fq12 { c0: c0 * cubic_scale, c1: c1 * cubic_scale };

    // Finishing up `q - q**2 + q**3` of `6 * x + 2 + q - q**2 + q**3`
    // result^(q + q**3) * (1/residue)^(q**2)
    let result = result
        * residue_witness_inv.frob1()
        * residue_witness.frob2()
        * residue_witness_inv.frob3();

    // return result == 1
    result == one
}
