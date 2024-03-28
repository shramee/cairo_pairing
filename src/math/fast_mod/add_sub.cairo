use core::result::ResultTrait;
use super::{utils as u, reduce};
use u::{u128_overflowing_add, u128_overflowing_sub, u256_overflow_sub, u256_wrapping_add};
use integer::u512;
use core::panic_with_felt252;
use result::Result;

#[inline(always)]
fn neg(b: u256, modulo: u256) -> u256 {
    modulo - b
}

#[inline(always)]
fn add_u(lhs: u256, rhs: u256) -> u256 implicits(RangeCheck) {
    let high = u::expect_u128(u128_overflowing_add(lhs.high, rhs.high), 'u256_add_u Overflow');
    match u128_overflowing_add(lhs.low, rhs.low) {
        Result::Ok(low) => u256 { low, high },
        Result::Err(low) => {
            let high = u::expect_u128(u128_overflowing_add(high, 1), 'u256_add_u Overflow');
            u256 { low, high }
        },
    }
}

#[inline(always)]
fn sub_u(lhs: u256, rhs: u256) -> u256 implicits(RangeCheck) {
    let high = u::expect_u128(u128_overflowing_sub(lhs.high, rhs.high), 'u256_sub_u Overflow');
    match u128_overflowing_sub(lhs.low, rhs.low) {
        Result::Ok(low) => u256 { low, high },
        Result::Err(low) => {
            let high = u::expect_u128(u128_overflowing_sub(high, 1), 'u256_sub_u Overflow');
            u256 { low, high }
        },
    }
}

#[inline(always)]
fn add_nz(mut a: u256, mut b: u256, modulo: NonZero<u256>) -> u256 {
    super::reduce(add_u(a, b), modulo)
}

#[inline(always)]
fn add(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    let res = add_u(a, b);
    match u256_overflow_sub(res, modulo) {
        Result::Ok(v) => v,
        Result::Err(_) => res
    }
}

#[inline(always)]
fn sub(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    match u256_overflow_sub(a, b) {
        Result::Ok(v) => v,
        Result::Err(v) => u256_wrapping_add(v, modulo)
    }
}
