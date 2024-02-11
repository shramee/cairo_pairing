use integer::{u128_overflowing_add, u128_overflowing_sub, u512};

#[inline(always)]
fn u128_wrapping_add(lhs: u128, rhs: u128) -> u128 implicits(RangeCheck) nopanic {
    match u128_overflowing_add(lhs, rhs) {
        Result::Ok(x) => x,
        Result::Err(x) => x,
    }
}

#[inline(always)]
fn u128_add_with_carry(a: u128, b: u128) -> (u128, u128) nopanic {
    match u128_overflowing_add(a, b) {
        Result::Ok(v) => (v, 0),
        Result::Err(v) => (v, 1),
    }
}

#[inline(always)]
fn u128_wrapping_sub(lhs: u128, rhs: u128) -> u128 implicits(RangeCheck) nopanic {
    match u128_overflowing_sub(lhs, rhs) {
        Result::Ok(x) => x,
        Result::Err(x) => x,
    }
}

#[inline(always)]
fn u256_overflow_add(lhs: u256, rhs: u256) -> Result<u256, u256> implicits(RangeCheck) nopanic {
    let (high, overflow) = match u128_overflowing_add(lhs.high, rhs.high) {
        Result::Ok(high) => (high, false),
        Result::Err(high) => (high, true),
    };
    match u128_overflowing_add(lhs.low, rhs.low) {
        Result::Ok(low) => if overflow {
            Result::Err(u256 { low, high })
        } else {
            Result::Ok(u256 { low, high })
        },
        Result::Err(low) => {
            match u128_overflowing_add(high, 1_u128) {
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
fn u256_overflow_sub(lhs: u256, rhs: u256) -> Result<u256, u256> implicits(RangeCheck) nopanic {
    let (high, overflow) = match u128_overflowing_sub(lhs.high, rhs.high) {
        Result::Ok(high) => (high, false),
        Result::Err(high) => (high, true),
    };
    match u128_overflowing_sub(lhs.low, rhs.low) {
        Result::Ok(low) => if overflow {
            Result::Err(u256 { low, high })
        } else {
            Result::Ok(u256 { low, high })
        },
        Result::Err(low) => {
            match u128_overflowing_sub(high, 1_u128) {
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
fn u256_wrapping_add(lhs: u256, rhs: u256) -> u256 implicits(RangeCheck) nopanic {
    let high = match u128_overflowing_add(lhs.high, rhs.high) {
        Result::Ok(high) => high,
        Result::Err(high) => high,
    };
    match u128_overflowing_add(lhs.low, rhs.low) {
        Result::Ok(low) => u256 { low, high },
        Result::Err(low) => {
            match u128_overflowing_add(high, 1_u128) {
                Result::Ok(high) => u256 { low, high },
                Result::Err(high) => u256 { low, high },
            }
        },
    }
}

#[inline(always)]
fn u256_wrapping_sub(lhs: u256, rhs: u256) -> u256 implicits(RangeCheck) nopanic {
    let high = match u128_overflowing_sub(lhs.high, rhs.high) {
        Result::Ok(high) => high,
        Result::Err(high) => high,
    };
    match u128_overflowing_sub(lhs.low, rhs.low) {
        Result::Ok(low) => u256 { low, high },
        Result::Err(low) => {
            match u128_overflowing_sub(high, 1_u128) {
                Result::Ok(high) => u256 { low, high },
                Result::Err(high) => u256 { low, high },
            }
        },
    }
}

#[inline(always)]
fn expect_u256(result: Result<u256, u256>, panic_msg: felt252) -> u256 {
    match result {
        Result::Ok(value) => value,
        Result::Err(value) => {
            panic_with_felt252(panic_msg);
            value
        },
    }
}

#[inline(always)]
fn expect_u128(result: Result<u128, u128>, panic_msg: felt252) -> u128 {
    match result {
        Result::Ok(value) => value,
        Result::Err(value) => {
            panic_with_felt252(panic_msg);
            value
        },
    }
}
