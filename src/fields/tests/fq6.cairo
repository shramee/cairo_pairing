use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{fq2, Fq6, fq6, Fq6Ops};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl, Fq6PrintImpl, Fq12PrintImpl};
use debug::PrintTrait;

#[test]
#[available_gas(50000000)]
fn add_sub() {
    let a = fq6(34, 645, 31, 55, 140, 105);
    let b = fq6(25, 45, 11, 43, 86, 101);
    let c = fq6(9, 600, 20, 12, 54, 4);
    assert(a == b + c, 'incorrect add');
    assert(b == a - c, 'incorrect sub');
}

#[test]
#[available_gas(50000000)]
fn one() {
    let a = fq6(34, 645, 20, 55, 140, 105);
    let one = FieldUtils::one();
    assert(one * a == a, 'incorrect mul by 1');
}

#[test]
#[available_gas(50000000)]
fn sqr() {
    let a = fq6(34, 645, 20, 55, 140, 105);
    assert(a * a == a.sqr(), 'incorrect square');
}

#[test]
#[available_gas(50000000)]
fn mul() {
    let a = fq6(34, 645, 20, 55, 140, 105);
    let b = fq6(25, 45, 11, 43, 86, 101);
    let c = fq6(9, 600, 31, 12, 54, 4);

    let ab = a * b;
    let bc = b * c;
    assert(ab * c == a * bc, 'incorrect mul');
}

#[test]
#[available_gas(50000000)]
fn div() {
    let a = fq6(34, 645, 20, 12, 54, 4);
    let b = fq6(25, 45, 11, 43, 86, 101);
    let c = a / b;
    assert(c * b == a, 'incorrect div');
}

#[test]
#[available_gas(50000000)]
fn inv() {
    let a = fq6(34, 645, 20, 12, 54, 4);
    let b = fq6(25, 45, 11, 43, 86, 101);
    let a_inv = FieldOps::inv(a);
    let c = a * a_inv;
    let d = b * a_inv;

    assert(c == FieldUtils::one(), 'incorrect inv');
    d * a;
    assert(d * a == b, 'incorrect inv');
}

