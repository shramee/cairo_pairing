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
use bn::fast_mod::{add, sub, div, mul, add_inverse};
use bn::bn254::FIELD;
use debug::PrintTrait;

const a: u256 = 9099547013904003590785796930435194473319680151794113978918064868415326638035;
const b: u256 = 8021715850804026033197027745655159931503181100513576347155970296011118125764;

#[test]
#[available_gas(1000000)]
fn bench_add() {
    add(a, b, FIELD);
}

#[test]
#[available_gas(1000000)]
fn bench_sub() {
    sub(a, b, FIELD);
}

#[test]
#[available_gas(1000000)]
fn bench_mul() {
    mul(a, b, FIELD);
}

#[test]
#[available_gas(100000000)]
fn bench_div() {
    div(a, b, FIELD);
}

#[test]
#[available_gas(100000000)]
fn test_all_mod_ops() {
    let add_ = add(a, b, FIELD);
    assert(
        17121262864708029623982824676090354404822861252307690326074035164426444763799 == add_,
        'incorrect add'
    );
    let sub_ = sub(a, b, FIELD);
    assert(
        1077831163099977557588769184780034541816499051280537631762094572404208512271 == sub_,
        'incorrect sub'
    );
    let mul_ = mul(a, b, FIELD);
    assert(
        6561477752769399547014183440960600095569924911855714080305417693732453755033 == mul_,
        'incorrect mul'
    );
    let div_ = div(a, b, FIELD);
    assert(
        12819640619688655488085323601008678463608009668414428319642291645922931558321 == div_,
        'incorrect div'
    );
}
