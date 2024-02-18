// These paramas from:
// https://hackmd.io/@jpw/bn254

const X: u64 = 4965661367192848881;
const ORDER: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

const FIELD: u256 = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;

// 2**256 % FIELD
const U512_MOD_FIELD: u256 = 0x6d89f71cab8351f47ab1eff0a417ff6b5e71911d44501fbf32cfc5b538afa89;

// FIELD - 2**256 % FIELD
const U512_MOD_FIELD_INV: u256 = 0x298baf0116796b0a70a526b7773fd866e19a517f942cc89148f38fbb84f202be;


const FIELD_X2: u256 = 0x60c89ce5c263405370a08b6d0302b0bb2f02d522d0e3951a7841182db0f9fa8e;
// 0x4689e957a1242c84a50189c6d96cadca602072d09eac1013b5458a2275d69b1
const FIELDSQLOW: u256 =
    1994097994880475507519040458855034912025718176994801861240415525295080958385;

// 0x925c4b8763cbf9c599a6f7c0348d21cb00b85511637560626edfa5c34c6b38d
const FIELDSQHIGH: u256 =
    4137546694012196313615514819619774299549115026185221663042307357682442875789;

const B: u256 = 3;

const ATE_LOOP_COUNT: u128 = 29793968203157093288;
const LOG_ATE_LOOP_COUNT: u128 = 63;

// u512 scale by u128 gives a u128 overflow.
// When doing a mul by 9, the overflow can be from 0 to 8
// for returned val q * 2**512 + r,
// we do, r + ((q * two_to_512) % FIELD)
// Here's (q * two_to_512) % FIELD precompute for q upto 8.
fn u512_overflow_precompute_add() -> Span<u256> {
    array![
        // for( i = 0n; i < 9n; i++ ) console.log( hex((i * 2n**512n) % FIELD) + ',');
        0,
        0x6d89f71cab8351f47ab1eff0a417ff6b5e71911d44501fbf32cfc5b538afa89,
        0xdb13ee395706a3e8f563dfe1482ffed6bce3223a88a03f7e659f8b6a715f512,
        0x1489de5560289f5dd7015cfd1ec47fe421b54b357ccf05f3d986f511faa0ef9b,
        0x1b627dc72ae0d47d1eac7bfc2905ffdad79c6447511407efccb3f16d4e2bea24,
        0x223b1d38f599099c66579afb33477fd18d837d59255909ebbfe0edc8a1b6e4ad,
        0x2913bcaac0513ebbae02b9fa3d88ffc8436a966af99e0be7b30dea23f541df36,
        0x2fec5c1c8b0973daf5add8f947ca7fbef951af7ccde30de3a63ae67f48ccd9bf,
        0x660ad1b749008d08508b241d08aa75817b75dfd39b645525d4756c3c3dad701,
    ]
        .span()
}

#[inline(always)]
fn x_naf() -> Array<(bool, bool)> {
    // https://codegolf.stackexchange.com/questions/235319/convert-to-a-non-adjacent-form#answer-235327
    // JS function, f=n=>n?f(n+n%4n/3n>>1n)+'OPON'[n%4n]:''
    // When run with X, f(4965661367192848881n)
    // returns POOOPOPOONOPOPONOOPOPONONONOPOOOPOOPOPOPONOPOOPOOOOPOPOOOONOOOP
    // Reverse and output tt for P and tf for N,
    // f(4965661367192848881n).split('').reverse().join(',');
    let O = (false, false);
    let P = (true, true);
    let N = (true, false);
    array![
        P,
        O,
        O,
        O,
        N,
        O,
        O,
        O,
        O,
        P,
        O,
        P,
        O,
        O,
        O,
        O,
        P,
        O,
        O,
        P,
        O,
        N,
        O,
        P,
        O,
        P,
        O,
        P,
        O,
        O,
        P,
        O,
        O,
        O,
        P,
        O,
        N,
        O,
        N,
        O,
        N,
        O,
        P,
        O,
        P,
        O,
        O,
        N,
        O,
        P,
        O,
        P,
        O,
        N,
        O,
        O,
        P,
        O,
        P,
        O,
        O,
        O,
        P,
    ]
}

#[inline(always)]
fn six_u_plus_2_naf() -> Array<(bool, bool)> {
    // sixuPlus2NAF is 6u+2 in non-adjacent form.
    let O = (false, false);
    let P = (true, true);
    let N = (true, false);
    array![
        O,
        O,
        O,
        P,
        O,
        P,
        O,
        N,
        O,
        O,
        P,
        N,
        O,
        O,
        P,
        O,
        O,
        P,
        P,
        O,
        N,
        O,
        O,
        P,
        O,
        N,
        O,
        O,
        O,
        O,
        P,
        P,
        P,
        O,
        O,
        N,
        O,
        O,
        P,
        O,
        O,
        O,
        O,
        O,
        N,
        O,
        O,
        P,
        P,
        O,
        O,
        N,
        O,
        O,
        O,
        P,
        P,
        O,
        N,
        O,
        O,
        P,
        O,
        P,
        P
    ]
}
