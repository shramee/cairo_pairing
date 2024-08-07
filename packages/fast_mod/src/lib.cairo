// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

pub use core::integer::u512;

// util functions
#[feature("corelib-internal-use")]
pub mod utils;
pub use utils::{u256_overflow_add, u256_overflow_sub};
pub use utils::{Tuple2Add, Tuple2Sub, Tuple3Add, Tuple3Sub, u512Display};
// endregion util functions

// u512_ops
#[feature("corelib-internal-use")]
pub mod u512_ops;

pub use u512_ops::{u512_add, u512_add_overflow, u512_sub, u512_sub_overflow,};
pub use u512_ops::{u512_high_add, u512_high_sub, u512_reduce, u512_add_u256, u512_sub_u256};
// endregion u512_ops

// region add/sub operation
pub mod add_sub;

pub use add_sub::{neg, add, add_nz, add_u, sub, sub_u};
// endregion add/sub operation

// region mul operations
pub mod mul_scale_sqr;

pub use mul_scale_sqr::{scl, scl_nz, scl_u, mul, mul_nz, mul_u, sqr, sqr_nz, sqr_u, u512_scl};
// endregion mul operations

// region div/inv operations
pub mod div_inv;
pub use div_inv::{inv, div, div_nz, div_u};
// endregion div/inv operations

#[inline(always)]
pub fn reduce(lhs: u256, modulo: NonZero<u256>) -> u256 {
    let (_, r) = DivRem::div_rem(lhs, modulo);
    r
}

#[cfg(test)]
pub mod tests;

