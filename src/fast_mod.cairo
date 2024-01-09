use core::traits::Into;
// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

use super::i257::{
    i257, i257Add, i257AddEq, i257Sub, i257SubEq, i257Mul, i257MulEq, i257Div, i257DivEq, i257Rem,
    i257RemEq, i257PartialEq, i257PartialOrd, i257Neg, U256IntoI257, FeltIntoI257
};
use alexandria_math::mod_arithmetics::{mult_mod};

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
    mult_mod(a, mult_inverse(b, modulo), modulo)
}

fn extended_gcd(a: i257, b: i257) -> (i257, i257) {
    let mut old_r = a.inner;
    let mut r = b.inner;
    let mut old_s: i257 = 1.into();
    let mut s: i257 = 0.into();

    loop {
        if r == 0 {
            break;
        }
        let (quotient, remainder) = integer::u256_safe_div_rem(
            old_r, r.try_into().expect('Division by 0')
        );
        let temp = r;
        r = remainder.into();
        old_r = temp;

        let temp = s;
        s = old_s - quotient.into() * s;
        old_s = temp;
    };

    (old_r.into(), old_s)
}

// Function to find modular inverse of x modulo f
#[inline(always)]
fn mult_inverse(x: u256, f: u256) -> u256 {
    // Calculate GCD and 's' coefficient using extended_gcd function
    let (gcd, mut s) = extended_gcd(x.into(), f.into());

    let s = if s.sign {
        f - (s.inner % f)
    } else {
        s.inner % f
    };

    // Return the modular inverse of x modulo f
    s % f
}
