// test bn::fields::tests::bench::fq01::add ... ok (gas usage est.: 17880)
// test bn::fields::tests::bench::fq01::div ... ok (gas usage est.: 86400)
// test bn::fields::tests::bench::fq01::mul ... ok (gas usage est.: 52530)
// test bn::fields::tests::bench::fq01::sub ... ok (gas usage est.: 15710)

// test bn::fields::tests::bench::fq02::add ... ok (gas usage est.: 35760)
// test bn::fields::tests::bench::fq02::div ... ok (gas usage est.: 514870)
// test bn::fields::tests::bench::fq02::mul ... ok (gas usage est.: 228130)
// test bn::fields::tests::bench::fq02::sub ... ok (gas usage est.: 31420)

// test bn::fields::tests::bench::fq06::add ... ok (gas usage est.: 107280)
// test bn::fields::tests::bench::fq06::div ... ok (gas usage est.: 6076420)
// test bn::fields::tests::bench::fq06::mul ... ok (gas usage est.: 2332000)
// test bn::fields::tests::bench::fq06::sub ... ok (gas usage est.: 94260)

// test bn::fields::tests::bench::fq12::add ... ok (gas usage est.: 214560)
// test bn::fields::tests::bench::fq12::div ... ok (gas usage est.: 20185860)
// test bn::fields::tests::bench::fq12::mul ... ok (gas usage est.: 7737890)
// test bn::fields::tests::bench::fq12::sub ... ok (gas usage est.: 188520)

mod fq01 {
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
    fn div() {
        let a = fq(645);
        let b = fq(45);
        a / b;
    }
}

mod fq02 {
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
    fn div() {
        let a = fq2(34, 645);
        let b = fq2(25, 45);
        a / b;
    }
}

mod fq06 {
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
    fn div() {
        let a = fq6(34, 645, 20, 55, 140, 105);
        let b = fq6(25, 45, 11, 43, 86, 101);
        a / b;
    }
}

mod fq12 {
    use bn::fields::{fq12, fq6, Fq12};
    use debug::PrintTrait;
    use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
    #[test]
    #[available_gas(20000000)]
    fn add() {
        let a = fq12(fq6(34, 645, 31, 55, 140, 105), fq6(2, 2, 2, 2, 2, 2));
        let b = fq12(fq6(25, 45, 11, 43, 86, 101), fq6(1, 1, 1, 1, 1, 1));
        a + b;
    }

    #[test]
    #[available_gas(20000000)]
    fn sub() {
        let a = fq12(fq6(34, 645, 31, 55, 140, 105), fq6(2, 2, 2, 2, 2, 2));
        let b = fq12(fq6(25, 45, 11, 43, 86, 101), fq6(1, 1, 1, 1, 1, 1));
        a - b;
    }

    #[test]
    #[available_gas(20000000)]
    fn mul() {
        let a = fq12(fq6(34, 645, 31, 55, 140, 105), fq6(2, 2, 2, 2, 2, 2));
        let b = fq12(fq6(25, 45, 11, 43, 86, 101), fq6(1, 1, 1, 1, 1, 1));
        a * b;
    }

    #[test]
    #[available_gas(30000000)]
    fn div() {
        let a = fq12(fq6(34, 645, 31, 55, 140, 105), fq6(2, 2, 2, 2, 2, 2));
        let b = fq12(fq6(25, 45, 11, 43, 86, 101), fq6(1, 1, 1, 1, 1, 1));
        a / b;
    }
}
