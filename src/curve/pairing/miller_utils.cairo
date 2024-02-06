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
        let cx = -p.x.sqr().scale(-fq(3));
        // 2p.y
        let cy = p.y + p.y;
        // TODO return Fq12
        Fq12Utils::one()
    }

    /// The sloped line function for adding two points
    fn at_chord(self: AffineG1, p1: AffineG2, p2: AffineG2) -> Fq12 {
        let cx = p2.y - p1.y;
        let cy = p1.x - p2.x;
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

#[cfg(test)]
mod g1_line {
    use bn::curve::pairing::miller_utils::LineEvaluationsTrait;
    use bn::fields::{Fq12, fq12_, Fq12Utils};
    use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, fq12, Fq, Fq2, Fq6};
    use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps, g1, g2};

    fn p1() -> AffineG1 {
        g1(
            0x11977508bb36160bd6a61bb62df52e7600a4bc5a0501a0575886ec466d7f712f,
            0xedd11161c12eec80ced1a5febbe8ad53cbcbde12aaac2342fa2e085531556e
        )
    }

    fn p2() -> AffineG1 {
        g1(
            0x3d3925d9e7bae9575fdbff788b6f71af848c7f6086fdfb903bdb6f07a0cd01d,
            0x2c66218e5cb40fbddd2f00d016dae0504fe77a7b01d09adff80fd915e82b0920
        )
    }

    fn q() -> AffineG2 {
        g2(
            0x1b938e30eec254e7965da0d7340fae3634baeb73d68992c487e30ca87215b7ce,
            0xd85c8f6fbcc8bd7d31694fc26746708505143e30870d4f34ff73839a1248bc1,
            0x1acd84a5e6312363c601c942bf50ca2892e294a7ce9da09b87e4753eaf79449b,
            0x1d5142a309e9fb7920d2ef78285e9c8c4437b5dca886b3a90d4954cccf741ccb,
        )
    }

    fn cord_res() -> Fq12 {
        fq12(
            0x1f1eff6bc9b3365536da4297b029ae47cfafc7acce182e6990d1fc60dd6601ac,
            0,
            0x17f7d5c3a88b387da3cb0c2535b2cba2225a3dc4d23e808b323f382f600b055,
            0x24f6134b1e3d93de96c2ae1a053962479be5d184b34512e363138707311da84b,
            0,
            0,
            0,
            0,
            0xf0c605fc017ed82acf09ea938d715272ad2b3e40618b6fa68d6ff63509e0710,
            0x1256b9f15a9f0a1605f688395421740450365c4ed28dc40f3247cbaed5403fa1,
            0,
            0,
        )
    }
    fn tangent_res() -> Fq12 {
        fq12(
            0x2ee84c3cee85e157e7149a463c0769d08bf2e421f653a85856ad859b84aca7a8,
            0,
            0x21fbda2f418fdd300d2203f122c2bc17e17ccb34e29ae5c949ccd51deb06bba9,
            0x28671d3bee02ad0081f2c437704149ac70a312a28ddd449c86c38f82953aef85,
            0,
            0,
            0,
            0,
            0x2cdd77b45c7b5c6704e5fbc1c6fc35d41d7ec3b71ee7ceecbc22ef8e944c81f7,
            0x193ceb7899103f068db4603598043f43453592b27ca8e53f92191707cb5cbc73,
            0,
            0,
        )
    }

    #[test]
    #[available_gas(20000000)]
    fn tangent() {
        assert(q().at_tangent(p1()) == tangent_res(), 'incorrect tangent');
    }

    #[test]
    #[available_gas(20000000)]
    fn chord() {
        assert(q().at_chord(p1(), p2()) == cord_res(), 'incorrect cord');
    }
}
