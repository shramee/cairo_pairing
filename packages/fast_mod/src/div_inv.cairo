use core::integer::u512;
use super::{mul_u, mul_nz};
// Inversion
#[inline(always)]
pub fn inv(b: u256, modulo: NonZero<u256>) -> u256 {
    core::math::u256_inv_mod(b, modulo).expect('inversion failed').into()
}

// Division with Non Zero
#[inline(always)]
pub fn div_nz(a: u256, b: u256, modulo_nz: NonZero<u256>) -> u256 {
    mul_nz(a, inv(b, modulo_nz), modulo_nz)
}

// Division unreduced
#[inline(always)]
pub fn div_u(a: u256, b: u256, modulo_nz: NonZero<u256>) -> u512 {
    mul_u(a, inv(b, modulo_nz))
}

// Division - Easy
#[inline(always)]
pub fn div(a: u256, b: u256, modulo: u256) -> u256 {
    let modulo_nz = modulo.try_into().expect('0 modulo');
    div_nz(a, b, modulo_nz)
}
