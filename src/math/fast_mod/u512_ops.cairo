use integer::u512;
use super::utils::{
    u256_wrapping_add, u256_overflow_add, u256_overflow_sub, u128_overflowing_add,
    u128_overflowing_sub
};

impl u512Add of Add<u512> {
    #[inline(always)]
    fn add(lhs: u512, rhs: u512) -> u512 {
        let (sum, _) = u512_add_overflow(lhs, rhs);
        sum
    }
}

impl u512Sub of Sub<u512> {
    #[inline(always)]
    fn sub(lhs: u512, rhs: u512) -> u512 {
        let (difference, _) = u512_sub_overflow(lhs, rhs);
        difference
    // u512_sub(lhs, rhs)
    }
}

#[derive(Copy, Drop, Hash, PartialEq, Serde)]
struct u256X2 {
    low: u256,
    high: u256,
}

impl U512Intou256X2 of Into<u512, u256X2> {
    #[inline(always)]
    fn into(self: u512) -> u256X2 {
        let u512{limb0: low, limb1: high, limb2, limb3 } = self;
        u256X2 { low: u256 { low, high }, high: u256 { low: limb2, high: limb3 } }
    }
}

#[inline(always)]
fn u512_add(lhs: u512, rhs: u512) -> u512 {
    let lhs: u256X2 = lhs.into();
    let rhs: u256X2 = rhs.into();

    // No overflow allowed
    let u256{low: limb2, high: limb3 } = u256_overflow_add(lhs.high, rhs.high)
        .expect('u512 add overflow');

    match u256_overflow_add(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0, high: limb1 }) => { u512 { limb0, limb1, limb2, limb3 } },
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_overflowing_add(limb2, 1_u128) {
                Result::Ok(limb2) => u512 { limb0, limb1, limb2, limb3 },
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    let limb3 = u128_overflowing_add(limb3, 1_u128).expect('u512 add overflow');
                    u512 { limb0, limb1, limb2, limb3 }
                },
            };
        },
    }
}

#[inline(always)]
fn u512_add_overflow(lhs: u512, rhs: u512) -> (u512, bool) {
    let lhs: u256X2 = lhs.into();
    let rhs: u256X2 = rhs.into();

    // No overflow allowed
    let (u256{low: limb2, high: limb3 }, overflow) = match u256_overflow_add(lhs.high, rhs.high) {
        Result::Ok(v) => (v, false),
        Result::Err(v) => (v, true)
    };

    match u256_overflow_add(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0,
        high: limb1 }) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_overflowing_add(limb2, 1_u128) {
                Result::Ok(limb2) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    match u128_overflowing_add(limb3, 1_u128) {
                        Result::Ok(v) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                        Result::Err(v) => (u512 { limb0, limb1, limb2, limb3 }, true)
                    }
                },
            };
        },
    }
}

#[inline(always)]
fn u512_sub(lhs: u512, rhs: u512) -> u512 {
    let lhs: u256X2 = lhs.into();
    let rhs: u256X2 = rhs.into();

    // No overflow allowed
    let u256{low: limb2, high: limb3 } = u256_overflow_sub(lhs.high, rhs.high)
        .expect('u512 sub overflow');

    match u256_overflow_sub(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0, high: limb1 }) => { u512 { limb0, limb1, limb2, limb3 } },
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_overflowing_sub(limb2, 1_u128) {
                Result::Ok(limb2) => u512 { limb0, limb1, limb2, limb3 },
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    let limb3 = u128_overflowing_sub(limb3, 1_u128).expect('u512 sub overflow');
                    u512 { limb0, limb1, limb2, limb3 }
                },
            };
        },
    }
}

#[inline(always)]
fn u512_sub_overflow(lhs: u512, rhs: u512) -> (u512, bool) {
    let lhs: u256X2 = lhs.into();
    let rhs: u256X2 = rhs.into();

    // No overflow allowed
    let (u256{low: limb2, high: limb3 }, overflow) = match u256_overflow_sub(lhs.high, rhs.high) {
        Result::Ok(v) => (v, false),
        Result::Err(v) => (v, true)
    };

    match u256_overflow_sub(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0,
        high: limb1 }) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_overflowing_sub(limb2, 1_u128) {
                Result::Ok(limb2) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    match u128_overflowing_sub(limb3, 1_u128) {
                        Result::Ok(v) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                        Result::Err(v) => (u512 { limb0, limb1, limb2, limb3 }, true)
                    }
                },
            };
        },
    }
}

// This is a beautiful beautiful function
// This converts a negative mod 2**512 in mod rhs
#[inline(always)]
fn u512_pad(lhs: u512, rhs: u256) -> u512 {
    let u512{limb0, limb1, limb2: low, limb3: high } = lhs;
    let lhs = u256 { low, high };
    let u256{low: limb2, high: limb3 } = u256_wrapping_add(lhs, rhs);
    u512 { limb0, limb1, limb2, limb3 }
}

#[inline(always)]
fn u512_sub_pad(lhs: u512, rhs: u512, high_pad: u256) -> u512 {
    let (difference, _) = u512_sub_overflow(u512_pad(lhs, high_pad), rhs);
    difference
}
