use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use bn::traits::{MillerPrecompute, MillerSteps};
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_utils::{pair_precompute,};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{process_input_constraints};

#[derive(Copy, Drop)]
struct Groth16MillerG1 { // Points in G1
    pi_a: AffineG1,
    pi_c: AffineG1,
    k: AffineG1,
}

#[derive(Copy, Drop)]
struct Groth16MillerG2 { // Points in G2
    pi_b: AffineG2,
    delta: AffineG2,
    gamma: AffineG2,
}

#[derive(Copy, Drop)]
struct Groth16PreCompute {
    p: Groth16MillerG1,
    q: Groth16MillerG2,
    ppc: (PPrecompute, PPrecompute, PPrecompute),
    neg_q: Groth16MillerG2,
    field_nz: NonZero<u256>,
}

impl Groth16MillerPrecompute of MillerPrecompute<
    Groth16MillerG1, Groth16MillerG2, Groth16PreCompute
> {
    fn precompute(
        self: (Groth16MillerG1, Groth16MillerG2), field_nz: NonZero<u256>
    ) -> (Groth16PreCompute, Groth16MillerG2) {
        let (p, q) = self;
        let Groth16MillerG1 { pi_a, pi_c, k } = p;
        let Groth16MillerG2 { pi_b, delta, gamma } = q;

        let (ppc0, pi_b_neg) = pair_precompute(pi_a, pi_b, field_nz);
        let (ppc1, delta_neg) = pair_precompute(pi_c, delta, field_nz);
        let (ppc2, gamma_neg) = pair_precompute(k, gamma, field_nz);
        let ppc = (ppc0, ppc1, ppc2);
        let neg_q = Groth16MillerG2 { pi_b: pi_b_neg, delta: delta_neg, gamma: gamma_neg, };
        let precomp = Groth16PreCompute { p, q, ppc, neg_q, field_nz, };
        (precomp, q.clone(),)
    }
}

impl Groth16MillerSteps of MillerSteps<Groth16PreCompute, Groth16MillerG2> {
    fn miller_first_second(
        self: @Groth16PreCompute, i1: u32, i2: u32, ref acc: Groth16MillerG2
    ) -> Fq12 { //
    }

    // 0 bit
    fn miller_bit_o(self: @Groth16PreCompute, i: u32, ref acc: Groth16MillerG2, ref f: Fq12) {
        let (pi_a_ppc, pi_c_ppc, k_ppc) = self.ppc;
        let l1 = step_double(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, *self.field_nz);
        let l2 = step_double(ref acc.delta, pi_c_ppc, *self.p.pi_c, *self.field_nz);
        let l3 = step_double(ref acc.gamma, k_ppc, *self.p.k, *self.field_nz);
        f = f.mul(l1.mul_034_by_034(l2, *self.field_nz).mul_01234_034(l3, *self.field_nz));
    }

    // 1 bit
    fn miller_bit_p(self: @Groth16PreCompute, i: u32, ref acc: Groth16MillerG2, ref f: Fq12) {
        let Groth16MillerG2 { pi_b, delta, gamma } = self.q;
        let field_nz = *self.field_nz;
        let (pi_a_ppc, pi_c_ppc, k_ppc) = self.ppc;
        let (l1_1, l1_2) = step_dbl_add(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, field_nz);
        let l1 = l1_1.mul_034_by_034(l1_2, field_nz);
        let (l2_1, l2_2) = step_dbl_add(ref acc.delta, pi_c_ppc, *self.p.pi_c, *delta, field_nz);
        let l2 = l2_1.mul_034_by_034(l2_2, field_nz);
        let (l3_1, l3_2) = step_dbl_add(ref acc.gamma, k_ppc, *self.p.k, *gamma, field_nz);
        let l3 = l3_1.mul_034_by_034(l3_2, field_nz);
        f = f.mul(l1.mul_01234_01234(l2, field_nz).mul_01234(l3, field_nz));
    }

    // -1 bit
    fn miller_bit_n(self: @Groth16PreCompute, i: u32, ref acc: Groth16MillerG2, ref f: Fq12) {
        // use neg q
        let Groth16MillerG2 { pi_b, delta, gamma } = self.neg_q;
        let field_nz = *self.field_nz;
        let (pi_a_ppc, pi_c_ppc, k_ppc) = self.ppc;
        let (l1_1, l1_2) = step_dbl_add(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, field_nz);
        let l1 = l1_1.mul_034_by_034(l1_2, field_nz);
        let (l2_1, l2_2) = step_dbl_add(ref acc.delta, pi_c_ppc, *self.p.pi_c, *delta, field_nz);
        let l2 = l2_1.mul_034_by_034(l2_2, field_nz);
        let (l3_1, l3_2) = step_dbl_add(ref acc.gamma, k_ppc, *self.p.k, *gamma, field_nz);
        let l3 = l3_1.mul_034_by_034(l3_2, field_nz);
        f = f.mul(l1.mul_01234_01234(l2, field_nz).mul_01234(l3, field_nz));
    }

    // last step
    fn miller_last(self: @Groth16PreCompute, ref acc: Groth16MillerG2, ref f: Fq12) {
    }
}

// Does verification
fn verify() { //
// Compute k from ic and public_inputs
// Compute optimise triple miller loop for the points
// multiply precomputed alphabeta_miller with the pairings
// final exponentiation
// return result == 1
}
