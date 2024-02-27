use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{fq12, Fq12, Fq6, fq6, Fq12Ops, Fq12FinalExpo};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl, Fq6PrintImpl, Fq12PrintImpl};
use bn::fields::print::{Fq12Display, Fq2Display};
use bn::curve::FIELD;
use debug::PrintTrait;

fn cyclotomic_input() -> Fq12 {
    fq12(
        0x299fa9e6f2be7f5e0134d731e8ceba8580affaf4afa3eb5e91b7a97c2f5734e0,
        0x201ccdefb31bfdf2b8515fe0711b4da98d57a24ea0877fcbafb60312208806c9,
        0x296b06df4ca6915f1b76572fb6768bfe71c1aeb3637d2bc5d9a72ff4c101db4f,
        0x2dd875327c181fd754dc3fdd674ce1355cb1ae65262b450e5ac46bc883c81b3c,
        0x1ae0ec6e455feb58cf303dca8b2dd6aa1150b8ee15545a2b863fe773ac517bf0,
        0x2f55812c498d2bde0050737908291c21aae824a3e7bf404d8c26cddd3df4a56a,
        0x2297ab25360e02d33104ff5bcd4c10e4c795aa82060cf0f336fbe39c96e1d294,
        0xc783f9c02b13f29dc83d5720f8585124428e4ccac4c21109537d9ed3fb0a3e1,
        0x1bed5a750afffb71c2e8ffac45020bb3c5f6241b66a3b3dbb9343ed59b949d91,
        0x1def3f63e89f940c987739d0d4bb8aa31dd45c43e987aef34d3f45601dc16a70,
        0x21c17a06b27ee5c448dc457ed58fd95a47a95da2fdefab52398c4ca1c63c876b,
        0x1356c6b1b5447f5d8bf42c5e870dc60d577f57f7b87bab288bf08e5483e29103,
    )
}

fn cyclotomic_squared() -> Fq12 {
    fq12(
        0x2c789330b21092eb574fcc7cacbb6e4778e24dd0e77be0dd68a8ebcaedd13545,
        0x269610152e2d9d1a635e241ec0ab35f2b6c3bd24c4d79b64c7f1cb8df488f412,
        0x2452419de50d6847fe2311e8ba91628710b40b1b96ca6eecccf7476d485dc3b8,
        0x1f43643df623875fbff71f8bc77d3af0cccf4c109bbf6c6fe3d51e4c01de56b5,
        0xca1e428bdc9fe935b8b885866ff4ddf466478654177558973af83f06454763,
        0x2fa5aa3046634bd2a83f13d477b718d1f52c656a928088b5af1a606738307d01,
        0x1458fe9b3ac0b91e11a71ab04be2da8a04c10e004c26ce597c6f298441b56345,
        0x14d152e05b9791235c2b4a47100e55a33bd310eeff6740a2231f9cf39e3c2519,
        0xb44764b85dd5c9752fb8f4db6f80dec4a9782fcddea916abb722b584cd51ad2,
        0xf8be86c84886b94981009b3ecb4ee8333ba8170e0f2548bcd4773b3e5be81d1,
        0x1dc1d1c32cb59589a96579e83cab5cf1508e1949fc1b00a394a14614b0f76538,
        0x281f3dab2f4ea9f42a827875d41b8f012a243669f66252fa1404a56612bf5a21,
    )
}

fn normal_squared() -> Fq12 {
    fq12(
        0x2c789330b21092eb574fcc7cacbb6e4778e24dd0e77be0dd68a8ebcaedd13545,
        0x269610152e2d9d1a635e241ec0ab35f2b6c3bd24c4d79b64c7f1cb8df488f412,
        0x2452419de50d6847fe2311e8ba91628710b40b1b96ca6eecccf7476d485dc3b8,
        0x1f43643df623875fbff71f8bc77d3af0cccf4c109bbf6c6fe3d51e4c01de56b5,
        0xca1e428bdc9fe935b8b885866ff4ddf466478654177558973af83f06454763,
        0x2fa5aa3046634bd2a83f13d477b718d1f52c656a928088b5af1a606738307d01,
        0x1458fe9b3ac0b91e11a71ab04be2da8a04c10e004c26ce597c6f298441b56345,
        0x14d152e05b9791235c2b4a47100e55a33bd310eeff6740a2231f9cf39e3c2519,
        0xb44764b85dd5c9752fb8f4db6f80dec4a9782fcddea916abb722b584cd51ad2,
        0xf8be86c84886b94981009b3ecb4ee8333ba8170e0f2548bcd4773b3e5be81d1,
        0x1dc1d1c32cb59589a96579e83cab5cf1508e1949fc1b00a394a14614b0f76538,
        0x281f3dab2f4ea9f42a827875d41b8f012a243669f66252fa1404a56612bf5a21,
    )
}

fn karabina_square() -> Fq12 {
    fq12(
        0x0,
        0x0,
        0x2452419de50d6847fe2311e8ba91628710b40b1b96ca6eecccf7476d485dc3b8,
        0x1f43643df623875fbff71f8bc77d3af0cccf4c109bbf6c6fe3d51e4c01de56b5,
        0xca1e428bdc9fe935b8b885866ff4ddf466478654177558973af83f06454763,
        0x2fa5aa3046634bd2a83f13d477b718d1f52c656a928088b5af1a606738307d01,
        0x1458fe9b3ac0b91e11a71ab04be2da8a04c10e004c26ce597c6f298441b56345,
        0x14d152e05b9791235c2b4a47100e55a33bd310eeff6740a2231f9cf39e3c2519,
        0x0,
        0x0,
        0x1dc1d1c32cb59589a96579e83cab5cf1508e1949fc1b00a394a14614b0f76538,
        0x281f3dab2f4ea9f42a827875d41b8f012a243669f66252fa1404a56612bf5a21,
    )
}

fn karabina_decompressed() -> Fq12 {
    fq12(
        0x2c789330b21092eb574fcc7cacbb6e4778e24dd0e77be0dd68a8ebcaedd13545,
        0x269610152e2d9d1a635e241ec0ab35f2b6c3bd24c4d79b64c7f1cb8df488f412,
        0x2452419de50d6847fe2311e8ba91628710b40b1b96ca6eecccf7476d485dc3b8,
        0x1f43643df623875fbff71f8bc77d3af0cccf4c109bbf6c6fe3d51e4c01de56b5,
        0xca1e428bdc9fe935b8b885866ff4ddf466478654177558973af83f06454763,
        0x2fa5aa3046634bd2a83f13d477b718d1f52c656a928088b5af1a606738307d01,
        0x1458fe9b3ac0b91e11a71ab04be2da8a04c10e004c26ce597c6f298441b56345,
        0x14d152e05b9791235c2b4a47100e55a33bd310eeff6740a2231f9cf39e3c2519,
        0xb44764b85dd5c9752fb8f4db6f80dec4a9782fcddea916abb722b584cd51ad2,
        0xf8be86c84886b94981009b3ecb4ee8333ba8170e0f2548bcd4773b3e5be81d1,
        0x1dc1d1c32cb59589a96579e83cab5cf1508e1949fc1b00a394a14614b0f76538,
        0x281f3dab2f4ea9f42a827875d41b8f012a243669f66252fa1404a56612bf5a21,
    )
}

#[test]
#[available_gas(50000000)]
fn sqr_2345() {
    let a = cyclotomic_input();
    let field_nz = FIELD.try_into().unwrap();
    let asq = a.sqr();

    let (a2, a3, a4, a5,) = a.krbn_compress().sqr_krbn(field_nz);
    println!("{}{}", asq.c0.c1, a2);
    assert(asq.c0.c1 == a2, 'incorrect k_sqr a2');
    assert(asq.c1.c0 == a3, 'incorrect k_sqr a3');
    assert(asq.c1.c1 == a4, 'incorrect k_sqr a4');
    assert(asq.c1.c2 == a5, 'incorrect k_sqr a5');
}

#[test]
#[available_gas(50000000)]
fn expand_2345() {
    let a = cyclotomic_input();
    let field_nz = FIELD.try_into().unwrap();
    let asq = a.sqr();

    let asq_decompressed = asq.krbn_compress().krbn_decompress(field_nz);
    assert(asq == asq_decompressed, 'incorrect krbn_decompress');
}

#[test]
#[available_gas(50000000)]
fn sqr_cyc() {
    let a = cyclotomic_input();
    let field_nz = FIELD.try_into().unwrap();

    assert(a.cyclotomic_sqr(field_nz) == a.sqr(), 'incorrect square');
}
