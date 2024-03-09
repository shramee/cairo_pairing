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
