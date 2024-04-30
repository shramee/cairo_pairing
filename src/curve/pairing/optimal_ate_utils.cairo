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
// * acc + acc
//
// Double and Add step:
// * acc + Q + acc (to save on extra steps in doubling vs adding)
// * Skip intermediate (Acc + Q) y calculation and substitute in final slope calculation
//
// Line evaluations
// ----------------
// Line evaluations use a D-type twist,
// gψₛ(P) = 1 − λ·xₚ/yₚ·w + (λxₛ − yₛ)/yₚ·w³
// Represented by a 034 sparse element in Fq12 over Fq2
// (1, 0, 0, -λ·xₚ/yₚ, (λxₛ − yₛ)/yₚ, 0)
// 

#[derive(Copy, Drop)]
struct PPrecompute {
    neg_x_over_y: Fq,
    y_inv: Fq,
}

fn pair_precompute(p: PtG1, q: PtG2, field_nz: NonZero<u256>) -> (PPrecompute, PtG2) {
    let neg_q = q.neg();
    let y_inv = (p.y).inv(field_nz);
    (PPrecompute { neg_x_over_y: -p.x * y_inv, y_inv }, neg_q,)
}

type PPre = PPrecompute;
type NZNum = NonZero<u256>;
type F034 = Fq12Sparse034;

#[derive(Copy, Drop, Serde)]
struct LineFn {
    slope: Fq2,
    c: Fq2,
}

mod line_fn {
    use bn::fields::fq_2::Fq2FrobeniusTrait;
    use bn::fields::fq_sparse::FqSparseTrait;
    use bn::traits::{FieldShortcuts, FieldUtils};
    use bn::curve::groups::ECOperations;
    use bn::curve::groups::{g1, g2, ECGroup};
    use bn::curve::groups::{Affine, AffineG1 as PtG1, AffineG2 as PtG2, AffineOps};
    use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
    use bn::fields::{
        Fq, fq, Fq2, fq2, Fq6, Fq12, Fq12Utils, Fq12Ops, FqOps, Fq2Utils, Fq2Ops,
        Fq12Exponentiation,
    };
    use bn::fields::{Fq12Sparse034, Fq12Sparse01234, FqSparse};
    use bn::fields::print::{Fq2Display, Fq12Display, FqDisplay};
    use bn::fields::frobenius::pi;
    use super::{LineFn, PPre, NZNum, F034};

    #[inline(always)]
    fn line_fn(slope: Fq2, s: PtG2) -> LineFn {
        LineFn { slope, c: slope * s.x - s.y, }
    }

    // For πₚ frobeneus map
    // Multiply by Fp2::NONRESIDUE^(2((q^1) - 1)/6)
    #[inline(always)]
    fn fq2_mul_nr_1p_2(a: Fq2) -> Fq2 {
        a * fq2(pi::Q1X2_C0, pi::Q1X2_C1)
    }

    // For πₚ frobeneus map
    // Multiply by Fp2::NONRESIDUE^(3((q^1) - 1)/6)
    #[inline(always)]
    fn fq2_mul_nr_1p_3(a: Fq2) -> Fq2 {
        a * fq2(pi::Q1X3_C0, pi::Q1X3_C1)
    }

    // For πₚ² frobeneus map
    // Multiply by Fp2::NONRESIDUE^(2(p^2-1)/6)
    #[inline(always)]
    fn fq2_mul_nr_2p_2(a: Fq2) -> Fq2 {
        a.scale(fq(pi::Q2X2_C0))
    }

    // For πₚ² frobeneus map
    // Multiply by Fp2::NONRESIDUE^(3(p^2-1)/6)
    #[inline(always)]
    fn fq2_mul_nr_2p_3(a: Fq2) -> Fq2 {
        a.scale(fq(pi::Q2X3_C0))
    }

    // https://eprint.iacr.org/2022/1162 (Section 6.1)
    // computes acc = acc + q + acc and line evals for p
    // returns product of line evaluations to multiply with f
    #[inline(always)]
    fn step_dbl_add(ref acc: PtG2, q: PtG2, field_nz: NZNum) -> (LineFn, LineFn) {
        let s = acc;
        // s + q
        let slope1 = s.chord(q);
        let x1 = s.x_on_slope(slope1, q.x);
        let line1 = line_fn(slope1, s);

        // we skip y1 calculation and sub slope1 directly in second slope calculation

        // s + (s + q)
        // λ2 = (y2-y1)/(x2-x1), subbing y2 = λ(x2-x1)+y1
        // λ2 = -λ1-2y1/(x3-x1)
        let slope2 = -slope1 - (s.y.u_add(s.y)) / (x1 - s.x);
        acc = s.pt_on_slope(slope2, x1);
        let line2 = line_fn(slope2, s);

        // line functions
        (line1, line2)
    }

    // https://eprint.iacr.org/2022/1162 (Section 6.1)
    // computes acc = 2 * acc and line eval for p
    // returns line evaluation to multiply with f
    #[inline(always)]
    fn step_double(ref acc: PtG2, field_nz: NZNum) -> LineFn {
        let s = acc;
        // λ = 3x²/2y
        let slope = s.tangent();
        // p = (λ²-2x, λ(x-xr)-y)
        acc = s.pt_on_slope(slope, acc.x);
        line_fn(slope, s)
    }
    // https://eprint.iacr.org/2022/1162 (Section 6.1)
    // computes acc = acc + q and line eval for p
    // returns line evaluation to multiply with f
    #[inline(always)]
    fn step_add(ref acc: PtG2, q: PtG2, field_nz: NZNum) -> LineFn {
        let s = acc;
        // λ = 3x²/2y
        let slope = s.chord(q);
        // p = (λ²-2x, λ(x-xr)-y)
        acc = s.pt_on_slope(slope, q.x);
        line_fn(slope, s)
    }

    // Realm of pairings, Algorithm 1, lines 8, 9, 10
    // https://eprint.iacr.org/2013/722.pdf
    // Code inspired by gnark
    // https://github.com/Consensys/gnark/blob/v0.9.1/std/algebra/emulated/sw_bn254/pairing.go#L529
    #[inline(always)]
    fn correction_step(ref acc: PtG2, q: PtG2, field_nz: NZNum) -> (LineFn, LineFn) {
        // Line 9: Q1 ← πₚ(Q),Q2 ← πₚ²(Q)
        // πₚ(x,y) = (xp,yp)
        // Q1 = π(Q)
        let q1 = Affine {
            x: fq2_mul_nr_1p_2(q.x.conjugate()), y: fq2_mul_nr_1p_3(q.y.conjugate()),
        };

        // Q2 = -π²(Q)
        let q2 = Affine { x: fq2_mul_nr_2p_2(q.x), y: fq2_mul_nr_2p_3(q.y).neg(), };

        // Line 10: if u < 0 then T ← −T, f ← fp6
        // skip line 10, ∵ x > 0

        // Line 11: d ← (gT,Q1)(P), T ← T + Q1, e ← (gT,−Q2)(P), T ← T − Q2

        // d ← (gT,Q1)(P), T ← T + Q1
        let d = step_add(ref acc, q1, field_nz);

        // e ← (gT,−Q2)(P), T ← T − Q2
        // we can skip the T ← T − Q2 step coz we don't need the final point, just the line function
        let slope = acc.chord(q2);
        let e = line_fn(slope, acc);

        // f ← f·(d·e) is left for the caller

        // return line functions
        (d, e)
    }
}

#[inline(always)]
fn line_fn_at_p(line: LineFn, p_pre: @PPre) -> F034 {
    F034 { c3: line.slope.scale(*p_pre.neg_x_over_y), c4: line.c.scale(*p_pre.y_inv), }
}

fn line_evaluation_at_p(slope: Fq2, p_pre: @PPre, s: PtG2) -> F034 {
    F034 { c3: slope.scale(*p_pre.neg_x_over_y), c4: (slope * s.x - s.y).scale(*p_pre.y_inv), }
}

#[inline(always)]
fn step_dbl_add_to_f(ref acc: PtG2, ref f: Fq12, p_pre: @PPre, p: PtG1, q: PtG2, field_nz: NZNum) {
    let (l1, l2) = step_dbl_add(ref acc, p_pre, p, q, field_nz);
    f = f.mul_01234(l1.mul_034_by_034(l2, field_nz), field_nz);
}

fn step_dbl_add(ref acc: PtG2, p_pre: @PPre, p: PtG1, q: PtG2, field_nz: NZNum) -> (F034, F034) {
    let (lf1, lf2) = line_fn::step_dbl_add(ref acc, q, field_nz);
    (line_fn_at_p(lf1, p_pre,), line_fn_at_p(lf2, p_pre,))
}

#[inline(always)]
fn step_double_to_f(ref acc: PtG2, ref f: Fq12, p_pre: @PPre, p: PtG1, field_nz: NZNum) {
    f = f.mul_034(step_double(ref acc, p_pre, p, field_nz), field_nz);
}

fn step_double(ref acc: PtG2, p_pre: @PPre, p: PtG1, field_nz: NZNum) -> F034 {
    let lf = line_fn::step_double(ref acc, field_nz);
    line_fn_at_p(lf, p_pre)
}

#[inline(always)]
fn step_add(ref acc: PtG2, p_pre: @PPre, p: PtG1, q: PtG2, field_nz: NZNum) -> F034 {
    let lf = line_fn::step_add(ref acc, q, field_nz);
    line_fn_at_p(lf, p_pre)
}

#[inline(always)]
fn correction_step_to_f(
    ref acc: PtG2, ref f: Fq12, p_pre: @PPre, p: PtG1, q: PtG2, field_nz: NZNum
) {
    // Realm of pairings, Algorithm 1, lines 10 mul into f
    // f ← f·(d·e)
    let (l1, l2) = correction_step(ref acc, p_pre, p, q, field_nz);
    f = f.mul_01234(l1.mul_034_by_034(l2, field_nz), field_nz);
}

fn correction_step(ref acc: PtG2, p_pre: @PPre, p: PtG1, q: PtG2, field_nz: NZNum) -> (F034, F034) {
    let (lf1, lf2) = line_fn::correction_step(ref acc, q, field_nz);
    (line_fn_at_p(lf1, p_pre,), line_fn_at_p(lf2, p_pre,))
}
