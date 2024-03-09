use bn::traits::FieldUtils;
use bn::curve as c;
use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
use integer::u512;
use bn::fields::{fq2, Fq2};
use bn::curve::FIELD;
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
fn mxi() {
    let a = fq2(34, 645);
    a.mul_by_nonresidue();
}

#[test]
#[available_gas(2000000)]
fn rdc() {
    let field_nz = c::FIELD.try_into().unwrap();
    let _: Fq2 = (u512_one(), u512_one()).to_fq(field_nz);
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
fn inv() {
    let a = fq2(34, 645);
    a.inv(FIELD.try_into().unwrap());
}
