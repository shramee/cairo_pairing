use bn::traits::FieldUtils;
use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
use integer::u512;
use bn::curve as c;
use c::{U512BnAdd, U512BnSub};
use bn::fields::{fq, Fq, FqMulShort};

#[test]
#[available_gas(2000000)]
fn add_bn() {
    u512_one() + u512_one();
}

#[test]
#[available_gas(2000000)]
fn sub_bn() {
    u512_one() - u512_one();
}

#[test]
#[available_gas(2000000)]
fn add() {
    c::u512_add_overflow(u512_one(), u512_one());
}

#[test]
#[available_gas(2000000)]
fn sub() {
    c::u512_sub_overflow(u512_one(), u512_one());
}

#[test]
#[available_gas(2000000)]
fn mxi() {
    c::mul_by_xi((u512_one(), u512_one()));
}

#[test]
#[available_gas(2000000)]
fn fq_n2() -> u512 {
    fq(1).into()
}

#[test]
#[available_gas(2000000)]
fn fq_add() -> u512 {
    u512_one().u512_add_fq(fq(1))
}

#[test]
#[available_gas(2000000)]
fn fq_sub() -> u512 {
    u512_one().u512_sub_fq(fq(1))
}
