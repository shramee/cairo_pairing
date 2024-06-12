use bn::groth16::utils_line::LineResult01234Trait;
use bn::fields::fq_12::Fq12FrobeniusTrait;
use bn::fields::fq_12_direct::{tower_to_direct, direct_to_tower};
use bn::traits::FieldUtils;
use bn::fields::{FS034, FS01234, FS01, fq_sparse::FqSparseTrait};
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, Fq6, print::{FqDisplay, Fq12Display, F034Display, F01234Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
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
use bn::groth16::schzip_base::{Groth16MillerSteps, verify_miller, schzip_verify};
use bn::groth16::schzip_base::{SchZipMock, SchZipMockSteps};

type F034X2 = (FS034, FS034);
type Lines = (FS034, FS034, FS034);
type LinesDbl = (F034X2, F034X2, F034X2);
type NZ256 = NonZero<u256>;

const COEFFICIENTS_COUNT: usize = 3234;

#[derive(Drop)]
pub struct SchZipCommitments {
    coefficients: Array<u256>,
    i: u32,
    fiat_shamir: u256,
}

// ## Schwartz Zippel lemma for FQ12 operation commitment verification
// Taking an FQ12 as a polynomial of degree 11, product of polynomials can be used to verify the
// committed coefficients with Schwartz Zippel lemma.
// From https://hackmd.io/@feltroidprime/B1eyHHXNT,
// For A and B element of Fq12 represented as direct extensions,
// ```A(x) * B(x) = R(x) + Q(x) * P12(x)```
// where `R(x)` is a polynomial of degree 11 or less.
// ### Expanding this to include the whole bit operation inside the miller loop,
// 1. For non-zero `P`/`N` bits,
//   * Commitment contains 42 coefficients
//   * F ∈ Fq12, miller loop aggregation
//   * L1, L2, L3 ∈ Sparse01234, Loop step lines
//   * Witness ∈ Fq12, Residue witness (or it's inverse based on the bit value)
//   * ```F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) = R(x) + Q(x) * P12(x)```
// 2. For zero `O` bits,
//   * Commitment contains 64 coefficients
//   * F ∈ Fq12, miller loop aggregation
//   * L1_L2 ∈ Sparse01234, Loop step lines L1 and L2 multiplied for lower degree
//   * L3 ∈ Sparse034, // Last L3 line
//   * ```F(x) * F(x) * L1_L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
// 3. Final step,
//   * Commitment contains 42 coefficients
//   * F ∈ Fq12, miller loop aggregation
//   * L1, L2, L3 ∈ Sparse01234, Correction step lines
//   * ```F(x) * L1(x) * L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
#[generate_trait]
impl SchZipPolyCommitHandler of SchZipPolyCommitHandlerTrait {
    fn zero_bit(
        self: @SchZipCommitments, ref f: Fq12, i: u32, l1_l2: FS01234, l3: FS034, f_nz: NZ256
    ) {
        let c = self.coefficients;
        // let FS01234 { c0: Fq6 { c0: a0, c1: a1, c2: a2 }, c1: FS01 { c0: a3, c1: a4 } } = l1_l2;
        // let FS034 { c3: b3, c4: b4 } = l3;

        f =
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
            );
    }
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
        f =
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
            );
    }
    fn last_step(
        self: @SchZipCommitments,
        ref f: Fq12,
        i: u32,
        l1: FS01234,
        l2: FS01234,
        l3: FS01234,
        f_nz: NZ256
    ) {
        let c = self.coefficients;
        f =
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
            );
        f = direct_to_tower(f);
    }
}

pub impl SchZipPolyCommitImpl of SchZipSteps<SchZipCommitments> {
    #[inline(always)]
    fn sz_init(self: @SchZipCommitments, ref f: Fq12, f_nz: NZ256) { //
        // Convert Fq12 tower to direct polynomial representation
        assert(self.coefficients.len() == COEFFICIENTS_COUNT, 'wrong number of coefficients');
        f = tower_to_direct(f);
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
    // Convert Fq12 direct polynomial representation back to tower
    // f = direct_to_tower(f);
    }
}

pub fn schzip_verify_with_commitments<TLines, +StepLinesGet<TLines>, +Drop<TLines>>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    inputs: Array<u256>,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    cubic_scale: Fq6,
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
    let fiat_shamir: u256 = hasher.finalize().into();

    let schzip = SchZipCommitments { coefficients, i: 0, fiat_shamir };
    schzip_verify(
        pi_a, pi_b, pi_c, inputs, residue_witness, residue_witness_inv, cubic_scale, setup, schzip
    )
}
