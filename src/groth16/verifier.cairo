use bn::fields::fq_sparse::FqSparseTrait;
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::{pairing, get_field_nz};
use bn::traits::{MillerPrecompute, MillerSteps};
use pairing::optimal_ate::{ate_miller_loop_steps};
use pairing::optimal_ate_utils::{p_precompute, step_double, step_dbl_add, correction_step};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{ICProcess, process_input_constraints};

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

impl Groth16MillerSteps of MillerSteps<Groth16PreCompute, Groth16MillerG2> {
    fn miller_first_second(
        self: @Groth16PreCompute, i1: u32, i2: u32, ref acc: Groth16MillerG2
    ) -> Fq12 { //
        let (pi_a_ppc, pi_c_ppc, k_ppc) = self.ppc;
        let field_nz = *self.field_nz;
        // Handle O, N steps
        // step 0, run step double
        let l1 = step_double(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, field_nz);
        let l2 = step_double(ref acc.delta, pi_c_ppc, *self.p.pi_c, field_nz);
        let l3 = step_double(ref acc.gamma, k_ppc, *self.p.k, field_nz);
        let f = l1.mul_034_by_034(l2, field_nz).mul_01234_034(l3, field_nz);
        // sqr with mul 034 by 034
        let f = f.sqr();
        // step -1, the next negative one step
        let Groth16MillerG2 { pi_b, delta, gamma } = self.neg_q;
        let (pi_a_ppc, pi_c_ppc, k_ppc) = self.ppc;
        let (l1_1, l1_2) = step_dbl_add(ref acc.pi_b, pi_a_ppc, *self.p.pi_a, *pi_b, field_nz);
        let l1 = l1_1.mul_034_by_034(l1_2, field_nz);
        let (l2_1, l2_2) = step_dbl_add(ref acc.delta, pi_c_ppc, *self.p.pi_c, *delta, field_nz);
        let l2 = l2_1.mul_034_by_034(l2_2, field_nz);
        let (l3_1, l3_2) = step_dbl_add(ref acc.gamma, k_ppc, *self.p.k, *gamma, field_nz);
        let l3 = l3_1.mul_034_by_034(l3_2, field_nz);
        f.mul(l1.mul_01234_01234(l2, field_nz).mul_01234(l3, field_nz))
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
        let Groth16PreCompute { p, q, ppc: _, neg_q: _, field_nz, } = self;
        let (pi_a_ppc, pi_c_ppc, k_ppc) = self.ppc;
        let (l1_1, l1_2) = correction_step(ref acc.pi_b, pi_a_ppc, *p.pi_a, *q.pi_b, *field_nz);
        let l1 = l1_1.mul_034_by_034(l1_2, *field_nz);
        let (l2_1, l2_2) = correction_step(ref acc.delta, pi_c_ppc, *p.pi_c, *q.delta, *field_nz);
        let l2 = l2_1.mul_034_by_034(l2_2, *field_nz);
        let (l3_1, l3_2) = correction_step(ref acc.gamma, k_ppc, *p.k, *q.gamma, *field_nz);
        let l3 = l3_1.mul_034_by_034(l3_2, *field_nz);

        f = f.mul(l1.mul_01234_01234(l2, *field_nz).mul_01234(l3, *field_nz));
    }
}

// Does verification
fn verify<T, +ICProcess<T>, +Drop<T>>(
    pi_a: AffineG1,
    pi_b: AffineG2,
    pi_c: AffineG1,
    ic_0: AffineG1,
    inputs_and_ic: T,
    albe_miller: Fq12,
    delta: AffineG2,
    gamma: AffineG2,
) -> bool { //
    // Compute k from ic and public_inputs
    let k = process_input_constraints(ic_0, inputs_and_ic);

    // Compute optimise triple miller loop for the points
    let pi_a = pi_a.neg();

    // build precompute
    let field_nz = get_field_nz();
    let q = Groth16MillerG2 { pi_b, delta, gamma, };
    let neg_q = Groth16MillerG2 { pi_b: pi_b.neg(), delta: delta.neg(), gamma: gamma.neg(), };
    let ppc = (
        p_precompute(pi_a, field_nz), p_precompute(pi_c, field_nz), p_precompute(k, field_nz)
    );
    let precomp = Groth16PreCompute {
        p: Groth16MillerG1 { pi_a: pi_a, pi_c, k, }, q, ppc, neg_q, field_nz,
    };

    // q points accumulator
    let mut acc = q;
    // run miller steps
    let miller_loop_result = ate_miller_loop_steps(precomp, ref acc);

    // multiply precomputed alphabeta_miller with the pairings
    let miller_loop_result = miller_loop_result * albe_miller;

    // final exponentiation
    let result = miller_loop_result.final_exponentiation();

    // return result == 1
    result == Fq12Utils::one()
}
