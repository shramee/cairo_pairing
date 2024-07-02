use core::traits::TryInto;
use integer::{u512, u128_wide_mul,};
use super::{utils as u, reduce, u512_reduce};
// scale u512 by u128 (for smaller numbers)
// unreduced, returns u512 plus u128 (fifth limb) which needs handling
#[inline(always)]
fn u512_scl(a: u512, x: u128) -> (u512, u128) {
    let u512 { limb0, limb1, limb2, limb3 } = a;
    // (a1 + a2) * c
    let (limb1_part1, limb0) = u128_wide_mul(limb0, x);
    let (limb2_part1, limb1_part2) = u128_wide_mul(limb1, x);
    let limb1 = u::u128_wrapping_add(limb1_part1, limb1_part2);
    let (limb3_part1, limb2_part2) = u128_wide_mul(limb2, x);
    let limb2 = u::u128_wrapping_add(limb2_part1, limb2_part2);
    let (limb4, limb3_part2) = u128_wide_mul(limb3, x);
    let limb3 = u::u128_wrapping_add(limb3_part1, limb3_part2);
    (u512 { limb0, limb1, limb2, limb3 }, limb4)
}

// scale u256 by u128 (for smaller numbers)
// unreduced, returns u512
#[inline(always)]
fn scl_u(a: u256, b: u128) -> u512 {
    // (a1 + a2) * c
    let (limb1_part1, limb0) = u128_wide_mul(a.low, b);
    let (limb2, limb1_part2) = u128_wide_mul(a.high, b);
    let limb1 = u::u128_wrapping_add(limb1_part1, limb1_part2);
    u512 { limb0, limb1, limb2, limb3: 0 }
}

// scale u256 by u128 (for smaller numbers)
// takes non zero modulo
// returns modded u256
#[inline(always)]
fn scl_nz(a: u256, b: u128, modulo: NonZero<u256>) -> u256 {
    u512_reduce(scl_u(a, b), modulo)
}

// scale u256 by u128 (for smaller numbers)
// returns modded u256
#[inline(always)]
fn scl(a: u256, b: u128, modulo: NonZero<u256>) -> u256 {
    scl_nz(a, b, modulo.try_into().unwrap())
}

// mul two u256
// unreduced, returns u512
// #[inline(always)]
fn mul_u(a: u256, b: u256) -> u512 {
    let (limb1, limb0) = u128_wide_mul(a.low, b.low);
    let (limb2, limb1_part) = u128_wide_mul(a.low, b.high);
    let (limb1, limb1_overflow0) = u::u128_add_with_carry(limb1, limb1_part);
    let (limb2_part, limb1_part) = u128_wide_mul(a.high, b.low);
    let (limb1, limb1_overflow1) = u::u128_add_with_carry(limb1, limb1_part);
    let (limb2, limb2_overflow) = u::u128_add_with_carry(limb2, limb2_part);
    let (limb3, limb2_part) = u128_wide_mul(a.high, b.high);
    // No overflow since no limb4.
    let limb3 = u::u128_wrapping_add(limb3, limb2_overflow);
    let (limb2, limb2_overflow) = u::u128_add_with_carry(limb2, limb2_part);
    // No overflow since no limb4.
    let limb3 = u::u128_wrapping_add(limb3, limb2_overflow);
    // No overflow possible in this addition since both operands are 0/1.
    let limb1_overflow = u::u128_wrapping_add(limb1_overflow0, limb1_overflow1);
    let (limb2, limb2_overflow) = u::u128_add_with_carry(limb2, limb1_overflow);
    // No overflow since no limb4.
    let limb3 = u::u128_wrapping_add(limb3, limb2_overflow);

    u512 { limb0, limb1, limb2, limb3 }
}

// mul two u256
// takes non zero modulo
// returns modded u256
#[inline(always)]
fn mul_nz(a: u256, b: u256, modulo: NonZero<u256>) -> u256 {
    u512_reduce(mul_u(a, b), modulo)
}

// mul two u256
// returns modded u256
#[inline(always)]
fn mul(a: u256, b: u256, modulo: u256) -> u256 {
    mul_nz(a, b, modulo.try_into().unwrap())
}

// squares a u256
// unreduced, returns u512
// #[inline(always)]
fn sqr_u(a: u256) -> u512 {
    let (limb1, limb0) = u128_wide_mul(a.low, a.low);
    let (limb2, limb1_part) = u128_wide_mul(a.low, a.high);
    let (limb1, limb1_overflow0) = u::u128_add_with_carry(limb1, limb1_part);
    let (limb1, limb1_overflow1) = u::u128_add_with_carry(limb1, limb1_part);
    let (limb2, limb2_overflow) = u::u128_add_with_carry(limb2, limb2);
    let (limb3, limb2_part) = u128_wide_mul(a.high, a.high);
    // No overflow since no limb4.
    let limb3 = u::u128_wrapping_add(limb3, limb2_overflow);
    let (limb2, limb2_overflow) = u::u128_add_with_carry(limb2, limb2_part);
    // No overflow since no limb4.
    let limb3 = u::u128_wrapping_add(limb3, limb2_overflow);
    // No overflow possible in this addition since both operands are 0/1.
    let limb1_overflow = u::u128_wrapping_add(limb1_overflow0, limb1_overflow1);
    let (limb2, limb2_overflow) = u::u128_add_with_carry(limb2, limb1_overflow);
    // No overflow since no limb4.
    let limb3 = u::u128_wrapping_add(limb3, limb2_overflow);
    u512 { limb0, limb1, limb2, limb3 }
}

// squares a u256
// takes non zero modulo
// returns modded u256
#[inline(always)]
fn sqr_nz(a: u256, modulo: NonZero<u256>) -> u256 {
    u512_reduce(sqr_u(a), modulo)
}

// squares a u256
// takes non zero modulo
// returns modded u256
#[inline(always)]
fn sqr(a: u256, modulo: u256) -> u256 {
    u512_reduce(sqr_u(a), modulo.try_into().unwrap())
}
