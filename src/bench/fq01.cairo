use bn::traits::FieldUtils;
use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
use integer::u512;
use bn::curve::{U512BnAdd, U512BnSub, FIELD, FIELD_NZ};
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
    let _: Fq = u512_one().to_fq(FIELD_NZ);
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
    a.inv(FIELD_NZ);
}
