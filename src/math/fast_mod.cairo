// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

use integer::u512;
// util functions
// cost saving with inline
mod u {
    use integer::{u128_overflowing_add as u128_over_add, u128_overflowing_sub as u128_over_sub};
    #[inline(always)]
    fn u128_wrapping_add(lhs: u128, rhs: u128) -> u128 implicits(RangeCheck) nopanic {
        match u128_over_add(lhs, rhs) {
            Result::Ok(x) => x,
            Result::Err(x) => x,
        }
    }

    #[inline(always)]
    fn u128_add_with_carry(a: u128, b: u128) -> (u128, u128) nopanic {
        match u128_over_add(a, b) {
            Result::Ok(v) => (v, 0),
            Result::Err(v) => (v, 1),
        }
    }
}


// region add/sub operation
mod add_sub;

use add_sub::{neg, add, add_nz, add_u, sub, u256_over_add, u256_over_sub, add_u512, sub_u512};


impl u512Add of Add<u512> {
    fn add(lhs: u512, rhs: u512) -> u512 {
        add_u512(lhs, rhs)
    }
}

impl u512Sub of Sub<u512> {
    fn sub(lhs: u512, rhs: u512) -> u512 {
        sub_u512(lhs, rhs)
    }
}

// end region add/sub operation

// region mul operations
mod mul_scale_sqr;

use mul_scale_sqr::{scl, scl_nz, scl_u, mul, mul_nz, mul_u, sqr, sqr_nz, sqr_u};
// endregion mul operations

// region div/inv operations
mod div_inv;
use div_inv::{inv, div, div_nz, div_u};
// endregion div/inv operations

#[inline(always)]
fn modulo(lhs: u256, modulo: NonZero<u256>) -> u256 {
    let (q, r, _) = integer::u256_safe_divmod(lhs, modulo);
    r
}

#[inline(always)]
fn mod_512(a: u512, modulo: NonZero<u256>) -> u256 {
    let (_, rem_u256, _, _, _, _, _) = integer::u512_safe_divmod_by_u256(a, modulo);
    rem_u256
}
