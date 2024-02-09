mod constants;
mod groups;

use constants::{X, ORDER, FIELD, FIELDSQLOW, FIELDSQHIGH, B, x_naf};
use constants::{ATE_LOOP_COUNT, LOG_ATE_LOOP_COUNT,};
// #[cfg(test)]
// mod groups_tests;

// #[cfg(test)]
// mod tests;

mod pairing {
    mod final_exponentiation;
    mod miller_utils;
    mod bkls_tate;
// #[cfg(test)]
// mod tests;
}

use bn::fields as f;
use bn::math::fast_mod as m;
use m::{add_u, mul_u, sqr_u, scl_u};
// These paramas from:
// https://hackmd.io/@jpw/bn254

#[inline(always)]
fn field_nz() -> NonZero<u256> {
    FIELD.try_into().unwrap()
}

#[inline(always)]
fn mul(a: u256, b: u256) -> u256 {
    m::mul_nz(a, b, field_nz())
}

#[inline(always)]
fn scl(a: u256, b: u128) -> u256 {
    m::scl(a, b, field_nz())
}

#[inline(always)]
fn neg(b: u256) -> u256 {
    m::neg(b, FIELD)
}

#[inline(always)]
fn add(mut a: u256, mut b: u256) -> u256 {
    m::add(a, b, FIELD)
}

#[inline(always)]
fn sqr(mut a: u256) -> u256 {
    m::sqr_nz(a, field_nz())
}

#[inline(always)]
fn sub(mut a: u256, mut b: u256) -> u256 {
    m::sub(a, b, FIELD)
}

#[inline(always)]
fn div(a: u256, b: u256) -> u256 {
    m::div_nz(a, b, field_nz())
}

#[inline(always)]
fn inv(b: u256) -> u256 {
    m::inv(b, field_nz())
}
