use core::array::ArrayTrait;
use core::clone::Clone;
use core::traits::TryInto;
use bn::curve::FIELD;
use bn::fast_mod as f;
use f::u512;

use bn::curve::{U512BnAdd, Tuple2Add, U512BnSub, Tuple2Sub};
use bn::traits::{FieldOps, FieldUtils, FieldMulShortcuts};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq2, fq2, Fq2Ops, Fq2MulShort};
use debug::PrintTrait;

    fq2(
        0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
        0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f
    )
}

fn b() -> Fq2 {
    fq2(
        0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
        0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb
    )
}

fn axb() -> Fq2 {
    fq2(
        0x23cc62ad7646c4f41c9ff2a7326bddac3e33094c2686b0eb7d508fe5729b060f,
        0x17b94d77eb36c29eefb15c11ecfc6c52878ff53fa7d83dbedc15ba4865ed0c5c
    )
}
#[test]
#[available_gas(2000000)]
fn add_sub() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    assert(a == b + c, 'incorrect add');
    assert(b == a - c, 'incorrect sub');
}

#[test]
#[available_gas(200000000)]
fn mul() {
    let b = b();
    let ab = axb();
    assert(ab == a * b, 'incorrect mul');
}

#[test]
#[available_gas(200000000)]
fn mul_assoc() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    let ab = a * b;
    let C: (u512, u512) = a.u_mul(b);

    assert(ab * c == a * (b * c), 'incorrect mul');
    assert(ab == C.to_fq(), 'incorrect u512 mul');
}

#[test]
#[available_gas(2000000)]
fn div() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = a / b;
    assert(c * b == a, 'incorrect div');
}

#[test]
#[available_gas(2000000)]
fn inv() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let a_inv = FieldOps::inv(a);
    let c = a * a_inv;
    let d = b * a_inv;
    assert(c == FieldUtils::one(), 'incorrect inv');
    assert(d * a == b, 'incorrect inv');
}

#[test]
#[available_gas(0xf0000)]
fn inv_one() {
    let one: Fq2 = FieldUtils::one();
    let one_inv = one.inv();
    assert(one_inv == one, 'incorrect inverse of one');
}

#[test]
#[available_gas(5000000)]
fn sqr() {
    let a = fq2(34, 645);
    assert(a * a == a.sqr(), 'incorrect mul');
}
