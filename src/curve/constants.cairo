// These paramas from:
// https://hackmd.io/@jpw/bn254

const T: u64 = 4965661367192848881;
const ORDER: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

const FIELD: u256 = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;

// 2**256 % FIELD
const U256_MOD_FIELD: u256 = 0xe0a77c19a07df2f666ea36f7879462c0a78eb28f5c70b3dd35d438dc58f0d9d;

// FIELD - 2**256 % FIELD
const U256_MOD_FIELD_INV: u256 = 0x2259d6b14729c0fa51e1a247090812318d087f6872aabf4f68c3488912edefaa;

const FIELD_X2: u256 = 0x60c89ce5c263405370a08b6d0302b0bb2f02d522d0e3951a7841182db0f9fa8e;

const FIELDSQLOW: u256 = 0x4689e957a1242c84a50189c6d96cadca602072d09eac1013b5458a2275d69b1;
const FIELDSQHIGH: u256 = 0x925c4b8763cbf9c599a6f7c0348d21cb00b85511637560626edfa5c34c6b38d;

const B: u256 = 3;

const ATE_LOOP_COUNT: u128 = 29793968203157093288;
const LOG_ATE_LOOP_COUNT: u128 = 63;

#[inline(always)]
fn t_naf() -> Array<(bool, bool)> {
    // https://codegolf.stackexchange.com/questions/235319/convert-to-a-non-adjacent-form#answer-235327
    // JS function, f=n=>n?f(n+n%4n/3n>>1n)+'OPON'[n%4n]:''
    // When run with T, f(4965661367192848881n)
    // returns POOOPOPOONOPOPONOOPOPONONONOPOOOPOOPOPOPONOPOOPOOOOPOPOOOONOOOP
    // Then reverse it
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
fn six_u_plus_2_naf_rev_first_sign() -> (bool, bool) {
    let P = (true, true);
    P
}

#[inline(always)]
fn six_u_plus_2_naf_rev_except_first() -> Array<(bool, bool)> {
    // sixuPlus2NAF is 6u+2 in non-adjacent form, reversed and first element removed.
    // NAF form,
    // O,O,O,P,O,P,O,N,O,O,P,N,O,O,P,O,O,P,P,O,N,O,O,P,O,N,O,O,O,O,P,P,P,O,O,N,O,O,P,O,O,O,O,O,N,O,O,P,P,O,O,N,O,O,O,P,P,O,N,O,O,P,O,P,P
    // Reversed,
    // P,P,O,P,O,O,N,O,P,P,O,O,O,N,O,O,P,P,O,O,N,O,O,O,O,O,P,O,O,N,O,O,P,P,P,O,O,O,O,N,O,P,O,O,N,O,P,P,O,O,P,O,O,N,P,O,O,N,O,P,O,P,O,O,O
    let O = (false, false);
    let P = (true, true);
    let N = (true, false);
    array![
        // in six_u_plus_2_naf_rev_first_sign()
        // P,
        P,
        O,
        P,
        O,
        O,
        N,
        O,
        P,
        P,
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
        O,
        O,
        P,
        O,
        O,
        N,
        O,
        O,
        P,
        P,
        P,
        O,
        O,
        O,
        O,
        N,
        O,
        P,
        O,
        O,
        N,
        O,
        P,
        P,
        O,
        O,
        P,
        O,
        O,
        N,
        P,
        O,
        O,
        N,
        O,
        P,
        O,
        P,
        O,
        O,
        O,
    ]
}
