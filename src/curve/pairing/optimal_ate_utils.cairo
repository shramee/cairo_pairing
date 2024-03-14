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


fn correction_step_to_f(
    ref acc: PtG2, ref f: Fq12, p_precomp: @PPrecompute, p: PtG1, q: PtG2, field_nz: NonZero<u256>
) {
    // @TODO incorporate results into f
    let _ = correction_step(ref acc, p_precomp, p, q, field_nz);
}

// Realm of pairings, Algorithm 1, lines 8, 9, 10
// https://eprint.iacr.org/2013/722.pdf
// Code referenced from gnark
// https://github.com/Consensys/gnark/blob/v0.9.1/std/algebra/emulated/sw_bn254/pairing.go#L529
#[inline(always)]
fn correction_step(
    ref acc: PtG2, p_precomp: @PPrecompute, p: PtG1, q: PtG2, field_nz: NonZero<u256>
) {
    // Line 9: Q1 ← πₚ(Q),Q2 ← πₚ²(Q)

    // πₚ(x,y) = (xp,yp)
    //Q1 = π(Q)
    // Q1.X = *pr.Ext12.Ext2.Conjugate(&Q[k].X)
    // Q1.X = *pr.Ext12.Ext2.MulByNonResidue1Power2(&Q1.X)
    // Q1.Y = *pr.Ext12.Ext2.Conjugate(&Q[k].Y)
    // Q1.Y = *pr.Ext12.Ext2.MulByNonResidue1Power3(&Q1.Y)
    // Q2 = -π²(Q)
    // Q2.X = *pr.Ext12.Ext2.MulByNonResidue2Power2(&Q[k].X)
    // Q2.Y = *pr.Ext12.Ext2.MulByNonResidue2Power3(&Q[k].Y)
    // Q2.Y = *pr.Ext12.Ext2.Neg(&Q2.Y)
// Line 10: if u < 0 then T ← −T,f ← fp6
// skip line 10, ∵ x > 0

// Line 11: d ← (gT,Q1)(P), T ← T + Q1, e ← (gT,−Q2)(P), T ← T − Q2, f ← f·(d·e)

// // Qacc[k] ← Qacc[k]+π(Q) and
// // l1 the line passing Qacc[k] and π(Q)
// Qacc[k], l1 = pr.addStep(Qacc[k], Q1)

// // line evaluation at P[k]
// l1.R0 = *pr.Ext2.MulByElement(&l1.R0, xOverY[k])
// l1.R1 = *pr.Ext2.MulByElement(&l1.R1, yInv[k])

// // l2 the line passing Qacc[k] and -π²(Q)
// l2 = pr.lineCompute(Qacc[k], Q2)
// // line evaluation at P[k]
// l2.R0 = *pr.MulByElement(&l2.R0, xOverY[k])
// l2.R1 = *pr.MulByElement(&l2.R1, yInv[k])

// // ℓ × ℓ
// prodLines = *pr.Mul034By034(&l1.R0, &l1.R1, &l2.R0, &l2.R1)
// // (ℓ × ℓ) × res
// res = pr.MulBy01234(res, &prodLines)
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
