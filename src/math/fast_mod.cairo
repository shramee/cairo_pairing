// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

use integer::u512;

// util functions
mod utils;
use utils::{u256_overflow_add, u256_overflow_sub};
// endregion util functions

// u512_ops
mod u512_ops;

use u512_ops::{u512Add, u512Sub, u512_add, u512_sub, u512_pad, u512_sub_pad};
// endregion u512_ops

// region add/sub operation
mod add_sub;

use add_sub::{neg, add, add_nz, add_u, sub};
// endregion add/sub operation

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
