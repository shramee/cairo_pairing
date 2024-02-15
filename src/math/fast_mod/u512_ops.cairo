use integer::u512;
use super::utils::{
    u256_wrapping_add, u256_overflow_add, u256_overflow_sub, u128_overflowing_add,
    u256_wrapping_sub, u128_overflowing_sub, expect_u256, expect_u128
};

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
    let u256{low: limb2, high: limb3 } = expect_u256(
        u256_overflow_add(lhs.high, rhs.high), 'u512 add overflow'
    );

    match u256_overflow_add(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0, high: limb1 }) => { u512 { limb0, limb1, limb2, limb3 } },
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_overflowing_add(limb2, 1_u128) {
                Result::Ok(limb2) => u512 { limb0, limb1, limb2, limb3 },
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    let limb3 = expect_u128(
                        u128_overflowing_add(limb3, 1_u128), 'u512 add overflow'
                    );
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
                        Result::Ok(limb3) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                        Result::Err(limb3) => (u512 { limb0, limb1, limb2, limb3 }, true)
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
    let u256{low: limb2, high: limb3 } = expect_u256(
        u256_overflow_sub(lhs.high, rhs.high), 'u512 sub overflow'
    );

    match u256_overflow_sub(lhs.low, rhs.low) {
        Result::Ok(u256{low: limb0, high: limb1 }) => { u512 { limb0, limb1, limb2, limb3 } },
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_overflowing_sub(limb2, 1_u128) {
                Result::Ok(limb2) => u512 { limb0, limb1, limb2, limb3 },
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    let limb3 = expect_u128(
                        u128_overflowing_sub(limb3, 1_u128), 'u512 sub overflow'
                    );
                    u512 { limb0, limb1, limb2, limb3 }
                },
            };
        },
    }
}

#[inline(always)]
fn u512_add_u256(lhs: u512, rhs: u256) -> (u512, bool) {
    let u256X2{high, low }: u256X2 = lhs.into();
    let u256{high: limb3, low: limb2 } = high;

    match u256_overflow_add(low, rhs) {
        Result::Ok(u256{low: limb0, high: limb1 }) => (u512 { limb0, limb1, limb2, limb3 }, false),
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            match u128_overflowing_add(limb2, 1_u128) {
                Result::Ok(limb2) => (u512 { limb0, limb1, limb2, limb3 }, false),
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    match u128_overflowing_add(limb3, 1_u128) {
                        Result::Ok(limb3) => (u512 { limb0, limb1, limb2, limb3 }, false),
                        Result::Err(limb3) => (u512 { limb0, limb1, limb2, limb3 }, true),
                    }
                },
            }
        },
    }
}

#[inline(always)]
fn u512_sub_u256(lhs: u512, rhs: u256) -> (u512, bool) {
    let u256X2{high, low }: u256X2 = lhs.into();
    let u256{high: limb3, low: limb2 } = high;

    match u256_overflow_sub(low, rhs) {
        Result::Ok(u256{low: limb0, high: limb1 }) => (u512 { limb0, limb1, limb2, limb3 }, false),
        Result::Err(u256{low: limb0,
        high: limb1 }) => {
            // Try to move overflow to limb2
            return match u128_overflowing_sub(limb2, 1_u128) {
                Result::Ok(limb2) => (u512 { limb0, limb1, limb2, limb3 }, false),
                Result::Err(limb2) => {
                    // Try to move overflow to limb3
                    match u128_overflowing_sub(limb3, 1_u128) {
                        Result::Ok(limb3) => (u512 { limb0, limb1, limb2, limb3 }, false),
                        Result::Err(limb3) => (u512 { limb0, limb1, limb2, limb3 }, true),
                    }
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
                        Result::Ok(limb3) => (u512 { limb0, limb1, limb2, limb3 }, overflow),
                        Result::Err(limb3) => (u512 { limb0, limb1, limb2, limb3 }, true)
                    }
                },
            };
        },
    }
}

// add a u256 to high limbs of u512
// this beautiful beautiful function converts a `-x mod 2**512` to `x mod rhs`
#[inline(always)]
fn u512_high_add(lhs: u512, rhs: u256) -> Result<u512, u512> {
    let u512{limb0, limb1, limb2: low, limb3: high } = lhs;
    let lhs = u256 { low, high };
    match u256_overflow_add(lhs, rhs) {
        Result::Ok(u256{low: limb2,
        high: limb3 }) => Result::Ok(u512 { limb0, limb1, limb2, limb3 }),
        Result::Err(u256{low: limb2,
        high: limb3 }) => Result::Err(u512 { limb0, limb1, limb2, limb3 })
    }
}

// subtracts u256 from high limbs of u512
// this beautiful beautiful function can convert an overflown `2**512 + x mod rhs` to equivalent `y mod rhs`
#[inline(always)]
fn u512_high_sub(lhs: u512, rhs: u256) -> Result<u512, u512> {
    let u512{limb0, limb1, limb2: low, limb3: high } = lhs;
    let lhs = u256 { low, high };
    match u256_overflow_sub(lhs, rhs) {
        Result::Ok(u256{low: limb2,
        high: limb3 }) => Result::Ok(u512 { limb0, limb1, limb2, limb3 }),
        Result::Err(u256{low: limb2,
        high: limb3 }) => Result::Err(u512 { limb0, limb1, limb2, limb3 })
    }
}

#[inline(always)]
fn u512_reduce(a: u512, modulo: NonZero<u256>) -> u256 {
    let (_, rem_u256, _, _, _, _, _) = integer::u512_safe_divmod_by_u256(a, modulo);
    rem_u256
}

