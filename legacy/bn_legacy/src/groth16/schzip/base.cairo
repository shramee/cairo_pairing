use bn::groth16::schzip::utils::{SchZipSteps, SchzipPreCompute, SchZipAccumulator};
use bn::groth16::schzip::utils::{F034X2, Lines, LinesDbl};

use bn::traits::{FieldOps, FieldUtils, FieldMulShortcuts};

// Field tower
use bn::fields::{fq_12::Fq12FrobeniusTrait, fq_12_direct};
use bn::fields::{Fq, Fq2, Fq6, Fq12, fq12, FS034, FS01234, FS01,};
use bn::fields::{FqSparseTrait, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::fields::print::{
    FqDisplay, Fq2Display, Fq12Display, Fq6Display, F034Display, F01234Display, G2Display, G1Display
};

// Field direct
use fq_12_direct::{FS034Direct, Fq12DirectIntoFq12, Fq12IntoFq12Direct, Fq12Direct};
use fq_12_direct::{direct_to_tower, tower_to_direct};

// Math
use bn::curve::{m, U512BnAdd, U512BnSub, u512, U512Ops, scale_9 as x9, groups::ECOperations};
use m::{mul_nz, mul_u, u512_add, u512_add_u256, u512_reduce, add_u};
use bn::curve::UAddSubTrait;

use bn::g::{AffineG1, AffineG2,};
use bn::curve::{pairing, residue_witness, get_field_nz};
use bn::traits::{MillerPrecompute, MillerSteps};
use pairing::optimal_ate_utils::{p_precompute, step_double, step_dbl_add, correction_step};
use pairing::optimal_ate::{ate_miller_loop_steps_first_half, ate_miller_loop_steps_second_half};

// Groth16 utils
use residue_witness::{mul_by_root_27th, mul_by_root_27th_sq, ROOT_27TH, ROOT_27TH_SQ, CubicScale};
use bn::groth16::utils::{ICProcess, G16CircuitSetup, Groth16MillerG1, Groth16MillerG2};
use bn::groth16::utils::{StepLinesGet, StepLinesTrait};
use bn::groth16::utils_line::LineResult01234Trait;

#[derive(Drop)]
pub struct SchZipMock {
    print: bool,
    f01234: bool,
}

pub impl SchZipMockSteps of SchZipSteps<SchZipMock> {
    #[inline(always)]
    fn sz_init(self: @SchZipMock, ref f: Fq12, f_nz: NonZero<u256>) {
        if *self.print {
            println!(
                "from schzip_runner import fq12, f01234, f034, sz_zero_bit, sz_nz_bit, sz_last_step"
            );
        }
    }

    #[inline(always)]
    // Handled in individual bit operation functions
    fn sz_sqr(self: @SchZipMock, ref f: Fq12, ref i: u32, f_nz: NonZero<u256>) {}

    #[inline(always)]
    fn sz_zero_bit(self: @SchZipMock, ref f: Fq12, ref i: u32, lines: Lines, f_nz: NonZero<u256>) {
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
        self: @SchZipMock,
        ref f: Fq12,
        ref i: u32,
        lines: LinesDbl,
        witness: Fq12,
        f_nz: NonZero<u256>
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
    fn sz_last_step(
        self: @SchZipMock, ref f: Fq12, ref i: u32, lines: LinesDbl, f_nz: NonZero<u256>
    ) {
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

    fn sz_post_miller(
        self: @SchZipMock,
        f: Fq12,
        ref i: u32,
        alpha_beta: Fq12,
        residue: Fq12,
        residue_inv: Fq12,
        cubic_scale: CubicScale,
        f_nz: NonZero<u256>
    ) -> bool {
        let one = Fq12Utils::one();
        assert(residue_inv * residue == one, 'incorrect residue witness');

        // add cubic scale
        let (result, cubic_scale) = match cubic_scale {
            CubicScale::Zero => (f, FieldUtils::one()),
            CubicScale::One => (mul_by_root_27th(f, f_nz), ROOT_27TH),
            CubicScale::Two => (mul_by_root_27th_sq(f, f_nz), ROOT_27TH_SQ),
        };

        if *self.print {
            println!("sz_residue_inv_verify(\n{}\n{}\n)", residue_inv, residue,);
            println!(
                "sz_post_miller(\n{}\n{}\n{}\n{}\n{}\n{}\n)",
                f,
                alpha_beta,
                cubic_scale,
                residue_inv.frob1(),
                residue.frob2(),
                residue_inv.frob3()
            );
            println!("sz_print_coeffs()");
        }

        // Finishing up `q - q**2 + q**3` of `6 * x + 2 + q - q**2 + q**3`
        // result * residue^q * (1/residue)^(q**2) * residue^q**3
        let result = result
            * alpha_beta
            * residue_inv.frob1()
            * residue.frob2()
            * residue_inv.frob3();

        // return result == 1
        result == one
    }
}

// This loop doesn't make any updates to f: Fq12
// All updates are made via the SchZipSteps implementation
pub impl Groth16MillerSteps<
    TLines, TSchZip, +StepLinesGet<TLines>, +SchZipSteps<TSchZip>
> of MillerSteps<SchzipPreCompute<TLines, TSchZip>, SchZipAccumulator, Fq12> {
    #[inline(always)]
    fn sqr_target(
        self: @SchzipPreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        self.schzip.sz_sqr(ref f, ref acc.coeff_i, *self.field_nz);
    }

    fn miller_first_second(
        self: @SchzipPreCompute<TLines, TSchZip>, i1: u32, i2: u32, ref acc: SchZipAccumulator
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
        self: @SchzipPreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
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
        self: @SchzipPreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
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
        self: @SchzipPreCompute<TLines, TSchZip>, i: u32, ref acc: SchZipAccumulator, ref f: Fq12
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
        self: @SchzipPreCompute<TLines, TSchZip>, ref acc: SchZipAccumulator, ref f: Fq12
    ) {
        // let SchzipPreCompute { p, q, ppc: _, neg_q: _, lines: _, field_nz, } = self;
        let f_nz = *self.field_nz;
        let (pi_a_ppc, _, _) = self.ppc;
        let l1 = correction_step(ref acc.g2.pi_b, pi_a_ppc, *self.p.pi_a, *self.q.pi_b, f_nz);
        let (l2, l3) = self.lines.with_fxd_pt_lines(self.ppc, ref acc.g2, 'last', f_nz);
        self.schzip.sz_last_step(ref f, ref acc.coeff_i, (l1, l2, l3), f_nz);
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
) -> (Fq12, Fq12, SchzipPreCompute<TLines, TSchZip>, SchZipAccumulator) { //
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
    let precomp = SchzipPreCompute {
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
    let mut q_acc = SchZipAccumulator { g2: q, coeff_i: 0, rem_hash: PoseidonImpl::new() };

    // let miller_loop_result = precomp.miller_first_second(64, 65, ref acc);
    let (precomp, mut miller_loop_result) = ate_miller_loop_steps_first_half(precomp, ref q_acc);
    let precomp = ate_miller_loop_steps_second_half(precomp, ref q_acc, ref miller_loop_result);

    // returnpairing and precomputed alphabeta_miller with the pairings
    (miller_loop_result, alpha_beta, precomp, q_acc)
}

// Does the verification
pub fn schzip_base_verify<
    TLines, TSchZip, +SchZipSteps<TSchZip>, +StepLinesGet<TLines>, +Drop<TLines>, +Drop<TSchZip>
>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    cubic_scale: CubicScale,
    setup: G16CircuitSetup<TLines>,
    schzip: TSchZip,
    field_nz: NonZero<u256>,
) -> bool {
    // residue_witness_inv as starter to incorporate  6 * x + 2 in the miller loop

    // miller loop result
    let (f, alpha_beta, precomp, mut acc) = schzip_miller(
        pi_a, pi_b, pi_c, inputs, residue_witness, residue_witness_inv, setup, schzip, field_nz
    );

    precomp
        .schzip
        .sz_post_miller(
            f,
            ref acc.coeff_i,
            alpha_beta,
            residue_witness,
            residue_witness_inv,
            cubic_scale,
            field_nz
        )
}
