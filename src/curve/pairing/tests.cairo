use core::debug::PrintTrait;
use bn::fields::{Fq12, Fq12Utils};
use bn::curve::{groups, FIELD};
use groups::{AffineG1, AffineG2, AffineG1Impl, AffineG2Impl, g1, g2};
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq12, Fq, Fq6};
use bn::pairing::tate_bkls::{tate_miller_loop, tate_pairing};

fn dbl_g2() -> AffineG2 {
    g2(
        18029695676650738226693292988307914797657423701064905010927197838374790804409,
        14583779054894525174450323658765874724019480979794335525732096752006891875705,
        2140229616977736810657479771656733941598412651537078903776637920509952744750,
        11474861747383700316476719153975578001603231366361248090558603872215261634898,
    )
}
fn dbl_g1() -> AffineG1 {
    g1(
        1368015179489954701390400359078579693043519447331113978918064868415326638035,
        9918110051302171585080402603319702774565515993150576347155970296011118125764,
    )
}

fn pair_result() -> Fq12 {
    fq12(
        0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
        0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
        0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
        0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
        0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
        0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
        0x2da44e38ec26bde1ad31495943114856dd885beb7889c590079bb300bb6ec023,
        0x1c40f4619c21dbd91ba610a8943188e35402e587a071361f60288e7e96fa33b,
        0x9ebfb41a99f28109afed1112aab3c8ab4ff6dd90097e880669c960f11106b52,
        0x2d0c275838257edb77665b9aafbbd40626b6a35fe12b4ccacee5613bf3408fc2,
        0x289d6d934bc5994e10f4dc4bfe3a5ac9cddfce66ee76df1e751b064bfdb5533d,
        0x1e18e64906693e6f4c9cd40273060c504a78843d903489abb13377666679d33f,
    )
}

#[test]
#[available_gas(99999999999999)]
fn miller() {
    let pair12 = tate_miller_loop(AffineG1Impl::one(), dbl_g2());
    assert(pair12 == pair_result(), 'incorrect pairing');
}

#[cfg(test)]
mod g1_line {
    use bn::curve::pairing::miller_utils::LineEvaluationsTrait;
    use bn::fields::{Fq12, Fq12Utils};
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

#[test]
#[available_gas(2000000000)]
fn t_naf_verify() {
    let mut naf = bn::curve::t_naf();
    let mut bit = 1_u128;
    let mut offset = 0xffffffffffffffff_u128;
    let mut result = offset;

    loop {
        match naf.pop_front() {
            Option::Some(naf) => {
                let (naf0, naf1) = naf;

                if naf0 {
                    if naf1 {
                        result = result + bit;
                    } else {
                        result = result - bit;
                    }
                }

                bit = bit * 2;
            },
            Option::None => { break; },
        }
    };
    assert(result - offset == bn::curve::T.into(), 'incorrect T')
}
