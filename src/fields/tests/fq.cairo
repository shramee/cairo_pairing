use bn::traits::FieldOps;
use bn::fields::{fq, Fq, fq2, Fq2, FieldUtils};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use debug::PrintTrait;

fn fq_ops() -> Array<Fq> {
    array![ //
        fq(256) - fq(56), //
        fq(256) + fq(56), //
        fq(256) * fq(56), //
        fq(256) / fq(56), //
        -fq(256), //
    ]
}

use bn::fast_mod::bn254::{sub, add, mul, div, add_inverse,};

fn u256_mod_ops() -> Array<u256> {
    array![ //
        sub(256, 56), //
         add(256, 56), //
         mul(256, 56), //
         div(256, 56), //
         add_inverse(256), //
    ]
}

#[test]
#[available_gas(2000000)]
fn bench_fq() {
    fq_ops();
}

#[test]
#[available_gas(2000000)]
fn bench_raw() {
    u256_mod_ops();
}

#[test]
#[available_gas(0xf0000)]
fn inv_one() {
    let one: Fq = FieldUtils::one();
    assert(one.inv() == one, 'incorrect inverse of one');
}

#[test]
#[available_gas(0xf0000)]
fn fq_test_main() {
    let fq_res = fq_ops();
    let u256_mod_res = u256_mod_ops();

    let mut i = 0;
    loop {
        if i == fq_res.len() {
            break;
        }
        assert(fq_res.at(i).c0 == u256_mod_res.at(i), 'incorrect op 0' + i.into());
        i += 1;
    };
    assert((fq(256) == fq(56)) == false, 'incorrect eq');
    assert((fq(3294587623987546) == fq(3294587623987546)) == true, 'incorrect eq');
}
