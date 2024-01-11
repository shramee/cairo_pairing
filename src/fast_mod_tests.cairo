// REFERENCE: u128 operations in u256
// plain_div -> gas: 11450
// plain_add -> gas: 6830
// plain_mul -> gas: 21190
// plain_sub -> gas: 6830
//   mod_add -> gas: 17880
//   mod_mul -> gas: 52730
//   mod_div -> gas: 86500
//   mod_sub -> gas: 15710

use core::option::OptionTrait;
use core::traits::TryInto;
use cairo_ec::fast_mod::{add, sub, div, mul, add_inverse};
use cairo_ec::bn::curve::FIELD;
use debug::PrintTrait;

const a: u256 = 9099547013904003590785796930435194473319680151794113978918064868415326638035;
const b: u256 = 8021715850804026033197027745655159931503181100513576347155970296011118125764;


#[test]
#[available_gas(1000000)]
fn test_mod_add() {
    add(a, b, FIELD);
}

#[test]
#[available_gas(1000000)]
fn test_mod_sub() {
    sub(a, b, FIELD);
}

#[test]
#[available_gas(1000000)]
fn test_mod_mul() {
    let m = mul(a, b, FIELD);
}

#[test]
#[available_gas(100000000)]
fn test_mod_div() {
    let a = div(a, b, FIELD);
}
