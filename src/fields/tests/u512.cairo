use core::traits::TryInto;
use bn::traits::FieldOps;
use bn::curve::{FIELD, u512, U512BnAdd, U512BnSub, u512Display};
use bn::curve::{u512_reduce, u512_sub_u256, u512_add_u256, reduce};
use bn::fields::{fq, Fq, fq2, Fq2, FieldUtils, FqIntoU512Tuple, Fq2IntoU512Tuple};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use debug::PrintTrait;
const f30f: u128 = 0xffffffffffffffffffffffffffffffff;

// bi for big integer
#[inline(always)]
fn bi(limb3: u128, limb2: u128, limb1: u128, limb0: u128) -> u512 {
    u512 { limb0, limb1, limb2, limb3 }
}

#[test]
#[available_gas(2000000)]
fn u512_basic() {
    assert(bi(0, f30f, 2, 3) + bi(4, 5, 6, 7) == bi(5, 4, 8, 10), 'wrong u512 add');
    assert(bi(4, 5, 6, 7) - bi(0, 1, 2, 3) == bi(4, 4, 4, 4), 'wrong u512 sub');
}

#[test]
#[available_gas(20000000)]
fn u512_add_overflow() {
    let field_nz = get_field_nz();
    let a = bi(
        0xb644cf8c3632b365f7ecd91ecbc56e37,
        0x7c98ebc8858f41d26746b3b9cd81f524,
        0x93ca7d501004eb2b6f4b036038bee74e,
        0x31c521c84cd3126699cd3d7301276788,
    );

    let b = bi(
        0xf4b036038beeb644c014e31c521c84cd,
        0x312004eb2b676699cd3d7301276788c5,
        0x6e377c98ebc8858f41d26746b3b9cf8c,
        0x3632b365f7ecd91ecb3ca7d5d81f5249,
    );

    let b_large = bi(
        0xf4b036038beeb644c014e31c521c84cd,
        0x312004eb2b676699cd3d7301276788c5,
        // Larger less significant limbs are equivalent mod FIELD
        0xcf00197eae2bc5e2b272f2b3b6bc8047,
        0x65358888c8d06e39437dc00389194cd7
    );

    // c overflows with a small limb1
    // 0x1aaf5058fc22169aab801bc3b1de1f304adb8f0b3b0f6a86c348426baf4e97dea0201f9e8fbcd70bab11d6aa6ec78b6da67f7d52e44bfeb856509e548d946b9d1
    let c = a + b;
    let c_reduced = u512_reduce(c, field_nz);

    // c_large overflows with a large limb1
    let c_large = a + b_large;
    let c_large_reduced = u512_reduce(c_large, field_nz);

    // c mod FIELD should equal
    // 0x1aaf5058fc22169aab801bc3b1de1f304adb8f0b3b0f6a86c348426baf4e97dea0201f9e8fbcd70bab11d6aa6ec78b6da67f7d52e44bfeb856509e548d946b9d1 mod FIELD
    // = 0x62b58555709f7c875737862f99cf22dc374de2d9c2b4a847d0654732a1c2260
    let expect = 0x62b58555709f7c875737862f99cf22dc374de2d9c2b4a847d0654732a1c2260;

    assert(expect == c_reduced, 'wrong u512 add');
    assert(expect == c_large_reduced, 'wrong u512 add');
}

#[test]
#[available_gas(20000000)]
fn u512_u256_add() {
    let field_nz = get_field_nz();
    let a = bi(FIELD.high, FIELD.low, FIELD.high, FIELD.low,); // a = 0 mod FIELD
    let b = 0xf444d17ddb44b1e72ef0b482a1ceaaf4ec43dcc2c5a0b44f59c9ee33ed61806a;
    let b_r = reduce(b, field_nz);

    assert(b_r == u512_reduce(u512_add_u256(a, b), field_nz), 'u512_add_u256 mismatch');

    let a = bi(FIELD.high, FIELD.low, b.high, b.low,); // a = 0 mod FIELD
    assert(b_r == u512_reduce(u512_add_u256(a, FIELD), field_nz), 'u512_add_u256 mismatch');

    let a = bi(1, 1, f30f, f30f,); // a = 0 mod FIELD
    assert(bi(1, 2, 0, 0,) == u512_add_u256(a, 1), 'u512_add_u256 mismatch');

    let a = bi(1, f30f, f30f, f30f,); // a = 0 mod FIELD
    assert(bi(2, 0, 0, 0,) == u512_add_u256(a, 1), 'u512_add_u256 mismatch');
// assert(a_red - b.into(), '');
}

#[test]
#[available_gas(20000000)]
fn u512_u256_sub() {
    let field_nz = get_field_nz();
    let a = bi(FIELD.high, FIELD.low, FIELD.high, FIELD.low,); // a = 0 mod FIELD
    let b = 0xf444d17ddb44b1e72ef0b482a1ceaaf4ec43dcc2c5a0b44f59c9ee33ed61806a;
    let b_r = reduce(b, field_nz);

    assert(FIELD - b_r == u512_reduce(u512_sub_u256(a, b), field_nz), 'u512_sub_u256 mismatch');

    let a = bi(FIELD.high, FIELD.low, b.high, b.low,); // a = 0 mod FIELD
    assert(b_r == u512_reduce(u512_sub_u256(a, FIELD), field_nz), 'u512_add_u256 mismatch');

    let a = bi(2, 0, 0, 0,); // a = 0 mod FIELD
    assert(bi(1, f30f, f30f, f30f,) == u512_sub_u256(a, 1), 'u512_add_u256 mismatch');

    let a = bi(1, 2, 0, 0,); // a = 0 mod FIELD
    assert(bi(1, 1, f30f, f30f,) == u512_sub_u256(a, 1), 'u512_add_u256 mismatch');
}


#[test]
#[available_gas(20000000)]
fn u512_sub_overflow() {
    let field_nz = get_field_nz();
    let a = bi(
        0xb644cf8c3632b365f7ecd91ecbc56e37,
        0x7c98ebc8858f41d26746b3b9cd81f524,
        0xc3ca7d501004eb2b6f4b036038bee74e,
        0x31c521c84cd3126699cd3d7301276788,
    );

    let b = bi(
        0xf4b036038beeb644c014e31c521c84cd,
        0x312004eb2b676699cd3d7301276788c5,
        0xc380bee042bbe74e3ca7d50106f4b036,
        0x3632b365f7ecd91ecb3ca7d5d81f5249,
    );

    let b_large = bi(
        0xf4b036038beeb644c014e31c521c84cd,
        0x312004eb2b676699cd3d7301276788c5,
        // Larger less significant limbs are equivalent mod FIELD
        0x1ef8514bdf566a75b66be2700ef4ebf,
        0xd82d09205625aee9daba777a762b5d2d
    );

    // c overflows with a small limb1
    // 0x1aaf5058fc22169aab801bc3b1de1f304adb8f0b3b0f6a86c348426baf4e97dea0201f9e8fbcd70bab11d6aa6ec78b6da67f7d52e44bfeb856509e548d946b9d1
    let c = a - b;
    let c_reduced = u512_reduce(c, field_nz);

    // c_large overflows with a large limb1
    let c_large = a - b_large;
    let c_large_reduced = u512_reduce(c_large, field_nz);

    // c mod FIELD should equal
    // -0x3e6b667755bc02dec82809fd86571695b4871922a5d824c765f6bf4759e593a0ffb6419032b6fc22cd5cd1a0ce35c8e8046d919dab19c6b8316f6a62d6f7eac1 mod FIELD
    // = 0xa5ec6c44bcafb8a12eee3c8766b0ed6d149384a9d063b80933d2f7bbd1820ad
    let expect = 0xa5ec6c44bcafb8a12eee3c8766b0ed6d149384a9d063b80933d2f7bbd1820ad;

    assert(expect == c_reduced, 'wrong u512 add');
    assert(expect == c_large_reduced, 'wrong u512 add');
}
