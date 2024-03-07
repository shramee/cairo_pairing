use bn::traits::{FieldShortcuts, FieldUtils};
use bn::curve::groups::ECOperations;
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{
    Fq, Fq2, Fq12, Fq12Utils, Fq12Ops, FqOps, Fq2Utils, Fq2Ops, Fq12Expo, Fq12Sparse034,
    Fq12Sparse01234
};
use bn::curve::groups::{g1, g2, ECGroup};
use bn::curve::groups::{Affine, AffineG1 as PtG1, AffineG2 as PtG2, AffineOps};
use bn::traits::MillerEngine;

// This implementation follows the paper at https://eprint.iacr.org/2022/1162
// Pairings in Rank-1 Constraint Systems, Youssef El Housni et al.
// Section 6.1 Miller loop
// 
// Parts about miller steps implementations and line function evaluations
//
// Miller steps
// ------------
//
// Double step:
// * Acc + ACC
//
// Double and Add step:
// * Acc + Q + ACC (to save on extra steps in doubling vs adding)
// * Skip intermediate (Acc + Q) y calculation and substitute in final slope calculation
//
// Line evaluations
// ----------------
//
// 

#[derive(Copy, Drop)]
struct LineEvalPrecompute {
    x_over_y: Fq,
    y_inv: Fq,
}

#[derive(Copy, Drop)]
struct PreCompute {
    p: LineEvalPrecompute,
    neg_q: PtG2,
}

type Pair = (PtG1, PtG2);

impl SinglePairMiller of MillerEngine<Pair, PreCompute, PtG2, Fq12> {
    fn precompute_and_acc(self: @Pair, field_nz: NonZero<u256>) -> (PreCompute, PtG2) {
        let (p, q) = self;
        let neg_q = PtG2 { x: *q.x, y: -*q.y, };
        let y_inv = (*p.y).inv(field_nz);
        let precomp = PreCompute { p: LineEvalPrecompute { x_over_y: *p.x * y_inv, y_inv }, neg_q };
        (precomp, q.clone(),)
    }
    // 0 bit
    fn miller_bit_o(
        self: @Pair, pre_comp: @PreCompute, ref acc: PtG2, ref f: Fq12, field_nz: NonZero<u256>
    ) {
        let (p, _) = self;
        step_double(ref acc, pre_comp, *p);
    }
    // 1 bit
    fn miller_bit_p(
        self: @Pair, pre_comp: @PreCompute, ref acc: PtG2, ref f: Fq12, field_nz: NonZero<u256>
    ) {
        let (p, q) = self;
        let _line = step_double_and_add(ref acc, pre_comp, *q, *p);
    }
    // -1 bit
    fn miller_bit_n(
        self: @Pair, pre_comp: @PreCompute, ref acc: PtG2, ref f: Fq12, field_nz: NonZero<u256>
    ) {
        let (p, _) = self;
        // use neg q
        let _line = step_double_and_add(ref acc, pre_comp, *pre_comp.neg_q, *p);
    }
}

// https://eprint.iacr.org/2022/1162 (Section 6.1)
// computes acc = acc + q + acc and line eval for p
// returns product of line evaluations to multiply with f
fn step_double_and_add(ref acc: PtG2, precomp: @PreCompute, q: PtG2, p: PtG1) -> Fq12Sparse01234 {
    // acc + q
    // acc = acc + (acc + q)
    // line function
    let s = acc;
    Fq12Sparse01234 {
        c0: FieldUtils::one(),
        c1: FieldUtils::one(),
        c2: FieldUtils::one(),
        c3: FieldUtils::one(),
        c4: FieldUtils::one()
    }
}


// https://eprint.iacr.org/2022/1162 (Section 6.1)
// computes acc = 2 * acc and line eval for p
// returns line evaluation to multiply with f
fn step_double(ref acc: PtG2, precomp: @PreCompute, p: PtG1) -> Fq12Sparse034 {
    // acc + q
    // acc = acc + (acc + q)
    // line function
    let s = acc;

    // λ = 3x²/2y
    let slope = s.tangent();
    // p = (λ²-2x, λ(x-xr)-y)
    acc = s.pt_on_slope(slope, acc.x);
    Fq12Sparse034 {
        c3: slope.scale(*precomp.p.x_over_y), c4: (slope * s.x - s.y).scale(*precomp.p.y_inv),
    }
}
