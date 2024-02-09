use core::result::ResultTrait;
use super::{utils as u, modulo};
use u::{u128_overflowing_add, u128_overflowing_sub};
use integer::u512;
use core::panic_with_felt252;
use result::Result;

#[inline(always)]
fn neg(b: u256, modulo: u256) -> u256 {
    modulo - b
}

#[inline(always)]
fn add_u(lhs: u256, rhs: u256) -> u256 implicits(RangeCheck) {
    let high = u128_overflowing_add(lhs.high, rhs.high).expect('u256_add_u Overflow');
    match u128_overflowing_add(lhs.low, rhs.low) {
        Result::Ok(low) => u256 { low, high },
        Result::Err(low) => {
            let high = u128_overflowing_add(high, 1_u128).expect('u256_add_u Overflow');
            u256 { low, high }
        },
    }
}

#[inline(always)]
fn add_nz(mut a: u256, mut b: u256, modulo: NonZero<u256>) -> u256 {
    super::modulo(add_u(a, b), modulo)
}

#[inline(always)]
fn add(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    add_nz(a, b, modulo.try_into().unwrap())
}

#[inline(always)]
fn sub(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    // reduce values
    if (a < b) {
        (modulo - b) + a
    } else {
        a - b
    }
}
