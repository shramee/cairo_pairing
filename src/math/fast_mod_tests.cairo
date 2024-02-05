// test bn::math::fast_mod_tests::bench_plain::add ... ok (gas usage est.: 6830)
// test bn::math::fast_mod_tests::bench_plain::div ... ok (gas usage est.: 11450)
// test bn::math::fast_mod_tests::bench_plain::mul ... ok (gas usage est.: 21190)
// test bn::math::fast_mod_tests::bench_plain::rem ... ok (gas usage est.: 11450)
// test bn::math::fast_mod_tests::bench_plain::sub ... ok (gas usage est.: 6830)
// test bn::math::fast_mod_tests::bench::add ... ok (gas usage est.: 16680)
// test bn::math::fast_mod_tests::bench::div ... ok (gas usage est.: 86400)
// test bn::math::fast_mod_tests::bench::mul ... ok (gas usage est.: 52530)
// test bn::math::fast_mod_tests::bench::scl ... ok (gas usage est.: 37630)
// test bn::math::fast_mod_tests::bench::sqr ... ok (gas usage est.: 48300)
// test bn::math::fast_mod_tests::bench::sub ... ok (gas usage est.: 15710)

use core::option::OptionTrait;
use core::traits::TryInto;
use bn::fast_mod::{add, sub, div, mul, sqr_nz, add_inverse, scale};
use bn::curve::FIELD;
use debug::PrintTrait;

const a: u256 = 9099547013904003590785796930435194473319680151794113978918064868415326638035;
const b: u256 = 8021715850804026033197027745655159931503181100513576347155970296011118125764;

mod bench {
    use bn::fast_mod as f;
    use super::{a, b, FIELD};
    #[test]
    #[available_gas(1000000)]
    fn add() {
        f::add(a, b, FIELD);
    }

    #[test]
    #[available_gas(1000000)]
    fn sub() {
        f::sub(a, b, FIELD);
    }

    #[test]
    #[available_gas(1000000)]
    fn mul() {
        f::mul(a, b, FIELD);
    }

    #[test]
    #[available_gas(1000000)]
    fn scl() {
        f::scale(a, b.low, FIELD.try_into().unwrap());
    }

    #[test]
    #[available_gas(1000000)]
    fn sqr() {
        f::sqr_nz(a, FIELD.try_into().unwrap());
    }

    #[test]
    #[available_gas(100000000)]
    fn div() {
        f::div(a, b, FIELD);
    }
}

mod bench_plain {
    use core::traits::TryInto;
    use super::{a, b, FIELD};
    #[test]
    #[available_gas(1000000)]
    fn add() {
        a + b;
    }

    #[test]
    #[available_gas(1000000)]
    fn sub() {
        a - b;
    }

    #[test]
    #[available_gas(1000000)]
    fn mul() {
        7_u256 * 909954701390400359078579693043519447331968015179411397891806486841532663803;
    }

    #[test]
    #[available_gas(100000000)]
    fn div() {
        a / b;
    }

    #[test]
    #[available_gas(100000000)]
    fn rem() {
        a % b;
    }
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
    let sqr_mul = mul(a, a, FIELD);
    let sqr_ = sqr_nz(a, FIELD.try_into().unwrap());
    assert(sqr_ == sqr_mul, 'incorrect square');

    let scl_mul = mul(a, u256 { high: 0, low: b.low }, FIELD);
    let scl_ = scale(a, b.low, FIELD.try_into().unwrap());
    assert(scl_ == scl_mul, 'incorrect square');
}
