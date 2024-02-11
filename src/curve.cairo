mod constants;
mod groups;

use constants::{X, ORDER, FIELD, FIELDSQLOW, FIELDSQHIGH, B, x_naf};
use constants::{ATE_LOOP_COUNT, LOG_ATE_LOOP_COUNT,};
#[cfg(test)]
mod groups_tests;

mod pairing {
    mod final_exponentiation;
    mod miller_utils;
    mod tate_bkls;
// #[cfg(test)]
// mod tests;
}

use bn::fields as f;
use bn::math::fast_mod as m;
use m::{u512};
use m::{add_u, mul_u, sqr_u, scl_u, u512_high_add, u512_high_sub, u512_add_u256, u512_sub_u256};
use m::{u512Tuple2Add, u512Tuple2Sub, u512_add_overflow, u512_sub_overflow};

impl U512BnAdd of Add<u512> {
    #[inline(always)]
    fn add(lhs: u512, rhs: u512) -> u512 {
        let (result, overflow) = u512_add_overflow(lhs, rhs);
        if overflow {
            // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
            // As described on page 7,
            // if c > 2^N·p, where c is the result of a double- precision addition,
            // then c can be restored with a cheaper single-precision sub- traction by 2^N·p
            // For p as FIELD, This function reduces values over FIELD·2^n
            // We do this on overflow
            u512_high_sub(result, FIELD)
        } else {
            result
        }
    }
}

impl U512BnSub of Sub<u512> {
    #[inline(always)]
    fn sub(lhs: u512, rhs: u512) -> u512 {
        let (result, overflow) = u512_sub_overflow(lhs, rhs);
        if overflow {
            // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
            // As described on page 7,
            // Option 2: if c < 0 then r = c + 2^N · p, r ∈ [ 0, 2N · p ].
            // For p as FIELD, This function reduces values over FIELD·2^n
            // If limb3 of a u512 is over FIELD.high, We subtract FIELD·2^N
            u512_high_add(result, FIELD)
        } else {
            result
        }
    }
}


// Faster Explicit Formulas for Computing Pairings over Ordinary Curves
// As described on page 7,
// if c > 2^N·p, where c is the result of a double- precision addition,
// then c can be restored with a cheaper single-precision sub- traction by 2^N·p
// For p as FIELD, This function reduces values over FIELD·2^n
// If limb3 of a u512 is over FIELD.high, We subtract FIELD·2^N
#[inline(always)]
fn u512_fix_high(int: u512) -> u512 {
    let u512{limb0, limb1, limb2, limb3 } = int;

    if int.limb3 > FIELD.high {
        u512_high_sub(int, FIELD)
    } else {
        int
    }
}

// Faster Explicit Formulas for Computing Pairings over Ordinary Curves
// As described on page 7,
// Option 2: if c < 0 then r = c + 2^N · p, r ∈ [ 0, 2N · p ].
// For p as FIELD, This function reduces values over FIELD·2^n
// If limb3 of a u512 is over FIELD.high, We subtract FIELD·2^N
#[inline(always)]
fn u512_fix_neg(int: u512) -> u512 {
    let u512{limb0, limb1, limb2, limb3 } = int;
    if int.limb3 > 0x80000000000000000000000000000000 {
        // If the result has last bit on, then it's sub overflow,
        // fix with addition 
        u512_high_add(int, FIELD)
    } else {
        int
    }
}

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
