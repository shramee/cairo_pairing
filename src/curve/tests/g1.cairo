use bn::traits::ECOperations;
use bn::fields::fq;
use bn::{g1, g2};
use debug::PrintTrait;

const DBL_X: u256 = 1368015179489954701390400359078579693043519447331113978918064868415326638035;
const DBL_Y: u256 = 9918110051302171585080402603319702774565515993150576347155970296011118125764;

const TPL_X: u256 = 3353031288059533942658390886683067124040920775575537747144343083137631628272;
const TPL_Y: u256 = 19321533766552368860946552437480515441416830039777911637913418824951667761761;

#[test]
#[available_gas(100000000)]
fn dbl() {
    // test bn::curve::tests::g1::dbl ... ok (gas usage est.: 412280)

    let doubled = g1::one().double();
    assert(doubled.x.c0 == DBL_X, 'wrong double x');
    assert(doubled.y.c0 == DBL_Y, 'wrong double y');
}

#[test]
#[available_gas(100000000)]
fn add() {
    // test bn::curve::tests::g1::add ... ok (gas usage est.: 359810)

    let g_3x = g1::one().add(g1::pt(DBL_X, DBL_Y));

    assert(g_3x.x.c0 == TPL_X, 'wrong add x');
    assert(g_3x.y.c0 == TPL_Y, 'wrong add y');
}

#[test]
#[available_gas(100000000)]
fn mul() {
    // test bn::curve::tests::g1::mul ... ok (gas usage est.: 1568690)

    let g_3x = g1::one().multiply(3);

    assert(g_3x.x.c0 == TPL_X, 'wrong add x');
    assert(g_3x.y.c0 == TPL_Y, 'wrong add y');
}
