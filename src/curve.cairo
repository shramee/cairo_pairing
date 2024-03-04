use core::option::OptionTrait;
use core::traits::TryInto;
mod constants;
mod groups;

use constants::{
    T, ORDER, FIELD, FIELD_X2, FIELDSQLOW, FIELDSQHIGH, U256_MOD_FIELD, U256_MOD_FIELD_INV, B,
    t_naf, field_nz
};
use constants::{ATE_LOOP_COUNT, LOG_ATE_LOOP_COUNT, six_t_plus_2_naf_rev_except_first};
use bn::fields::print::u512Display;
// #[cfg(test)]
// mod groups_tests;

mod pairing {
    mod miller_utils;
    mod tate_bkls;
// #[cfg(test)]
// mod tests;
}

use bn::fields as f;
use bn::math::fast_mod as m;
use m::{u512};
use m::utils::u128_overflowing_sub;
use m::{add_u, sub_u, mul_u, sqr_u, scl_u, reduce, u512_add, u512_sub};
use m::{u512_add_u256, u512_sub_u256, u512_add_overflow, u512_sub_overflow, u512_scl, u512_reduce};
use m::{Tuple2Add, Tuple2Sub, Tuple3Add, Tuple3Sub};

#[inline(always)]
fn u512_high_add(lhs: u512, rhs: u256) -> u512 {
    m::u512_high_add(lhs, rhs).expect('u512_high_add overflow')
}

#[inline(always)]
fn u512_high_sub(lhs: u512, rhs: u256) -> u512 {
    m::u512_high_sub(lhs, rhs).expect('u512_high_sub overflow')
}


#[generate_trait]
impl U512Fq2Ops of U512Fq2OpsTrait {
    #[inline(always)]
    fn u_add(self: (u512, u512), rhs: (u512, u512)) -> (u512, u512) {
        let (L0, L1) = self;
        let (R0, R1) = rhs;
        // Operation without modding can only be done like 4 times
        (u512_add(L0, R0), u512_add(L1, R1))
    }

    #[inline(always)]
    fn u_sub(self: (u512, u512), rhs: (u512, u512)) -> (u512, u512) {
        let (L0, L1) = self;
        let (R0, R1) = rhs;
        // Operation without modding can only be done like 4 times
        (u512_sub(L0, R0), u512_sub(L1, R1))
    }
}

// This fixes overflow breaking mod
// Tell this guys what's safe to add or subtract
// And it will proceed optimally avoiding overflow
#[inline(always)]
fn fix_overflow(result: u256, sub: u256, add: u256) -> u256 {
    match u128_overflowing_sub(sub.high, result.high) {
        // If sub >= result, then we add
        Result::Ok(_) => m::u256_overflow_add(result, add).expect('fix overflow add failed'),
        // If sub < result, then we subtract
        Result::Err(_) => m::u256_overflow_sub(result, sub).expect('fix overflow sub failed'),
    }
}

// This fixes overflow breaking mod
// Tell this guys what's safe to add or subtract
// And it will proceed optimally avoiding overflow
#[inline(always)]
fn fix_overflow_u512(result: u512, sub: u256, add: u256) -> u512 {
    let u512 { limb0, limb1, limb2, limb3 } = result;
    let u512_high = u256 { low: limb2, high: limb3 };
    let u256 { low: limb2, high: limb3 } = fix_overflow(u512_high, sub, add);
    u512 { limb0, limb1, limb2, limb3 }
}

#[inline(always)]
fn add_u_wrapping(lhs: u256, rhs: u256) -> u256 {
    match m::u256_overflow_add(lhs, rhs) {
        Result::Ok(res) => res,
        Result::Err(res) => fix_overflow(res, U256_MOD_FIELD_INV, U256_MOD_FIELD),
    }
}

impl U512BnAdd of Add<u512> {
    // Adds u512 for bn field
    fn add(lhs: u512, rhs: u512) -> u512 {
        let (result, overflow) = u512_add_overflow(lhs, rhs);
        if overflow {
            // 278 % 61 = 34
            // (278 - 256) + (256 % 61) % 61 = 34
            // OR, ((x - a) + (a % b)) % b == x % b
            // For `a` as `2**256` and `b` as `FIELD` and overflow `result` as `x - a`
            // result + (2**256 % FIELD) fixes overflow error
            // U256_MOD_FIELD is precompute of 2**256 % FIELD
            // So we can either add U256_MOD_FIELD or subtract U256_MOD_FIELD_INV
            fix_overflow_u512(result, U256_MOD_FIELD_INV, U256_MOD_FIELD)
        } else {
            result
        }
    }
}

impl U512BnSub of Sub<u512> {
    // Subtracts u512 for bn field
    fn sub(lhs: u512, rhs: u512) -> u512 {
        let (result, overflow) = u512_sub_overflow(lhs, rhs);
        if overflow {
            // -13 % 61 = 48
            // (100 + -13) - (100 % 61) % 61 = 52
            // ((x + a) - (a % b)) % b == x % b
            // So, subbing `a` as `2**256` and `b` as `FIELD`, `x + a` as `result`
            // result - (2**256 % FIELD) fixes overflow error
            // U256_MOD_FIELD is precompute of 2**256 % FIELD
            // So we can either subtract U256_MOD_FIELD or add U256_MOD_FIELD
            fix_overflow_u512(result, U256_MOD_FIELD, U256_MOD_FIELD_INV)
        } else {
            result
        }
    }
}

#[inline(always)]
fn u512_reduce_bn(a: u512) -> u256 {
    u512_reduce(a, FIELD.try_into().unwrap())
}

#[inline(always)]
fn u512_scl_9(a: u512) -> u512 {
    let u512 { limb0, limb1, limb2: low, limb3: high, } = a;
    let u256 { low: limb2, high: limb3 } = reduce(u256 { high, low }, FIELD.try_into().unwrap());
    let (result, overflow) = u512_scl(u512 { limb0, limb1, limb2, limb3, }, 9);

    if (overflow == 0) {
        result
    } else {
        fix_overflow_u512(result, U256_MOD_FIELD_INV, U256_MOD_FIELD)
    }
}

// ξ = 9 + i
fn mul_by_xi(t: (u512, u512)) -> (u512, u512) {
    let (t0, t1): (u512, u512) = t;
    (u512_scl_9(t0) - t1, //
     t0 + u512_scl_9(t1))
}

#[inline(always)]
fn mul_by_v(
    t: ((u512, u512), (u512, u512), (u512, u512)),
) -> ((u512, u512), (u512, u512), (u512, u512)) {
    // https://github.com/paritytech/bn/blob/master/src/fields/fq6.rs#L110
    let (t0, t1, t2) = t;
    (mul_by_xi(t2), t0, t1,)
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
