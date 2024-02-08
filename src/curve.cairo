mod groups;

// #[cfg(test)]
// mod groups_tests;

// #[cfg(test)]
// mod tests;

mod pairing {
    mod final_exponentiation;
    mod miller_utils;
    mod bkls_tate;
// #[cfg(test)]
// mod tests;
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
    // Reverse and output tt for P and tf for 
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

#[cfg(test)]
mod test {
    #[test]
    #[available_gas(2000000000)]
    fn x_naf_verify() {
        let mut naf = bn::curve::x_naf();
        let mut bit = 1_u128;
        let mut offset = 0xffffffffffffffff_u128;
        let mut result = offset;

        loop {
            match naf.pop_front() {
                Option::Some(naf) => {
                    let (naf0, naf1) = naf;

                    if naf0 {
                        if naf1 {
                            result = result + bit;
                        } else {
                            result = result - bit;
                        }
                    }

                    bit = bit * 2;
                },
                Option::None => { break; },
            }
        };
        assert(result - offset == bn::curve::X.into(), 'incorrect X')
    }
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
fn scl(a: u256, b: u128) -> u256 {
    bn::fast_mod::scl(a, b, field_nz())
}

#[inline(always)]
fn neg(b: u256) -> u256 {
    bn::fast_mod::neg(b, FIELD)
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
