use bn::traits::{FieldOps, FieldUtils};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq2, fq2, Fq2Ops};
use debug::PrintTrait;

#[test]
#[available_gas(2000000)]
fn fq2_add_sub() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    assert(a == b + c, 'incorrect add');
    assert(b == a - c, 'incorrect sub');
}

#[test]
#[available_gas(2000000)]
fn fq2_mul() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    assert((a * b) * c == a * (b * c), 'incorrect mul');
}

#[test]
#[available_gas(2000000)]
fn fq2_div() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = a / b;
    assert(c * b == a, 'incorrect div');
}

#[test]
#[available_gas(2000000)]
fn fq2_inv() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let a_inv = FieldOps::inv(a);
    let c = a * a_inv;
    let d = b * a_inv;
    assert(c == FieldUtils::one(), 'incorrect inv');
    assert(d * a == b, 'incorrect inv');
}
