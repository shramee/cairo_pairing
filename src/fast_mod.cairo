use core::option::OptionTrait;
use core::traits::TryInto;
use core::traits::Into;
// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

#[inline(always)]
fn mult_mod(a: u256, b: u256, modulo: u256) -> u256 {
    let mult = integer::u256_wide_mul(a, b);
    let (_, rem_u256, _, _, _, _, _) = integer::u512_safe_divmod_by_u256(
        mult, modulo.try_into().unwrap()
    );
    rem_u256
}

#[inline(always)]
fn add_inverse_mod(b: u256, modulo: u256) -> u256 {
    modulo - b
}

#[inline(always)]
fn add_mod(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    // Doesn't overflow coz we have at least one bit to spare
    (a + b) % modulo
}

#[inline(always)]
fn sub_mod(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    // reduce values
    if (a >= b) {
        a - b
    } else {
        (modulo - b) + a
    }
}

#[inline(always)]
fn div_mod(a: u256, b: u256, modulo: u256) -> u256 {
    let modulo_nz = modulo.try_into().expect('0 modulo');
    let inv = math::u256_inv_mod(b, modulo_nz).unwrap().into();
    math::u256_mul_mod_n(a, inv, modulo_nz)
}
