use core::debug::PrintTrait;
use bn::fields::{Fq12, fq12_, Fq12Utils};
use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};

trait LineEvaluationsTrait<P1, P2> {
    /// The sloped line function for doubling a point
    fn at_tangent(self: P1, p: P2) -> Fq12;
    /// The sloped line function for adding two points
    fn at_chord(self: P1, p1: P2, p2: P2) -> Fq12;
}

impl G2LineEvals of LineEvaluationsTrait<AffineG2, AffineG1> {
    /// The sloped line function for doubling a point
    #[inline(always)]
    fn at_tangent(self: AffineG2, p: AffineG1) -> Fq12 {
        // -3px^2
        let cx = -fq(3) * p.x.sqr();
        // 2p.y
        let cy = p.y + p.y;
        sparse_fq12(p.y * p.y - fq(9), self.x.scale(cx), self.y.scale(cy))
    }

    /// The sloped line function for adding two points
    #[inline(always)]
    fn at_chord(self: AffineG2, p1: AffineG1, p2: AffineG1) -> Fq12 {
        let cx = p2.y - p1.y;
        let cy = p1.x - p2.x;
        sparse_fq12(p1.y * p2.x - p2.y * p1.x, self.x.scale(cx), self.y.scale(cy))
    }
}

impl G1LineEvals of LineEvaluationsTrait<AffineG1, AffineG2> {
    /// The sloped line function for doubling a point
    fn at_tangent(self: AffineG1, p: AffineG2) -> Fq12 {
        // -3px^2
        let _cx = -p.x.sqr().scale(-fq(3));
        // 2p.y
        let _cy = p.y + p.y;
        // TODO return Fq12
        Fq12Utils::one()
    }

    /// The sloped line function for adding two points
    fn at_chord(self: AffineG1, p1: AffineG2, p2: AffineG2) -> Fq12 {
        let _cx = p2.y - p1.y;
        let _cy = p1.x - p2.x;
        // TODO return Fq12
        Fq12Utils::one()
    }
}

/// The tangent and cord functions output sparse Fp12 elements.
/// This map embeds the nonzero coefficients into an Fp12.
fn sparse_fq12(g000: Fq, g01: Fq2, g11: Fq2) -> Fq12 {
    Fq12 {
        c0: Fq6 { c0: Fq2 { c0: g000, c1: FieldUtils::zero(), }, c1: g01, c2: FieldUtils::zero(), },
        c1: Fq6 { c0: FieldUtils::zero(), c1: g11, c2: FieldUtils::zero(), }
    }
}
