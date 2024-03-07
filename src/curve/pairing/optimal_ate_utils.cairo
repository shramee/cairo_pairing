use bn::traits::{FieldShortcuts, FieldUtils};
use bn::curve::groups::ECOperations;
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq, Fq2, Fq12, Fq12Utils, Fq12Ops, FqOps, Fq2Utils, Fq2Ops};
use bn::curve::groups::{g1, g2, ECGroup};
use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps};
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
struct PreCompute {
    xOverY: Fq,
    yInv: Fq,
    negQ: AffineG2,
}

type Pair = (AffineG1, AffineG2);

impl SinglePairMiller of MillerEngine<Pair, PreCompute, AffineG2, Fq12> {
    fn precompute_and_acc(self: @Pair, field_nz: NonZero<u256>) -> (PreCompute, AffineG2) {
        let (p, q) = self;
        let yInv = (*p.y).inv(field_nz);
        let negQ = AffineG2 { x: *q.x, y: -*q.y, };
        let precomp = PreCompute { xOverY: *p.x * yInv, yInv, negQ };
        (precomp, q.clone(),)
    }
    // 0 bit
    fn miller_bit_o(
        self: @Pair, pre_comp: @PreCompute, ref acc: AffineG2, ref f: Fq12, field_nz: NonZero<u256>
    ) {
        let (p, _) = self;
        step_double(ref acc, pre_comp, *p);
    }
    // 1 bit
    fn miller_bit_p(
        self: @Pair, pre_comp: @PreCompute, ref acc: AffineG2, ref f: Fq12, field_nz: NonZero<u256>
    ) {
        let (p, q) = self;
        let _line = step_double_and_add(ref acc, pre_comp, *q, *p);
    }
    // -1 bit
    fn miller_bit_n(
        self: @Pair, pre_comp: @PreCompute, ref acc: AffineG2, ref f: Fq12, field_nz: NonZero<u256>
    ) {
        let (p, _) = self;
        // use neg q
        let _line = step_double_and_add(ref acc, pre_comp, *pre_comp.neg_q, *p);
    }
}

// https://eprint.iacr.org/2022/1162 (Section 6.1)
// computes acc = acc + q + acc and line eval for p
// returns product of line evaluations to multiply with f
fn step_double_and_add(ref acc: AffineG2, precomp: @PreCompute, q: AffineG2, p: AffineG1) {
    // acc + q
    // acc = acc + (acc + q)
    // line function
    let s = acc;
}


// https://eprint.iacr.org/2022/1162 (Section 6.1)
// computes acc = 2 * acc and line eval for p
// returns line evaluation to multiply with f
fn step_double(ref acc: AffineG2, precomp: @PreCompute, p: AffineG1) {
    // acc + q
    // acc = acc + (acc + q)
    // line function
    let s = acc;
}
