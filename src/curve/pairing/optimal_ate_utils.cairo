use bn::fields::fq_2::Fq2FrobeniusTrait;
use bn::fields::fq_sparse::FqSparseTrait;
use bn::traits::{FieldShortcuts, FieldUtils};
use bn::curve::groups::ECOperations;
use bn::curve::groups::{g1, g2, ECGroup};
use bn::curve::groups::{Affine, AffineG1 as PtG1, AffineG2 as PtG2, AffineOps};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{
    Fq, fq, Fq2, fq2, Fq6, Fq12, Fq12Utils, Fq12Ops, FqOps, Fq2Utils, Fq2Ops, Fq12Exponentiation,
};
use bn::fields::{Fq12Sparse034, Fq12Sparse01234, FqSparse};
use bn::fields::print::{Fq2Display, Fq12Display, FqDisplay};
use bn::fields::frobenius::pi;

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
struct PPrecompute {
    x_over_y: Fq,
    y_inv: Fq,
}

fn step_dbl_add_to_f(
    ref acc: PtG2, ref f: Fq12, p_precomp: @PPrecompute, p: PtG1, q: PtG2, field_nz: NonZero<u256>
) {
    let (l1, l2) = step_dbl_add(ref acc, p_precomp, p, q, field_nz);
    f = f.mul_034(l1, field_nz);
    f = f.mul_034(l2, field_nz);
}

// https://eprint.iacr.org/2022/1162 (Section 6.1)
// computes acc = acc + q + acc and line evals for p
// returns product of line evaluations to multiply with f
#[inline(always)]
fn step_dbl_add(
    ref acc: PtG2, p_precomp: @PPrecompute, p: PtG1, q: PtG2, field_nz: NonZero<u256>
) -> (Fq12Sparse034, Fq12Sparse034) {
    let s = acc;
    // s + q
    let slope1 = s.chord(q);
    let x1 = s.x_on_slope(slope1, q.x);
    let line1 = Fq12Sparse034 {
        c3: slope1.scale(*p_precomp.x_over_y), c4: (slope1 * s.x - s.y).scale(*p_precomp.y_inv),
    };
    // we skip y1 calculation and sub slope1 directly in second slope calculation

    // s + (s + q)
    let slope2 = -slope1 - (s.y.u_add(s.y)) / (x1 - s.x);
    acc = s.pt_on_slope(slope2, x1);
    let line2 = Fq12Sparse034 {
        c3: slope2.scale(*p_precomp.x_over_y), c4: (slope2 * s.x - s.y).scale(*p_precomp.y_inv),
    };

    // line functions
    (line1, line2)
}

fn step_double_to_f(
    ref acc: PtG2, ref f: Fq12, p_precomp: @PPrecompute, p: PtG1, field_nz: NonZero<u256>
) {
    f = f.mul_034(step_double(ref acc, p_precomp, p, field_nz), field_nz);
}

// https://eprint.iacr.org/2022/1162 (Section 6.1)
// computes acc = 2 * acc and line eval for p
// returns line evaluation to multiply with f
#[inline(always)]
fn step_double(
    ref acc: PtG2, p_precomp: @PPrecompute, p: PtG1, field_nz: NonZero<u256>
) -> Fq12Sparse034 {
    // acc + q
    // acc = acc + (acc + q)
    // line function
    let s = acc;

    // λ = 3x²/2y
    let slope = s.tangent();
    // p = (λ²-2x, λ(x-xr)-y)
    acc = s.pt_on_slope(slope, acc.x);
    Fq12Sparse034 {
        c3: slope.scale(*p_precomp.x_over_y), c4: (slope * s.x - s.y).scale(*p_precomp.y_inv),
    }
}
// https://github.com/mratsim/constantine/blob/976c8bb215a3f0b21ce3d05f894eb506072a6285/constantine/math/isogenies/frobenius.nim#L109

fn fq2_by_nonresidue_1p_2(a: Fq2) -> Fq2 {
    a * fq2(pi::X2Q_1_C0, pi::X2Q_1_C1)
}
fn fq2_by_nonresidue_1p_3(a: Fq2) -> Fq2 {
    a * fq2(pi::X3Q_1_C0, pi::X3Q_1_C1)
}
fn fq2_by_nonresidue_2p_2(a: Fq2) -> Fq2 {
    a.scale(fq(pi::X2Q_2_C0))
}
fn fq2_by_nonresidue_2p_3(a: Fq2) -> Fq2 {
    a.scale(fq(pi::X3Q_2_C0))
}
