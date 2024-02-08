use super::{u, {u::u128_over_add}, modulo};
use core::panic_with_felt252;
use result::Result::{Ok, Err};

#[inline(always)]
fn neg(b: u256, modulo: u256) -> u256 {
    modulo - b
}

#[inline(always)]
fn add_over(lhs: u256, rhs: u256) -> (u256, u128) implicits(RangeCheck) nopanic {
    let (high, overflow) = match u128_over_add(lhs.high, rhs.high) {
        Ok(high) => (high, 0),
        Err(high) => (high, 1),
    };
    match u128_over_add(lhs.low, rhs.low) {
        Ok(low) => (u256 { low, high }, overflow),
        Err(low) => {
            match u128_over_add(high, 1_u128) {
                Ok(high) => (u256 { low, high }, overflow),
                Err(high) => (u256 { low, high }, 1),
            }
        },
    }
}

#[inline(always)]
fn add_u(lhs: u256, rhs: u256) -> u256 implicits(RangeCheck) {
    let high = match u128_over_add(lhs.high, rhs.high) {
        Ok(high) => high,
        Err(high) => {
            panic_with_felt252('u256_add_u Overflow');
            high
        },
    };
    match u128_over_add(lhs.low, rhs.low) {
        Ok(low) => u256 { low, high },
        Err(low) => {
            let high = u128_over_add(high, 1_u128).expect('u256_add_u Overflow');
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
