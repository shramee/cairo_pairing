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

// https://eprint.iacr.org/2022/1162 (Section 6.1)
// computes acc = 2 * acc and line eval for p
// returns line evaluation to multiply with f
#[inline(always)]
fn step_add(
    ref acc: PtG2, p_precomp: @PPrecompute, p: PtG1, q: PtG2, field_nz: NonZero<u256>
) -> Fq12Sparse034 {
    // acc + q
    // acc = acc + (acc + q)
    // line function
    let s = acc;

    // λ = 3x²/2y
    let slope = s.chord(q);
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
) -> (Fq12Sparse034, Fq12Sparse034) {
    // Line 9: Q1 ← πₚ(Q),Q2 ← πₚ²(Q)

    // πₚ(x,y) = (xp,yp)
    // Q1 = π(Q)
    let Q1 = Affine {
        x: fq2_by_nonresidue_1p_2(q.x.conjugate()), //
        y: fq2_by_nonresidue_1p_3(q.y.conjugate()), //
    };

    // Q2 = -π²(Q)
    let Q2 = Affine {
        x: fq2_by_nonresidue_2p_2(q.x.conjugate()),
        y: fq2_by_nonresidue_2p_3(q.y.conjugate()).neg(),
    };

    // Line 10: if u < 0 then T ← −T,f ← fp6
    // skip line 10, ∵ x > 0

    // Line 11: d ← (gT,Q1)(P), T ← T + Q1, e ← (gT,−Q2)(P), T ← T − Q2

    // d ← (gT,Q1)(P), T ← T + Q1
    let d = step_add(ref acc, p_precomp, p, q, field_nz);

    // e ← (gT,−Q2)(P), T ← T − Q2
    // we can skip the T ← T − Q2 step coz we don't need the final point, just the line function
    let slope = acc.chord(Q2);
    let e = Fq12Sparse034 {
        c3: slope.scale(*p_precomp.x_over_y), c4: (slope * s.x - s.y).scale(*p_precomp.y_inv),
    };

    // f ← f·(d·e) is left for the caller

    // return line functions
    (d, e)
}

// For πₚ frobeneusmap
// Multiply by Fp2::NONRESIDUE^(2((q^1) - 1)/6)
fn fq2_by_nonresidue_1p_2(a: Fq2) -> Fq2 {
    a * fq2(pi::X2Q_1_C0, pi::X2Q_1_C1)
}

// For πₚ frobeneusmap
// Multiply by Fp2::NONRESIDUE^(3((q^1) - 1)/6)
fn fq2_by_nonresidue_1p_3(a: Fq2) -> Fq2 {
    a * fq2(pi::X3Q_1_C0, pi::X3Q_1_C1)
}

// For πₚ² frobeneusmap
// Multiply by Fp2::NONRESIDUE^(2(p^2-1)/6)
fn fq2_by_nonresidue_2p_2(a: Fq2) -> Fq2 {
    a.scale(fq(pi::X2Q_2_C0))
}

// For πₚ² frobeneusmap
// Multiply by Fp2::NONRESIDUE^(3(p^2-1)/6)
fn fq2_by_nonresidue_2p_3(a: Fq2) -> Fq2 {
    a.scale(fq(pi::X3Q_2_C0))
}
