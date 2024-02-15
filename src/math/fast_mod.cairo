// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

use integer::u512;

// util functions
mod utils;
use utils::{u256_overflow_add, u256_overflow_sub};
use utils::{Tuple2Add, Tuple2Sub, Tuple3Add, Tuple3Sub, u512Display};
// endregion util functions

// u512_ops
mod u512_ops;

use u512_ops::{u512_add, u512_add_overflow, u512_sub, u512_sub_overflow,};
use u512_ops::{u512_high_add, u512_high_sub, u512_reduce, u512_add_u256, u512_sub_u256};
// endregion u512_ops

// region add/sub operation
mod add_sub;

use add_sub::{neg, add, add_nz, add_u, sub};
// endregion add/sub operation

// region mul operations
mod mul_scale_sqr;

use mul_scale_sqr::{scl, scl_nz, scl_u, mul, mul_nz, mul_u, sqr, sqr_nz, sqr_u, u512_scl};
// endregion mul operations

// region div/inv operations
mod div_inv;
use div_inv::{inv, div, div_nz, div_u};
// endregion div/inv operations

#[inline(always)]
fn reduce(lhs: u256, modulo: NonZero<u256>) -> u256 {
    let (_, r, _) = integer::u256_safe_divmod(lhs, modulo);
    r
}
