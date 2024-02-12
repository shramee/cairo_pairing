// test bn::fields::tests::bench::fq01::add ... ok (gas usage est.: 10160)
// test bn::fields::tests::bench::fq01::div ... ok (gas usage est.: 83000)
// test bn::fields::tests::bench::fq01::mul ... ok (gas usage est.: 49130)
// test bn::fields::tests::bench::fq01::mulu ... ok (gas usage est.: 24140)
// test bn::fields::tests::bench::fq01::rdc ... ok (gas usage est.: 25690)
// test bn::fields::tests::bench::fq01::sqr ... ok (gas usage est.: 45100)
// test bn::fields::tests::bench::fq01::sqru ... ok (gas usage est.: 20110)
// test bn::fields::tests::bench::fq01::sub ... ok (gas usage est.: 14780)
// test bn::fields::tests::bench::fq02::add ... ok (gas usage est.: 20020)
// test bn::fields::tests::bench::fq02::div ... ok (gas usage est.: 370360)
// test bn::fields::tests::bench::fq02::mul ... ok (gas usage est.: 156780)
// test bn::fields::tests::bench::fq02::mulu ... ok (gas usage est.: 106800)
// test bn::fields::tests::bench::fq02::rdc ... ok (gas usage est.: 50080)
// test bn::fields::tests::bench::fq02::sqr ... ok (gas usage est.: 115960)
// test bn::fields::tests::bench::fq02::sqru ... ok (gas usage est.: 67480)
// test bn::fields::tests::bench::fq02::sub ... ok (gas usage est.: 29560)
// test bn::fields::tests::bench::fq06::add ... ok (gas usage est.: 59460)
// test bn::fields::tests::bench::fq06::div ... ok (gas usage est.: 2946400)
// test bn::fields::tests::bench::fq06::mul ... ok (gas usage est.: 1054200)
// test bn::fields::tests::bench::fq06::sqr ... ok (gas usage est.: 827260)
// test bn::fields::tests::bench::fq06::sub ... ok (gas usage est.: 88680)
// test bn::fields::tests::bench::fq12::add ... ok (gas usage est.: 118620)
// test bn::fields::tests::bench::fq12::div ... ok (gas usage est.: 9319040)
// test bn::fields::tests::bench::fq12::mul ... ok (gas usage est.: 3522980)
// test bn::fields::tests::bench::fq12::sqr ... ok (gas usage est.: 2500620)
// test bn::fields::tests::bench::fq12::sub ... ok (gas usage est.: 177360)

use bn::traits::{FieldOps, FieldShortcuts, FieldMulShortcuts};
use bn::math::fast_mod as m;
use integer::u512;
use debug::PrintTrait;

fn u512_one() -> u512 {
    u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }
}

mod fq01 {
    use super::{u512, u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
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
    fn mulu() {
        let a = fq(645);
        let b = fq(45);
        a.u_mul(b);
    }

    #[test]
    #[available_gas(2000000)]
    fn rdc() {
        let _: Fq = u512_one().to_fq();
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
    fn div() {
        let a = fq(645);
        let b = fq(45);
        a / b;
    }
}

mod fq02 {
    use super::{u512, u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use bn::fields::{fq2, Fq2};
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
    fn rdc() {
        let _: Fq2 = (u512_one(), u512_one()).to_fq();
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
    fn div() {
        let a = fq2(34, 645);
        let b = fq2(25, 45);
        a / b;
    }
}

mod fq06 {
    use super::{u512, u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use bn::fields::{fq6, Fq6};
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
    fn sqr() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        a.sqr();
    }

    #[test]
    #[available_gas(20000000)]
    fn div() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        let b = fq6(25, 45, 11, 43, 86, 101);
        a / b;
    }
}

mod fq12 {
    use super::{u512, u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
    use bn::fields::{fq12, fq6, Fq12};
    #[test]
    #[available_gas(20000000)]
    fn add() {
        let a = fq12(34, 645, 31, 55, 140, 105, 2, 2, 2, 2, 2, 2);
        let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
        a + b;
    }

    #[test]
    #[available_gas(20000000)]
    fn sub() {
        let a = fq12(34, 645, 31, 55, 140, 105, 2, 2, 2, 2, 2, 2);
        let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
        a - b;
    }

    #[test]
    #[available_gas(20000000)]
    fn mul() {
        let a = fq12(34, 645, 31, 55, 140, 105, 2, 2, 2, 2, 2, 2);
        let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
        a * b;
    }

    #[test]
    #[available_gas(20000000)]
    fn sqr() {
        let a = fq12(34, 645, 31, 55, 140, 105, 2, 2, 2, 2, 2, 2);
        a.sqr();
    }

    #[test]
    #[available_gas(30000000)]
    fn div() {
        let a = fq12(34, 645, 31, 55, 140, 105, 2, 2, 2, 2, 2, 2);
        let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
        a / b;
    }
}
