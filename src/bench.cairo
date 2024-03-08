// test bn::bench::fq01::add ... ok (gas usage est.: 10160)
// test bn::bench::fq01::inv ... ok (gas usage est.: 36270)
// test bn::bench::fq01::mul ... ok (gas usage est.: 49130)
// test bn::bench::fq01::mulu ... ok (gas usage est.: 23540)
// test bn::bench::fq01::rdc ... ok (gas usage est.: 25490)
// test bn::bench::fq01::scale ... ok (gas usage est.: 35730)
// test bn::bench::fq01::sqr ... ok (gas usage est.: 45100)
// test bn::bench::fq01::sqru ... ok (gas usage est.: 19510)
// test bn::bench::fq01::sub ... ok (gas usage est.: 5250)
// test bn::bench::fq02::add ... ok (gas usage est.: 20020)
// test bn::bench::fq02::inv ... ok (gas usage est.: 218250)
// test bn::bench::fq02::mul ... ok (gas usage est.: 151970)
// test bn::bench::fq02::mulu ... ok (gas usage est.: 103490)
// test bn::bench::fq02::mxi ... ok (gas usage est.: 85870)
// test bn::bench::fq02::rdc ... ok (gas usage est.: 49680)
// test bn::bench::fq02::sqr ... ok (gas usage est.: 105230)
// test bn::bench::fq02::sqru ... ok (gas usage est.: 56750)
// test bn::bench::fq02::sub ... ok (gas usage est.: 10500)
// test bn::bench::fq06::add ... ok (gas usage est.: 59460)
// test bn::bench::fq06::inv ... ok (gas usage est.: 2081670)
// test bn::bench::fq06::mul ... ok (gas usage est.: 1249220)
// test bn::bench::fq06::mulu ... ok (gas usage est.: 1105280)
// test bn::bench::fq06::sqr ... ok (gas usage est.: 963530)
// test bn::bench::fq06::sqru ... ok (gas usage est.: 819590)
// test bn::bench::fq06::sub ... ok (gas usage est.: 31500)
// test bn::bench::fq12::add ... ok (gas usage est.: 128220)
// test bn::bench::fq12::inv ... ok (gas usage est.: 6584690)
// test bn::bench::fq12::kdcmp ... ok (gas usage est.: 1230780)
// test bn::bench::fq12::ksqr ... ok (gas usage est.: 1276420)
// test bn::bench::fq12::mul ... ok (gas usage est.: 4087960)
// test bn::bench::fq12::sqr ... ok (gas usage est.: 3066340)
// test bn::bench::fq12::sqrc ... ok (gas usage est.: 2247250)
// test bn::bench::fq12::sub ... ok (gas usage est.: 74900)
// test bn::bench::fq12::xp_t ... ok (gas usage est.: 163091970)
// test bn::bench::fq12::z_esy ... ok (gas usage est.: 15862820)
// test bn::bench::fq12::z_hrd ... ok (gas usage est.: 540241830)
// test bn::bench::sprs::l1f_l2f ... ok (gas usage est.: 4414980)
// test bn::bench::sprs::l1l2_f ... ok (gas usage est.: 4423410)
// test bn::bench::sprs::s01_01 ... ok (gas usage est.: 382270)
// test bn::bench::sprs::s01_fq6 ... ok (gas usage est.: 811210)
// test bn::bench::sprs::s034_034 ... ok (gas usage est.: 651640)
// test bn::bench::sprs::s034_fq12 ... ok (gas usage est.: 2208740)
// test bn::bench::sprs::s01234_fq12 ... ok (gas usage est.: 3776570)
// test bn::bench::u512::add ... ok (gas usage est.: 7490)
// test bn::bench::u512::add_bn ... ok (gas usage est.: 15390)
// test bn::bench::u512::fq_add ... ok (gas usage est.: 5480)
// test bn::bench::u512::fq_n2 ... ok (gas usage est.: 400)
// test bn::bench::u512::fq_sub ... ok (gas usage est.: 5480)
// test bn::bench::u512::mxi ... ok (gas usage est.: 95100)
// test bn::bench::u512::sub ... ok (gas usage est.: 7490)
// test bn::bench::u512::sub_bn ... ok (gas usage est.: 15390)

use bn::traits::{FieldOps, FieldShortcuts, FieldMulShortcuts};
use bn::math::fast_mod as m;
use bn::curve::{U512BnAdd, U512BnSub};
use debug::PrintTrait;

#[inline(always)]
fn u512_one() -> integer::u512 {
    integer::u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }
}

mod fq01 {
    use bn::traits::FieldUtils;
    use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use integer::u512;
    use bn::curve::{U512BnAdd, U512BnSub, FIELD};
    use bn::fields::{fq, Fq, FqMulShort};
    #[test]
    #[available_gas(2000000)]
    fn add() {
        let a = fq(645);
        let b = fq(45);
        a + b;
    }

    #[test]
    #[available_gas(2000000)]
    fn sub() {
        let a = fq(645);
        let b = fq(45);
        a - b;
    }

    #[test]
    #[available_gas(2000000)]
    fn mul() {
        let a = fq(645);
        let b = fq(45);
        a * b;
    }

    #[test]
    #[available_gas(2000000)]
    fn scale() {
        let a = fq(645);
        let b = fq(45);
        a.scale(b.c0.low);
    }

    #[test]
    #[available_gas(2000000)]
    fn mulu() {
        let a = fq(645);
        let b = fq(45);
        a.u_mul(b);
    }

    #[test]
    #[available_gas(2000000)]
    fn rdc() {
        let field_nz = FIELD.try_into().unwrap();
        let _: Fq = u512_one().to_fq(field_nz);
    }

    #[test]
    #[available_gas(2000000)]
    fn sqr() {
        let a = fq(645);
        a.sqr();
    }

    #[test]
    #[available_gas(2000000)]
    fn sqru() {
        let a = fq(645);
        a.u_sqr();
    }

    #[test]
    #[available_gas(2000000)]
    fn inv() {
        let a = fq(645);
        a.inv(FIELD.try_into().unwrap());
    }
}

mod fq02 {
    use bn::traits::FieldUtils;
    use bn::curve as c;
    use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use integer::u512;
    use bn::fields::{fq2, Fq2};
    use bn::curve::FIELD;
    #[test]
    #[available_gas(2000000)]
    fn add() {
        let a = fq2(34, 645);
        let b = fq2(25, 45);
        a + b;
    }

    #[test]
    #[available_gas(2000000)]
    fn sub() {
        let a = fq2(34, 645);
        let b = fq2(25, 45);
        a - b;
    }

    #[test]
    #[available_gas(2000000)]
    fn mul() {
        let a = fq2(34, 645);
        let b = fq2(25, 45);
        a * b;
    }

    #[test]
    #[available_gas(2000000)]
    fn mulu() {
        let a = fq2(34, 645);
        let b = fq2(25, 45);
        a.u_mul(b);
    }

    #[test]
    #[available_gas(2000000)]
    fn mxi() {
        let a = fq2(34, 645);
        a.mul_by_nonresidue();
    }

    #[test]
    #[available_gas(2000000)]
    fn rdc() {
        let field_nz = c::FIELD.try_into().unwrap();
        let _: Fq2 = (u512_one(), u512_one()).to_fq(field_nz);
    }

    #[test]
    #[available_gas(2000000)]
    fn sqr() {
        let a = fq2(34, 645);
        a.sqr();
    }

    #[test]
    #[available_gas(2000000)]
    fn sqru() {
        let a = fq2(34, 645);
        a.u_sqr();
    }

    #[test]
    #[available_gas(2000000)]
    fn inv() {
        let a = fq2(34, 645);
        a.inv(FIELD.try_into().unwrap());
    }
}

mod fq06 {
    use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use integer::u512;
    use bn::fields::{fq6, Fq6};
    use bn::curve::{FIELD};
    #[test]
    #[available_gas(20000000)]
    fn add() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        let b = fq6(25, 45, 11, 43, 86, 101);
        a + b;
    }

    #[test]
    #[available_gas(20000000)]
    fn sub() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        let b = fq6(25, 45, 11, 43, 86, 101);
        a - b;
    }

    #[test]
    #[available_gas(20000000)]
    fn mul() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        let b = fq6(25, 45, 11, 43, 86, 101);
        a * b;
    }

    #[test]
    #[available_gas(20000000)]
    fn mulu() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        let b = fq6(25, 45, 11, 43, 86, 101);
        a.u_mul(b);
    }

    #[test]
    #[available_gas(20000000)]
    fn sqr() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        a.sqr();
    }

    #[test]
    #[available_gas(2000000)]
    fn sqru() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        a.u_sqr();
    }

    #[test]
    #[available_gas(20000000)]
    fn inv() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        a.inv(FIELD.try_into().unwrap());
    }
}

mod fq12 {
    use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use integer::u512;
    use bn::fields::{fq12, fq6, Fq12, Fq12Exponentiation, Fq12Squaring, print::Fq12Display};
    use bn::curve::FIELD;

    fn a() -> Fq12 {
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
    #[available_gas(20000000)]
    fn add() {
        let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
        a() + b;
    }

    #[test]
    #[available_gas(20000000)]
    fn sub() {
        let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
        a() - b;
    }

    #[test]
    #[available_gas(20000000)]
    fn mul() {
        let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
        a() * b;
    }

    #[test]
    #[available_gas(20000000)]
    fn sqr() {
        a().sqr();
    }

    #[test]
    #[available_gas(20000000)]
    fn sqrc() {
        a().cyclotomic_sqr(FIELD.try_into().unwrap());
    }

    #[test]
    #[available_gas(20000000)]
    fn ksqr() {
        a().krbn_compress_2345().sqr_krbn(FIELD.try_into().unwrap());
    }

    #[test]
    #[available_gas(20000000)]
    fn kdcmp() {
        a().krbn_compress_2345().krbn_decompress(FIELD.try_into().unwrap());
    }

    #[test]
    #[available_gas(30000000)]
    fn inv() {
        a().inv(FIELD.try_into().unwrap());
    }

    #[test]
    #[available_gas(30000000)]
    fn z_esy() {
        a().final_exponentiation_easy_part();
    }

    #[test]
    #[available_gas(20000000000)]
    fn xp_t() {
        a().exp_by_neg_t(FIELD.try_into().unwrap());
    }

    #[test]
    #[available_gas(30000000000)]
    fn z_hrd() {
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
            .final_exponentiation_hard_part(FIELD.try_into().unwrap());
    }
}

mod sprs {
    use bn::fields::fq_sparse::FqSparseTrait;
    use bn::fields::{fq, fq2, Fq2, fq12, Fq12, Fq6, fq6, Fq12Ops, Fq12Exponentiation,};
    use bn::curve::{FIELD, u512,};
    use bn::fields::{sparse_fq6, FqSparse, Fq6Sparse01, Fq12Sparse034, Fq12Sparse01234};

    fn a_6() -> Fq6 {
        fq6(
            0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
            0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
            0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
            0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
            0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
            0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
        )
    }

    fn a_12() -> Fq12 {
        fq12(
            //30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
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

    fn a_sparse_01234() -> Fq12Sparse01234 {
        let Fq6 { c0, c1, c2 } = a_6();
        let Fq12Sparse034 { c3, c4 } = a();
        Fq12Sparse01234 { c0, c1, c2, c3, c4 }
    }

    fn a() -> Fq12Sparse034 {
        Fq12Sparse034 {
            c3: fq2(
                0x2e3a5a8e0529c430c27e3673b9519767e265dcbcde8fea81cdd820918c4bd107,
                0xe6c5e3ec8c33c105e56e0ff3969bd92b2c4f6b05be655dcf21238f80c72030f
            ),
            c4: fq2(
                0x1b9732f816a94fa77048902ccb7ffc1ef433b2d95ebfad13030852e6e244b0b3,
                0x200ab6da30955b57dcc064deef9e4962ffa243efffd819010546fadaf591ef55
            ),
        }
    }

    fn b() -> Fq12Sparse034 {
        Fq12Sparse034 {
            c3: fq2(
                0x4d4df3e5d3bd9178d6a6c3a0654b542be46f209d956660c3605b9b4d5c8b8e0,
                0x4a86b2d0e408874533554f3c4071db92b6984030d5e7e4c6d6bbd3b84bd86b4
            ),
            c4: fq2(
                0x62ef6addea25e90cedd1bfab17d5dc57aed021a999e6c03eb1d83cd04246394,
                0x13dada4aebe86c7c07d4d5689172f885284aafe4e599d240735bf229fa3d823f
            ),
        }
    }

    #[test]
    #[available_gas(20000000)]
    fn s01_01() {
        let field_nz = FIELD.try_into().unwrap();
        let a = a();
        let a = sparse_fq6(a.c3, a.c4);
        let b = b();
        let b = sparse_fq6(b.c3, b.c4);
        b.mul_01_by_01(a, field_nz);
    }

    #[test]
    #[available_gas(20000000)]
    fn s01_fq6() {
        let field_nz = FIELD.try_into().unwrap();
        let a = a();
        let a = sparse_fq6(a.c3, a.c4);
        let b = a_6();
        b.u_mul_01(a, field_nz);
    }

    #[test]
    #[available_gas(20000000)]
    fn s034_034() {
        let field_nz = FIELD.try_into().unwrap();
        a().mul_034_by_034(b(), field_nz);
    }

    #[test]
    #[available_gas(20000000)]
    fn s034_fq12() {
        let field_nz = FIELD.try_into().unwrap();
        let a = a_12();
        a.mul_034(b(), field_nz);
    }

    #[test]
    #[available_gas(200000000)]
    fn s01234_fq12() {
        let field_nz = FIELD.try_into().unwrap();
        a_12().mul_01234(a_sparse_01234(), field_nz);
    }

    #[test]
    #[available_gas(200000000)]
    fn l1l2_f() {
        let field_nz = FIELD.try_into().unwrap();
        let f = a_12();
        let l1 = a();
        let l2 = b();
        f.mul_01234(l1.mul_034_by_034(l2, field_nz), field_nz);
    }

    #[test]
    #[available_gas(200000000)]
    fn l1f_l2f() {
        let field_nz = FIELD.try_into().unwrap();
        let f = a_12();
        let l1 = a();
        let l2 = b();
        f.mul_034(l1, field_nz).mul_034(l2, field_nz);
    }
}

mod u512 {
    use bn::traits::FieldUtils;
    use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use integer::u512;
    use bn::curve as c;
    use c::{U512BnAdd, U512BnSub};
    use bn::fields::{fq, Fq, FqMulShort};

    #[test]
    #[available_gas(2000000)]
    fn add_bn() {
        u512_one() + u512_one();
    }

    #[test]
    #[available_gas(2000000)]
    fn sub_bn() {
        u512_one() - u512_one();
    }

    #[test]
    #[available_gas(2000000)]
    fn add() {
        c::u512_add_overflow(u512_one(), u512_one());
    }

    #[test]
    #[available_gas(2000000)]
    fn sub() {
        c::u512_sub_overflow(u512_one(), u512_one());
    }

    #[test]
    #[available_gas(2000000)]
    fn mxi() {
        c::mul_by_xi((u512_one(), u512_one()));
    }

    #[test]
    #[available_gas(2000000)]
    fn fq_n2() -> u512 {
        fq(1).into()
    }

    #[test]
    #[available_gas(2000000)]
    fn fq_add() -> u512 {
        u512_one().u512_add_fq(fq(1))
    }

    #[test]
    #[available_gas(2000000)]
    fn fq_sub() -> u512 {
        u512_one().u512_sub_fq(fq(1))
    }
}

