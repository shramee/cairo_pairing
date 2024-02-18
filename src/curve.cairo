use core::option::OptionTrait;
use core::traits::TryInto;
mod constants;
mod groups;

use constants::{
    X, ORDER, FIELD, FIELD_X2, FIELDSQLOW, FIELDSQHIGH, U512_MOD_FIELD, U512_MOD_FIELD_INV, B,
    x_naf, u512_overflow_precompute_add
};
use constants::{ATE_LOOP_COUNT, LOG_ATE_LOOP_COUNT};
use bn::fields::print::u512Display;
// #[cfg(test)]
// mod groups_tests;

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
use m::{add_u, mul_u, sqr_u, scl_u, reduce};
use m::{u512_add_u256, u512_sub_u256, u512_add_overflow, u512_sub_overflow, u512_scl, u512_reduce};
use m::{Tuple2Add, Tuple2Sub};

#[inline(always)]
fn fix_overflow(result: u512, sub: u256, add: u256) -> u512 {
    let u512{limb0, limb1, limb2, limb3 } = result;
    let u512_low = u256 { low: limb0, high: limb1 };

    if limb1 > sub.high {
        // Safe to sub, no overflow
        // Try to fix mod with sub
        // println!("Fixing ADD overflow with sub");
        let mod_fix = m::u256_overflow_sub(u512_low, sub).unwrap();
        u512 { limb0: mod_fix.low, limb1: mod_fix.high, limb2, limb3 }
    } else {
        // println!("Fixing ADD overflow with add");
        let mod_fix = m::u256_overflow_add(u512_low, add).unwrap();
        u512 { limb0: mod_fix.low, limb1: mod_fix.high, limb2, limb3 }
    }
}

impl U512BnAdd of Add<u512> {
    #[inline(always)]
    fn add(lhs: u512, rhs: u512) -> u512 {
        let (result, overflow) = u512_add_overflow(lhs, rhs);
        if overflow {
            // 278 % 61 = 34
            // (278 - 256) + (256 % 61) % 61 = 34
            // OR, ((x - a) + (a % b)) % b == x % b
            // For `a` as `2**256` and `b` as `FIELD` and overflow `result` as `x - a`
            // result + (2**256 % FIELD) fixes overflow error
            // U512_MOD_FIELD is precompute of 2**256 % FIELD
            // So we can either add U512_MOD_FIELD or subtract U512_MOD_FIELD_INV
            fix_overflow(result, U512_MOD_FIELD_INV, U512_MOD_FIELD)
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
            // -13 % 61 = 48
            // (100 + -13) - (100 % 61) % 61 = 52
            // ((x + a) - (a % b)) % b, x + b
            // So, subbing `a` as `2**256` and `b` as `FIELD`, `x + a` as `result`
            // result - (2**256 % FIELD) fixes overflow error
            // U512_MOD_FIELD is precompute of 2**256 % FIELD
            // So we can either subtract U512_MOD_FIELD or add U512_MOD_FIELD
            fix_overflow(result, U512_MOD_FIELD, U512_MOD_FIELD_INV)
        } else {
            result
        }
    }
}

#[inline(always)]
fn u512_scl_9(a: u512, u512_overflow_precompute_add: Span<u256>) -> u512 {
    let u512{limb0, limb1, limb2: low, limb3: high, } = a;
    let u256{low: limb2, high: limb3 } = reduce(u256 { high, low }, FIELD.try_into().unwrap());
    let (result, overflow) = u512_scl(u512 { limb0, limb1, limb2, limb3, }, 9);

    if (overflow == 0) {
        result
    } else {
        fix_overflow(result, U512_MOD_FIELD_INV, U512_MOD_FIELD)
    }
}

#[inline(always)]
fn u512_reduce_bn(a: u512) -> u256 {
    u512_reduce(a, FIELD.try_into().unwrap())
}

// ξ = 9 + i
#[inline(always)]
fn mul_by_xi(t: (u512, u512), u512_overflow_precompute_add: Span<u256>) -> (u512, u512) {
    let (mut t0, mut t1): (u512, u512) = t;
    (
        u512_scl_9(t0, u512_overflow_precompute_add) - t1, //
        t0 + u512_scl_9(t1, u512_overflow_precompute_add)
    )
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
