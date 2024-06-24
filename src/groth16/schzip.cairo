use bn::curve::UAddSubTrait;
use bn::groth16::utils_line::LineResult01234Trait;
use bn::fields::{fq_12, fq_12_direct};
use bn::fields::{Fq, Fq2, Fq6, print::{FqDisplay, Fq12Display, F034Display, F01234Display}};
use bn::fields::{fq, fq12, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
use bn::fields::{FS034, FS01234, FS01, fq_sparse::FqSparseTrait};
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use fq_12::Fq12FrobeniusTrait;
use fq_12_direct::{FS034Direct, Fq12DirectIntoFq12, Fq12IntoFq12Direct, Fq12Direct};
use fq_12_direct::{direct_to_tower, tower_to_direct, tower01234_to_direct, tower034_to_direct,};
use bn::traits::FieldOps;
use bn::curve::residue_witness::{
    ROOT_27TH, ROOT_27TH_SQ, mul_by_root_27th, mul_by_root_27th_sq, CubicScale
};
use bn::curve::{m, U512BnAdd, U512BnSub, u512, U512Ops, scale_9 as x9, groups::ECOperations};
use m::{sqr_nz, mul_nz, mul_u, u512_add, u512_add_u256, u512_reduce, add_u};
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::curve::{pairing, get_field_nz};
use bn::traits::{MillerPrecompute, MillerSteps};
use core::hash::HashStateTrait;
use pairing::optimal_ate::{ate_miller_loop_steps};
use pairing::optimal_ate_utils::{p_precompute, line_fn_at_p, LineFn};
use pairing::optimal_ate_utils::{step_double, step_dbl_add, correction_step};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{ICProcess, G16CircuitSetup, Groth16PrecomputedStep};
use bn::groth16::utils::{StepLinesGet, StepLinesTrait, fq12_034_034_034};
use bn::groth16::utils::{Groth16MillerG1, Groth16MillerG2, PPrecomputeX3, LineResult,};
use bn::groth16::schzip_base::{SchZipAccumulator, Groth16PreCompute, SchZipSteps};
use bn::groth16::schzip_base::{Groth16MillerSteps, schzip_miller, schzip_verify};
use bn::groth16::schzip_base::{SchZipMock, SchZipMockSteps, SchZipEval};
use bn::traits::{FieldUtils, FieldMulShortcuts};

type F034X2 = (FS034, FS034);
type Lines = (FS034, FS034, FS034);
type LinesDbl = (F034X2, F034X2, F034X2);
type NZ256 = NonZero<u256>;

// const COEFFICIENTS_COUNT: usize = 3234;
const COEFFICIENTS_COUNT: usize = 3299;

#[derive(Drop)]
pub struct SchZipCommitments {
    coefficients: Array<u256>,
    fiat_shamir_powers: Array<u256>,
    p12_x: u256,
}

// Schwartz Zippel lemma for FQ12 operation commitment verification
// ----------------------------------------------------------------
// Taking an FQ12 as a polynomial of degree 11, product of polynomials can be used to verify the
// committed coefficients with Schwartz Zippel lemma.
// As described in https://hackmd.io/@feltroidprime/B1eyHHXNT,
// For A and B element of Fq12 represented as direct extensions,
// ```A(x) * B(x) = R(x) + Q(x) * P12(x)```
// where `R(x)` is a polynomial of degree 11 or less.
// Expanding this to include the whole bit operation inside the miller loop,
#[generate_trait]
impl SchZipPolyCommitHandler of SchZipPolyCommitHandlerTrait {
    fn fq12_at_coeffs_index(self: @SchZipCommitments, i: u32) -> Fq12 {
        let c = self.coefficients;
        fq12(
            *c[i],
            *c[i + 1],
            *c[i + 2],
            *c[i + 3],
            *c[i + 4],
            *c[i + 5],
            *c[i + 6],
            *c[i + 7],
            *c[i + 8],
            *c[i + 9],
            *c[i + 10],
            *c[i + 11],
        )
    }

    // Handles Schwartz Zippel verification for zero `O` bits,
    // * Commitment contains 64 coefficients
    // * F ∈ Fq12, miller loop aggregation
    // * L1_L2 ∈ Sparse01234, Loop step lines L1 and L2 multiplied for lower degree
    // * L3 ∈ Sparse034, Last L3 line
    // * ```F(x) * F(x) * L1_L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
    fn zero_bit(
        self: @SchZipCommitments, ref f: Fq12, i: u32, l1_l2: FS01234, l3: FS034, f_nz: NZ256
    ) {
        let c = self.coefficients;

        // F(x) * F(x) * L1_L2(x) * L3(x) = R(x) + Q(x) * P12(x)
        let f_x = SchZipEval::eval_fq12_direct(f.into(), self.fiat_shamir_powers, f_nz);
        let l1_l2_x = SchZipEval::eval_01234(l1_l2, self.fiat_shamir_powers, f_nz);
        let l3_x = SchZipEval::eval_034(l3, self.fiat_shamir_powers, f_nz);

        // RHS = F(x) * F(x) * L1_L2(x) * L3(x)
        let rhs: u512 = f_x.sqr().u_mul(l1_l2_x * l3_x);

        let r = self.fq12_at_coeffs_index(i);

        let r_x = SchZipEval::eval_fq12_direct_u(r.into(), self.fiat_shamir_powers, f_nz);
        let q_x = SchZipEval::eval_poly_30(c, i + 12, self.fiat_shamir_powers, f_nz);
        // LHS = R(x) + Q(x) * P12(x)
        let lhs = r_x + mul_u(q_x, *self.p12_x);

        // assert rhs == lhs mod field, or rhs - lhs == 0
        assert(u512_reduce(rhs - lhs, f_nz) == 0, 'SchZip 0 bit verif failed');

        f = r;
    }

    // Handles Schwartz Zippel verification for non-zero `P`/`N` bits,
    // * Commitment contains 42 coefficients
    // * F ∈ Fq12, miller loop aggregation
    // * L1, L2, L3 ∈ Sparse01234, Loop step lines
    // * Witness ∈ Fq12, Residue witness (or it's inverse based on the bit value)
    // * ```F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) = R(x) + Q(x) * P12(x)```
    fn nz_bit(
        self: @SchZipCommitments,
        ref f: Fq12,
        i: u32,
        l1: FS01234,
        l2: FS01234,
        l3: FS01234,
        witness: Fq12,
        f_nz: NZ256
    ) {
        let c = self.coefficients;

        // F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) = R(x) + Q(x) * P12(x)
        let f_x = SchZipEval::eval_fq12_direct(f.into(), self.fiat_shamir_powers, f_nz);
        let l1_x = SchZipEval::eval_01234(l1, self.fiat_shamir_powers, f_nz);
        let l2_x = SchZipEval::eval_01234(l2, self.fiat_shamir_powers, f_nz);
        let l3_x = SchZipEval::eval_01234(l3, self.fiat_shamir_powers, f_nz);
        let w_x = SchZipEval::eval_fq12_direct(witness.into(), self.fiat_shamir_powers, f_nz);

        // RHS = F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x)
        let rhs: u512 = f_x.sqr().u_mul(l1_x * l2_x * l3_x * w_x);

        let r = self.fq12_at_coeffs_index(i);

        let r_x = SchZipEval::eval_fq12_direct_u(r.into(), self.fiat_shamir_powers, f_nz);
        let q_x = SchZipEval::eval_poly_52(c, i + 12, self.fiat_shamir_powers, f_nz);
        // LHS = R(x) + Q(x) * P12(x)
        let lhs = r_x + mul_u(q_x, *self.p12_x);

        // assert rhs == lhs mod field, or rhs - lhs == 0
        assert(u512_reduce(rhs - lhs, f_nz) == 0, 'SchZip 1/-1 bit verif failed');

        f = r;
    }

    // Handles Schwartz Zippel verification for miller loop correction step,
    // * Commitment contains 42 coefficients
    // * F ∈ Fq12, miller loop aggregation
    // * L1, L2, L3 ∈ Sparse01234, Correction step lines
    // * ```F(x) * L1(x) * L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
    fn last_step(
        self: @SchZipCommitments,
        ref f: Fq12,
        i: u32,
        l1: FS01234,
        l2: FS01234,
        l3: FS01234,
        f_nz: NZ256
    ) {
        core::internal::revoke_ap_tracking();

        let c = self.coefficients;

        // F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) = R(x) + Q(x) * P12(x)
        let f_x = SchZipEval::eval_fq12_direct(f.into(), self.fiat_shamir_powers, f_nz);
        let l1_x = SchZipEval::eval_01234(l1, self.fiat_shamir_powers, f_nz);
        let l2_x = SchZipEval::eval_01234(l2, self.fiat_shamir_powers, f_nz);
        let l3_x = SchZipEval::eval_01234(l3, self.fiat_shamir_powers, f_nz);

        // RHS = F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x)
        let rhs: u512 = f_x.u_mul(l1_x * l2_x * l3_x);

        let r = self.fq12_at_coeffs_index(i);

        let r_x = SchZipEval::eval_fq12_direct_u(r.into(), self.fiat_shamir_powers, f_nz);
        let q_x = SchZipEval::eval_poly_30(c, i + 12, self.fiat_shamir_powers, f_nz);
        // LHS = R(x) + Q(x) * P12(x)
        let lhs = r_x + mul_u(q_x, *self.p12_x);

        // assert rhs == lhs mod field, or rhs - lhs == 0
        assert(u512_reduce(rhs - lhs, f_nz) == 0, 'SchZip last step verif failed');

        f = direct_to_tower(r);
    }

    // Handles Schwartz Zippel verification for inversion operation,
    // * Commitment contains 12 coefficients
    // * R is just 1 so we have 11 less coefficients
    // * F, I ∈ Fq12, miller loop aggregation
    // * ```F(x) * I(x) = R(x) + Q(x) * P12(x)```
    // * For r = 1, ```F(x) * I(x) = 1 + Q(x) * P12(x)```
    // * Or, ```F(x) * I(x) - Q(x) * P12(x) = 1```
    fn verify_inv_direct(self: @SchZipCommitments, i: u32, f: Fq12, inv: Fq12, f_nz: NZ256) {
        core::internal::revoke_ap_tracking();

        let c = self.coefficients;
        let f_x = SchZipEval::eval_fq12_direct(f.into(), self.fiat_shamir_powers, f_nz);
        let inv_x = SchZipEval::eval_fq12_direct(inv.into(), self.fiat_shamir_powers, f_nz);

        let rhs: u512 = f_x.u_mul(inv_x);

        let q_x = SchZipEval::eval_poly_11(c, i + 1, self.fiat_shamir_powers, f_nz);
        let lhs = mul_u(q_x, *self.p12_x);

        assert(u512_reduce(rhs - lhs, f_nz) == 1, 'SchZip inv verif failed');
    }
}

pub impl SchZipPolyCommitImpl of SchZipSteps<SchZipCommitments> {
    #[inline(always)]
    fn sz_init(self: @SchZipCommitments, ref f: Fq12, f_nz: NZ256) { //
        // Convert Fq12 tower to direct polynomial representation
        assert(self.coefficients.len() == COEFFICIENTS_COUNT, 'wrong number of coefficients');
    }

    #[inline(always)]
    // Handled in individual bit operation functions
    fn sz_sqr(self: @SchZipCommitments, ref f: Fq12, ref i: u32, f_nz: NZ256) {}

    #[inline(always)]
    fn sz_zero_bit(self: @SchZipCommitments, ref f: Fq12, ref i: u32, lines: Lines, f_nz: NZ256) {
        // Uses 42 coefficients
        let (l1, l2, l3) = lines;
        let l1_l2 = l1.mul_034_by_034(l2, f_nz);
        self.zero_bit(ref f, i, l1_l2, l3, f_nz);
        i += 42;
    }

    #[inline(always)]
    fn sz_nz_bit(
        self: @SchZipCommitments,
        ref f: Fq12,
        ref i: u32,
        lines: LinesDbl,
        witness: Fq12,
        f_nz: NZ256
    ) {
        // Uses 64 coefficients
        let (l1, l2, l3) = lines;
        let l1 = l1.as_01234(f_nz);
        let l2 = l2.as_01234(f_nz);
        let l3 = l3.as_01234(f_nz);
        self.nz_bit(ref f, i, l1, l2, l3, witness, f_nz);
        i += 64;
    }

    #[inline(always)]
    fn sz_last_step(
        self: @SchZipCommitments, ref f: Fq12, ref i: u32, lines: LinesDbl, f_nz: NZ256
    ) {
        // Uses 42 coefficients
        let (l1, l2, l3) = lines;
        let l1 = l1.as_01234(f_nz);
        let l2 = l2.as_01234(f_nz);
        let l3 = l3.as_01234(f_nz);

        self.last_step(ref f, i, l1, l2, l3, f_nz);
        i += 42;
    }

    fn sz_post_miller(
        self: @SchZipCommitments,
        f: Fq12,
        ref i: u32,
        alpha_beta: Fq12,
        residue: Fq12,
        residue_inv: Fq12,
        cubic_scale: CubicScale,
        f_nz: NZ256
    ) -> bool {
        self.verify_inv_direct(i, residue, residue_inv, f_nz);
        let one = Fq12Utils::one();

        let residue_inv_tow = direct_to_tower(residue_inv);
        let residue_tow = direct_to_tower(residue);

        // add cubic scale
        let result = match cubic_scale {
            CubicScale::Zero => f,
            CubicScale::One => mul_by_root_27th(f, f_nz),
            CubicScale::Two => mul_by_root_27th_sq(f, f_nz),
        };

        // Finishing up `q - q**2 + q**3` of `6 * x + 2 + q - q**2 + q**3`
        // result * residue^q * (1/residue)^(q**2) * residue^q**3
        let result = result * residue_inv.frob1() * residue.frob2() * residue_inv.frob3();

        // return result == 1
        result == one
    }
}

// Calculate 51 powers of x modulo field
pub fn powers_53(x: u256, field_nz: NZ256) -> Array<u256> {
    let x2 = sqr_nz(x, field_nz);
    let x3 = mul_nz(x2, x, field_nz);
    let x4 = sqr_nz(x2, field_nz);
    let x5 = mul_nz(x4, x, field_nz);
    let x6 = sqr_nz(x3, field_nz);
    let x7 = mul_nz(x6, x, field_nz);
    let x8 = sqr_nz(x4, field_nz);
    let x9 = mul_nz(x8, x, field_nz);
    let x10 = sqr_nz(x5, field_nz);
    let x11 = mul_nz(x10, x, field_nz);
    let x12 = sqr_nz(x6, field_nz);
    let x13 = mul_nz(x12, x, field_nz);
    let x14 = sqr_nz(x7, field_nz);
    let x15 = mul_nz(x14, x, field_nz);
    let x16 = sqr_nz(x8, field_nz);
    let x17 = mul_nz(x16, x, field_nz);
    let x18 = sqr_nz(x9, field_nz);
    let x19 = mul_nz(x18, x, field_nz);
    let x20 = sqr_nz(x10, field_nz);
    let x21 = mul_nz(x20, x, field_nz);
    let x22 = sqr_nz(x11, field_nz);
    let x23 = mul_nz(x22, x, field_nz);
    let x24 = sqr_nz(x12, field_nz);
    let x25 = mul_nz(x24, x, field_nz);
    let x26 = sqr_nz(x13, field_nz);
    let x27 = mul_nz(x26, x, field_nz);
    let x28 = sqr_nz(x14, field_nz);
    let x29 = mul_nz(x28, x, field_nz);
    let x30 = sqr_nz(x15, field_nz);
    let x31 = mul_nz(x30, x, field_nz);
    let x32 = sqr_nz(x16, field_nz);
    let x33 = mul_nz(x32, x, field_nz);
    let x34 = sqr_nz(x17, field_nz);
    let x35 = mul_nz(x34, x, field_nz);
    let x36 = sqr_nz(x18, field_nz);
    let x37 = mul_nz(x36, x, field_nz);
    let x38 = sqr_nz(x19, field_nz);
    let x39 = mul_nz(x38, x, field_nz);
    let x40 = sqr_nz(x20, field_nz);
    let x41 = mul_nz(x40, x, field_nz);
    let x42 = sqr_nz(x21, field_nz);
    let x43 = mul_nz(x42, x, field_nz);
    let x44 = sqr_nz(x22, field_nz);
    let x45 = mul_nz(x44, x, field_nz);
    let x46 = sqr_nz(x23, field_nz);
    let x47 = mul_nz(x46, x, field_nz);
    let x48 = sqr_nz(x24, field_nz);
    let x49 = mul_nz(x48, x, field_nz);
    let x50 = sqr_nz(x25, field_nz);
    let x51 = mul_nz(x50, x, field_nz);
    let x52 = sqr_nz(x26, field_nz);
    let x53 = mul_nz(x52, x, field_nz);
    array![
        1,
        x,
        x2,
        x3,
        x4,
        x5,
        x6,
        x7,
        x8,
        x9,
        x10,
        x11,
        x12,
        x13,
        x14,
        x15,
        x16,
        x17,
        x18,
        x19,
        x20,
        x21,
        x22,
        x23,
        x24,
        x25,
        x26,
        x27,
        x28,
        x29,
        x30,
        x31,
        x32,
        x33,
        x34,
        x35,
        x36,
        x37,
        x38,
        x39,
        x40,
        x41,
        x42,
        x43,
        x44,
        x45,
        x46,
        x47,
        x48,
        x49,
        x50,
        x51,
        x52,
        x53,
    ]
}

pub fn schzip_verify_with_commitments<TLines, +StepLinesGet<TLines>, +Drop<TLines>>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    cubic_scale: CubicScale,
    setup: G16CircuitSetup<TLines>,
    coefficients: Array<u256>,
) -> bool {
    let mut coeff_i = 0;
    let mut hasher = core::poseidon::PoseidonImpl::new();
    let coeffs = @coefficients;
    let coeffs_count = coeffs.len();
    while coeff_i != coeffs_count {
        let c = *(coeffs[coeff_i]);
        hasher = hasher.update(c.low.into());
        hasher = hasher.update(c.high.into());
        coeff_i += 1;
    };
    let f_nz = get_field_nz();
    let fiat_shamir: u256 = hasher.finalize().into();

    let mut fiat_shamir_powers = powers_53(fiat_shamir, f_nz);

    // x^12 + 21888242871839275222246405745257275088696311157297823662689037894645226208565x^6 + 82
    let minus18_x_6 = mul_u(
        21888242871839275222246405745257275088696311157297823662689037894645226208565,
        *fiat_shamir_powers[6]
    );
    let p12_x = u512_add_u256(minus18_x_6, add_u(*fiat_shamir_powers[12], 82));
    let p12_x = u512_reduce(p12_x, f_nz);

    let schzip = SchZipCommitments { coefficients, fiat_shamir_powers, p12_x };

    schzip_verify(
        pi_a,
        pi_b,
        pi_c,
        inputs,
        tower_to_direct(residue_witness).into(),
        tower_to_direct(residue_witness_inv).into(),
        cubic_scale,
        setup,
        schzip,
        f_nz
    )
}
