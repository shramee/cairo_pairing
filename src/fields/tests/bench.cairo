// test bn::fields::tests::bench::fq01::add ... ok (gas usage est.: 12360)
// test bn::fields::tests::bench::fq01::div ... ok (gas usage est.: 86000)
// test bn::fields::tests::bench::fq01::mul ... ok (gas usage est.: 52130)
// test bn::fields::tests::bench::fq01::mulu ... ok (gas usage est.: 24940)
// test bn::fields::tests::bench::fq01::rdc ... ok (gas usage est.: 27890)
// test bn::fields::tests::bench::fq01::sqr ... ok (gas usage est.: 47900)
// test bn::fields::tests::bench::fq01::sqru ... ok (gas usage est.: 20710)
// test bn::fields::tests::bench::fq01::sub ... ok (gas usage est.: 15710)
// test bn::fields::tests::bench::fq02::add ... ok (gas usage est.: 24420)
// test bn::fields::tests::bench::fq02::div ... ok (gas usage est.: 419640)
// test bn::fields::tests::bench::fq02::mul ... ok (gas usage est.: 155690)
// test bn::fields::tests::bench::fq02::mulu ... ok (gas usage est.: 103410)
// test bn::fields::tests::bench::fq02::rdc ... ok (gas usage est.: 53080)
// test bn::fields::tests::bench::fq02::sqr ... ok (gas usage est.: 121190)
// test bn::fields::tests::bench::fq02::sqru ... ok (gas usage est.: 69710)
// test bn::fields::tests::bench::fq02::sub ... ok (gas usage est.: 31420)
// test bn::fields::tests::bench::fq06::add ... ok (gas usage est.: 72660)
// test bn::fields::tests::bench::fq06::div ... ok (gas usage est.: 3865380)
// test bn::fields::tests::bench::fq06::mul ... ok (gas usage est.: 1376360)
// test bn::fields::tests::bench::fq06::sqr ... ok (gas usage est.: 1150210)
// test bn::fields::tests::bench::fq06::sub ... ok (gas usage est.: 94260)
// test bn::fields::tests::bench::fq12::add ... ok (gas usage est.: 145020)
// test bn::fields::tests::bench::fq12::div ... ok (gas usage est.: 12497840)
// test bn::fields::tests::bench::fq12::mul ... ok (gas usage est.: 4653310)
// test bn::fields::tests::bench::fq12::sqr ... ok (gas usage est.: 3374880)
// test bn::fields::tests::bench::fq12::sub ... ok (gas usage est.: 188520)

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
