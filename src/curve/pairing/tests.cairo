use core::debug::PrintTrait;
use bn::fields::{Fq12, Fq12Utils};
use bn::curve::groups::{AffineG1, AffineG2, AffineG1Impl, AffineG2Impl, g1, g2, FIELD};
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq12, Fq, Fq6};
use bn::curve::pairing::final_exponentiation::final_exponentiation;
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

#[test]
#[available_gas(99999999999999)]
fn pairing() {
    let p1 = AffineG1Impl::one();
    let p2 = dbl_g1();
    let q1 = AffineG2Impl::one();
    let q2 = dbl_g2();
    assert(tate_pairing(p1, q2) == tate_pairing(p2, q1), 'pairing mismatch');
}

mod exponentiation {
    use bn::curve::pairing::final_exponentiation::FinalExponentiationTrait;
    use bn::curve::pairing::final_exponentiation::final_exponentiation;
    use core::array::ArrayTrait;
    use bn::fields::{
        print::Fq12PrintImpl, print::FqPrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12,
        fq12, fq6
    };
    use bn::fields::{Fq6Frobenius, Fq12Frobenius};
    use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

    fn pair_result_12() -> Fq12 {
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

    fn pair_result_21() -> Fq12 {
        fq12(
            0x67344e1277398709a07f22125f334c042889b9968132d91836456f02693e2aa,
            0x9eb543ae69ac30e7c5a1d8740db1a27b76ce7639c31b4c5097118031dcc9fd6,
            0x1a828818f6199acedcc7e3b04359dd558e34046b9367d4f43e90530a3241800e,
            0x50eba70419a4a7703a843ab3ba1d635378175acdf8eecbdf959bba7b7d30458,
            0x51c4fe05ca153f901a16e7aa2d17eaae8ba67e06ff0f36f6b039a1eacf2b6cf,
            0x65ff7c2e78658da7694f442878d48d346b33678a6fe2ead51b475977e2c4f7f,
            0xc13c405903b8328438e35f5eae314749ae264ffeb6c4e4429108b29338da611,
            0x9b07dee721f8a8468804de92b08bac6dae98d8246da83ff65b96a7ab3241652,
            0x19731a39f257d88617714358ee57d06ae39d2b51b07c9de926be9ae4fa4ed2cc,
            0x103dea7bed900dd8dbabac886bd24e973cee753d8c1781b71f8b40b3ecaeb04f,
            0x239d3477b8798bb2227e8e21d724419e093c5c678058049a61bb69e21e046c00,
            0x309258557eb06754d1dcfb8a6fa4a98c59538a8dc0317cbae8fd97078c36cf0,
        )
    }

    fn easy_result() -> Fq12 {
        fq12(
            0x2a4ca72fdd0af3ff86e646da9b96a7cc69407cc1e4f87dd12f6552d6168cc1cb,
            0x1e632505544fad7aa191c7b1c7cc7a816d43ea1e3c222a9f633f2532beba7a90,
            0x29f7ffe4990167e9c40b82e10d99104ed5d58a10505ca9df3fe6f89f6d724631,
            0x2ecce5bd65fbc42a4fbacc84ed28a52669da21815d300b2c1a85cf547f941dff,
            0x2379db1f2f5cc1fbc708decedaec77bef7d70e5b45e93e0e3f4ed386e4f98543,
            0x48bcf44109b965cfcb21c0fd27c8a6a46b85d3d6bc8eef39bf4808fd737cc9b,
            0x14d67d4a9d98bb99dca11a3dfdf7ee4655c5305123e8676abd56cef0448cf135,
            0x2f9b1014ad8e0e49630b434d1869fbf7172935beff46af19cd14415f3592b2a2,
            0x79cb3aad73095167444481a53809f754281e717954a8247baa89729918cb2ce,
            0x2a3b1205bc914c2659c0eeea8e956ca4fd0386d8e5a05ba73a44114db999f936,
            0x2ed2c21f4810cf49ad8f51cc1bd2d28972a066bb153f23f87e955496865cccb4,
            0x24c11b663b70d224c7c3f096026b6aa418a4945ffcc6d8aaa5522633b2836b49,
        )
    }

    fn final_result() -> Fq12 {
        fq12(
            0x1025124034fecc32ba2c3bbbcdb356c5bd84a787f0a9c5e1f9a34d5b87dae85a,
            0x1aafb1f7de052c1c1187f7d294d2204bf4e854a05965817e51014a355d917f96,
            0x26c79392cd82f5f15f1366f8c70f618837fe6ccc10c10815369bc8e1412caae,
            0x1d65be11b6b500a55c3c53ca4c033319626a9bc82fa79316bfb14bcd86f0aca5,
            0x8bd3e1971621469e271e9b18016edbc3517c94001240a1e5ef3b07c10860383,
            0xe5327ccc2114231fcd953aa29ccc1fd04ec1bced962c7f9534b9a001dd41a75,
            0x2b7c8e0abca6a7476f0936f535c5e6469ad4b94f8f24c6f437f6d6686a1b381b,
            0x29679b4f134ab2b2e02d2c82a385b12d2ee2272a7e350fba6f80588c0e0afa13,
            0x29163531c4ea85c647a9cd25e2de1433f12569f772eb83fcd8a997f3ca309cee,
            0x23bc9fb95fcf761320a0a287addd92dfaeb1ffc8bf8a943e703fc39f1e9d3085,
            0x236942b30ace732d8b186b0702ea748b375e4405799aa59cf2ae5459f99216f4,
            0x10fc55420be890b138082d746e66bf86f4efe8190cc83313a792dd156bc76e1f,
        )
    }

    #[test]
    #[available_gas(99999999999999)]
    fn exponentiation_compare() {
        let f12 = final_exponentiation(pair_result_12());
        let f21 = final_exponentiation(pair_result_21());
        let f_random = final_exponentiation(easy_result());

        assert(f12 != FieldUtils::one(), 'degenerate exponentiation');
        assert(f12 == f21, 'incorrect exponentiation');
        assert(f12 != f_random, 'incorrect match');
    }

    #[test]
    #[available_gas(100000000)]
    fn pow_test() {
        let x = easy_result();
        let o = (false, false);
        let p = (true, true);
        let n = (true, false);
        let xpow = x.exp_naf(array![n, o, o, p]);
        let field_nz = FIELD.try_into().unwrap();
        let expected = x.cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz)
            / x;
        assert(xpow == expected, 'incorrect pow');
    }
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
