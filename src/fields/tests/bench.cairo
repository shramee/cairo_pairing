// test bench::fq1::add ... ok (gas usage est.: 17880)
// test bench::fq1::div ... ok (gas usage est.: 86400)
// test bench::fq1::mul ... ok (gas usage est.: 52530)
// test bench::fq1::sub ... ok (gas usage est.: 15710)

// test bench::fq2::add ... ok (gas usage est.: 35760)
// test bench::fq2::div ... ok (gas usage est.: 540800)
// test bench::fq2::mul ... ok (gas usage est.: 254060)
// test bench::fq2::sub ... ok (gas usage est.: 31420)

// test bench::fq6::add ... ok (gas usage est.: 107280)
// test bench::fq6::div ... ok (gas usage est.: 6633670)
// test bench::fq6::mul ... ok (gas usage est.: 2535440)
// test bench::fq6::sub ... ok (gas usage est.: 94260)

mod fq1 {
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

mod fq2 {
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

mod fq6 {
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
