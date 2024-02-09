use core::result::ResultTrait;
use super::{u, modulo};
use u::{u128_over_add, u128_over_sub};
use integer::u512;
use core::panic_with_felt252;
use result::Result;

#[inline(always)]
fn neg(b: u256, modulo: u256) -> u256 {
    modulo - b
}

#[inline(always)]
fn u256_over_add(lhs: u256, rhs: u256) -> Result<u256, u256> implicits(RangeCheck) nopanic {
    let (high, overflow) = match u128_over_add(lhs.high, rhs.high) {
        Result::Ok(high) => (high, false),
        Result::Err(high) => (high, true),
    };
    match u128_over_add(lhs.low, rhs.low) {
        Result::Ok(low) => if overflow {
            Result::Err(u256 { low, high })
        } else {
            Result::Ok(u256 { low, high })
        },
        Result::Err(low) => {
            match u128_over_add(high, 1_u128) {
                Result::Ok(high) => if overflow {
                    Result::Err(u256 { low, high })
                } else {
                    Result::Ok(u256 { low, high })
                },
                Result::Err(high) => Result::Err(u256 { low, high }),
            }
        },
    }
}

#[inline(always)]
fn u256_over_sub(lhs: u256, rhs: u256) -> Result<u256, u256> implicits(RangeCheck) nopanic {
    let (high, overflow) = match u128_over_sub(lhs.high, rhs.high) {
        Result::Ok(high) => (high, false),
        Result::Err(high) => (high, true),
    };
    match u128_over_sub(lhs.low, rhs.low) {
        Result::Ok(low) => if overflow {
            Result::Err(u256 { low, high })
        } else {
            Result::Ok(u256 { low, high })
        },
        Result::Err(low) => {
            match u128_over_sub(high, 1_u128) {
                Result::Ok(high) => if overflow {
                    Result::Err(u256 { low, high })
                } else {
                    Result::Ok(u256 { low, high })
                },
                Result::Err(high) => Result::Err(u256 { low, high }),
            }
        },
    }
}

#[inline(always)]
fn add_u(lhs: u256, rhs: u256) -> u256 implicits(RangeCheck) {
    let high = match u128_over_add(lhs.high, rhs.high) {
        Result::Ok(high) => high,
        Result::Err(high) => {
            panic_with_felt252('u256_add_u Overflow');
            high
        },
    };
    match u128_over_add(lhs.low, rhs.low) {
        Result::Ok(low) => u256 { low, high },
        Result::Err(low) => {
            let high = u128_over_add(high, 1_u128).expect('u256_add_u Overflow');
            u256 { low, high }
        },
    }
}

#[derive(Copy, Drop, Hash, PartialEq, Serde)]
struct u256X2 {
    low: u256,
    high: u256,
}

impl u256X2IntoU512 of Into<u256X2, u512> {
    fn into(self: u256X2) -> u512 {
        let u256X2{low, high } = self;
        u512 { limb0: low.low, limb1: low.high, limb2: high.low, limb3: high.high, }
    }
}

impl U512Intou256X2 of Into<u512, u256X2> {
    fn into(self: u512) -> u256X2 {
        let u512{limb0: low, limb1: high, limb2, limb3 } = self;
        u256X2 { low: u256 { low, high }, high: u256 { low: limb2, high: limb3 } }
    }
}

#[inline(always)]
fn add_u512(lhs: u512, rhs: u512) -> u512 implicits(RangeCheck) {
    let lhs: u256X2 = lhs.into();
    let rhs: u256X2 = rhs.into();

    // No overflow allowed
    let u256{low: limb2, high: limb3 } = u256_over_add(lhs.high, rhs.high)
        .expect('u512 add overflow');

    match u256_over_add(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0, high: limb1 }) => { u512 { limb0, limb1, limb2, limb3 } },
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_over_add(limb2, 1_u128) {
                Result::Ok(limb2) => u512 { limb0, limb1, limb2, limb3 },
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    let limb3 = u128_over_add(limb3, 1_u128).expect('u512 add overflow');
                    u512 { limb0, limb1, limb2, limb3 }
                },
            };
        },
    }
}

#[inline(always)]
fn sub_u512(lhs: u512, rhs: u512) -> u512 implicits(RangeCheck) {
    let lhs: u256X2 = lhs.into();
    let rhs: u256X2 = rhs.into();

    // No overflow allowed
    let u256{low: limb2, high: limb3 } = u256_over_sub(lhs.high, rhs.high)
        .expect('u512 sub overflow');

    match u256_over_sub(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0, high: limb1 }) => { u512 { limb0, limb1, limb2, limb3 } },
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_over_sub(limb2, 1_u128) {
                Result::Ok(limb2) => u512 { limb0, limb1, limb2, limb3 },
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    let limb3 = u128_over_sub(limb3, 1_u128).expect('u512 sub overflow');
                    u512 { limb0, limb1, limb2, limb3 }
                },
            };
        },
    }
}

#[inline(always)]
fn sub_u512_overflow(lhs: u512, rhs: u512) -> (u512, bool) implicits(RangeCheck) {
    let lhs: u256X2 = lhs.into();
    let rhs: u256X2 = rhs.into();

    // No overflow allowed
    let (u256{low: limb2, high: limb3 }, overflow) = match u256_over_sub(lhs.high, rhs.high) {
        Result::Ok(v) => (v, false),
        Result::Err(v) => (v, true)
    };

    match u256_over_sub(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0,
        high: limb1 }) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_over_sub(limb2, 1_u128) {
                Result::Ok(limb2) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    match u128_over_sub(limb3, 1_u128) {
                        Result::Ok(v) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                        Result::Err(v) => (u512 { limb0, limb1, limb2, limb3 }, true)
                    }
                },
            };
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
