use bn::fields::fq_sparse::FqSparseTrait;
use bn::traits::{FieldShortcuts, FieldUtils};
use bn::curve::groups::ECOperations;
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{
    Fq, Fq2, fq2, Fq6, Fq12, Fq12Utils, Fq12Ops, FqOps, Fq2Utils, Fq2Ops, Fq12Exponentiation,
};
use bn::fields::{Fq12Sparse034, Fq12Sparse01234, FqSparse};
use bn::fields::print::{Fq2Display, Fq12Display, FqDisplay};
use bn::curve::groups::{g1, g2, ECGroup};
use bn::curve::groups::{Affine, AffineG1 as PtG1, AffineG2 as PtG2, AffineOps};
use bn::traits::{MillerPrecompute, MillerSteps};
use bn::curve::pairing::optimal_ate_utils::{
    PPrecompute, p_precompute, step_dbl_add_to_f, step_dbl_add, step_double_to_f, step_double,
    correction_step_to_f
};

#[derive(Copy, Drop)]
struct PreCompute {
    p: PtG1,
    q: PtG2,
    neg_q: PtG2,
    ppc: PPrecompute,
    field_nz: NonZero<u256>,
}

impl SingleMillerPrecompute of MillerPrecompute<PtG1, PtG2, PreCompute> {
    fn precompute(self: (PtG1, PtG2), field_nz: NonZero<u256>) -> (PreCompute, PtG2) {
        let (p, q) = self;
        let ppc = p_precompute(p, field_nz);
        let precomp = PreCompute { ppc, neg_q: q.neg(), field_nz, p, q, };
        (precomp, q.clone(),)
    }
}

impl SingleMillerSteps of MillerSteps<PreCompute, PtG2, Fq12> {
    #[inline(always)]
    fn sqr_target(self: @PreCompute, i: u32, ref acc: PtG2, ref f: Fq12) {
        f = f.sqr();
    }

    fn miller_first_second(self: @PreCompute, i1: u32, i2: u32, ref acc: PtG2) -> Fq12 {
        // Handle O, N steps
        // step 0, run step double
        let l0 = step_double(ref acc, self.ppc, *self.p, *self.field_nz);
        // sqr with mul 034 by 034
        let f_01234 = l0.sqr_034(*self.field_nz);
        // step -1, the next negative one step
        let (l1, l2) = step_dbl_add(ref acc, self.ppc, *self.p, *self.neg_q, *self.field_nz);
        // let f = f_01234.mul_01234_034(l1, *self.field_nz);
        // f.mul_034(l2, *self.field_nz)
        f_01234.mul_01234_01234(l1.mul_034_by_034(l2, *self.field_nz), *self.field_nz)
    }

    // 0 bit
    fn miller_bit_o(self: @PreCompute, i: u32, ref acc: PtG2, ref f: Fq12) {
        step_double_to_f(ref acc, ref f, self.ppc, *self.p, *self.field_nz);
    }

    // 1 bit
    fn miller_bit_p(self: @PreCompute, i: u32, ref acc: PtG2, ref f: Fq12) {
        step_dbl_add_to_f(ref acc, ref f, self.ppc, *self.p, *self.q, *self.field_nz);
    }

    // -1 bit
    fn miller_bit_n(self: @PreCompute, i: u32, ref acc: PtG2, ref f: Fq12) {
        // use neg q
        step_dbl_add_to_f(ref acc, ref f, self.ppc, *self.p, *self.neg_q, *self.field_nz);
    }

    // last step
    fn miller_last(self: @PreCompute, ref acc: PtG2, ref f: Fq12) {
        correction_step_to_f(ref acc, ref f, self.ppc, *self.p, *self.q, *self.field_nz);
    }
}
