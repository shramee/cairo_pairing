// test bn::fields::tests::bench::fq01::add ... ok (gas usage est.: 17880)
// test bn::fields::tests::bench::fq01::div ... ok (gas usage est.: 86400)
// test bn::fields::tests::bench::fq01::mul ... ok (gas usage est.: 52530)
// test bn::fields::tests::bench::fq01::sqr ... ok (gas usage est.: 52330)
// test bn::fields::tests::bench::fq01::sub ... ok (gas usage est.: 15710)
// test bn::fields::tests::bench::fq02::add ... ok (gas usage est.: 35760)
// test bn::fields::tests::bench::fq02::div ... ok (gas usage est.: 495910)
// test bn::fields::tests::bench::fq02::mul ... ok (gas usage est.: 217080)
// test bn::fields::tests::bench::fq02::sqr ... ok (gas usage est.: 142030)
// test bn::fields::tests::bench::fq02::sub ... ok (gas usage est.: 31420)
// test bn::fields::tests::bench::fq06::add ... ok (gas usage est.: 107280)
// test bn::fields::tests::bench::fq06::div ... ok (gas usage est.: 5181310)
// test bn::fields::tests::bench::fq06::mul ... ok (gas usage est.: 1944240)
// test bn::fields::tests::bench::fq06::sqr ... ok (gas usage est.: 1475930)
// test bn::fields::tests::bench::fq06::sub ... ok (gas usage est.: 94260)
// test bn::fields::tests::bench::fq12::add ... ok (gas usage est.: 214560)
// test bn::fields::tests::bench::fq12::div ... ok (gas usage est.: 16899030)
// test bn::fields::tests::bench::fq12::mul ... ok (gas usage est.: 6490330)
// test bn::fields::tests::bench::fq12::sqr ... ok (gas usage est.: 4672740)
// test bn::fields::tests::bench::fq12::sub ... ok (gas usage est.: 188520)

// Optimal ate pairing cost, Page 14, Software Implementation of the Optimal
// Ate Pairing over BN curves
// 2355 * m ̃     + 2287 * s ̃     + 13933 * a ̃    + i ̃
// 2355 * 217080 + 2287 * 178070 + 13933 * 35760 + 496310
// = 1,417,209,880

mod fq01 {
    use bn::traits::{FieldOps, FieldShortcuts,};
    use bn::fields::{fq, Fq};
    use debug::PrintTrait;
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
    fn sqr() {
        let a = fq(645);
        a.sqr();
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
    use bn::traits::{FieldOps, FieldShortcuts,};
    use bn::fields::{fq2, Fq2};
    use debug::PrintTrait;
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
    fn sqr() {
        let a = fq2(34, 645);
        a.sqr();
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
    use bn::traits::{FieldOps, FieldShortcuts,};
    use bn::fields::{fq6, Fq6};
    use debug::PrintTrait;
    use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
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
    use bn::traits::{FieldOps, FieldShortcuts,};
    use bn::fields::{fq12, fq6, Fq12};
    use debug::PrintTrait;
    use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
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
