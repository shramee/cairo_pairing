use core::debug::PrintTrait;
use bn::fields::{Fq12, fq12_, Fq12Utils};
use bn::curve::{g1, g2};
use bn::traits::ECOperations;
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};

/// The sloped line function for doubling a point
fn tangent(p: g1::AffineG1, q: g2::AffineG2) -> Fq12 {
    let cx = -fq(3) * p.x * p.x;
    let cy = fq(2) * p.y;
    sparse_fq12(p.y * p.y - fq(9), q.x.scale(cx), q.y.scale(cy))
}

/// The sloped line function for adding two points
fn chord(p1: g1::AffineG1, p2: g1::AffineG1, q: g2::AffineG2) -> Fq12 {
    let cx = p2.y - p1.y;
    let cy = p1.x - p2.x;
    sparse_fq12(p1.y * p2.x - p2.y * p1.x, q.x.scale(cx), q.y.scale(cy))
}

/// The tangent and cord functions output sparse Fp12 elements.
/// This map embeds the nonzero coefficients into an Fp12.
fn sparse_fq12(g000: Fq, g01: Fq2, g11: Fq2) -> Fq12 {
    Fq12 {
        c0: Fq6 { c0: Fq2 { c0: g000, c1: FieldUtils::zero(), }, c1: g01, c2: FieldUtils::zero(), },
        c1: Fq6 { c0: FieldUtils::zero(), c1: g11, c2: FieldUtils::zero(), }
    }
}
