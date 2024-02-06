mod groups;

#[cfg(test)]
mod groups_tests;

mod pairing {
    mod miller_utils;
    mod bkls_tate;
    mod final_exponentiation;
}

use bn::fields as f;
// These paramas from:
// https://hackmd.io/@jpw/bn254

const X: u64 = 4965661367192848881;

#[inline(always)]
fn x_naf() -> Array<(bool, bool)> {
    // https://codegolf.stackexchange.com/questions/235319/convert-to-a-non-adjacent-form#answer-235327
    // JS function, f=n=>n?f(n+n%4n/3n>>1n)+'OPON'[n%4n]:''
    // When run with X, f(4965661367192848881n)
    // returns POOOPOPOONOPOPONOOPOPONONONOPOOOPOOPOPOPONOPOOPOOOOPOPOOOONOOOP
    // Reverses the array and outputs tt for P and tf for 
    array![
        (true, true),
        (false, false),
        (false, false),
        (false, false),
        (true, false),
        (false, false),
        (false, false),
        (false, false),
        (false, false),
        (true, true),
        (false, false),
        (true, true),
        (false, false),
        (false, false),
        (false, false),
        (false, false),
        (true, true),
        (false, false),
        (false, false),
        (true, true),
        (false, false),
        (true, false),
        (false, false),
        (true, true),
        (false, false),
        (true, true),
        (false, false),
        (true, true),
        (false, false),
        (false, false),
        (true, true),
        (false, false),
        (false, false),
        (false, false),
        (true, true),
        (false, false),
        (true, false),
        (false, false),
        (true, false),
        (false, false),
        (true, false),
        (false, false),
        (true, true),
        (false, false),
        (true, true),
        (false, false),
        (false, false),
        (true, false),
        (false, false),
        (true, true),
        (false, false),
        (true, true),
        (false, false),
        (true, false),
        (false, false),
        (false, false),
        (true, true),
        (false, false),
        (true, true),
        (false, false),
        (false, false),
        (false, false),
        (true, true),
    ]
}

const ORDER: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
// 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
const FIELD: u256 = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
const B: u256 = 3;

const ATE_LOOP_COUNT: u128 = 29793968203157093288;
const LOG_ATE_LOOP_COUNT: u128 = 63;

#[inline(always)]
fn field_nz() -> NonZero<u256> {
    FIELD.try_into().unwrap()
}

#[inline(always)]
fn mul(a: u256, b: u256) -> u256 {
    bn::fast_mod::mul_nz(a, b, field_nz())
}

#[inline(always)]
fn scale(a: u256, b: u128) -> u256 {
    bn::fast_mod::scale(a, b, field_nz())
}

#[inline(always)]
fn add_inverse(b: u256) -> u256 {
    bn::fast_mod::add_inverse(b, FIELD)
}

#[inline(always)]
fn add(mut a: u256, mut b: u256) -> u256 {
    bn::fast_mod::add(a, b, FIELD)
}

#[inline(always)]
fn sqr(mut a: u256) -> u256 {
    bn::fast_mod::sqr_nz(a, field_nz())
}

#[inline(always)]
fn sub(mut a: u256, mut b: u256) -> u256 {
    bn::fast_mod::sub(a, b, FIELD)
}

#[inline(always)]
fn div(a: u256, b: u256) -> u256 {
    bn::fast_mod::div_nz(a, b, field_nz())
}

#[inline(always)]
fn inv(b: u256) -> u256 {
    bn::fast_mod::inv(b, field_nz())
}
