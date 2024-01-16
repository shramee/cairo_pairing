use bn::traits::ECOperations;
use bn::fields::fq;
use bn::{g1, g2};
use debug::PrintTrait;

const dbl_x: u256 = 1368015179489954701390400359078579693043519447331113978918064868415326638035;
const dbl_y: u256 = 9918110051302171585080402603319702774565515993150576347155970296011118125764;

#[test]
#[available_gas(2000000)]
fn fq_test_main() {
    fq(256) - fq(56);
    fq(256) + fq(56);
    fq(256) * fq(56);
    fq(256) / fq(56);
    -fq(256);
    fq(256) == fq(56);
    let pt = g1::AffineG1 { x: fq(1), y: fq(2) };
    assert(pt.x.c0 == 1, '');
    assert(pt.y.c0 == 2, '');
}

#[test]
#[available_gas(2000000)]
fn fq_test_main2() {
    bn::fast_mod::bn254::sub(256, 56);
    bn::fast_mod::bn254::add(256, 56);
    bn::fast_mod::bn254::mul(256, 56);
    bn::fast_mod::bn254::div(256, 56);
    bn::fast_mod::bn254::add_inverse(256);
    256_u256 == 56_u256;
    let pt = (1_u256, 2_u256);
    let (x, y) = pt;
    assert(x == 1, '');
    assert(y == 2, '');
}

#[test]
#[available_gas(100000000)]
fn g1_dbl() {
    // g1_double ... ok (gas: 412280)
    // g1_double ... ok (gas: 413180)

    let doubled = g1::one().double();
    assert(doubled.x.c0 == dbl_x, 'wrong double x');
    assert(doubled.y.c0 == dbl_y, 'wrong double y');
}

#[test]
#[available_gas(100000000)]
fn g1_add() {
    // g1_add ... ok (gas: 359010)
    // g1_add ... ok (gas: 360510)

    let g_3x = g1::one().add(g1::pt(dbl_x, dbl_y));

    assert(
        g_3x.x.c0 == 3353031288059533942658390886683067124040920775575537747144343083137631628272,
        'wrong add x'
    );
    assert(
        g_3x.y.c0 == 19321533766552368860946552437480515441416830039777911637913418824951667761761,
        'wrong add y'
    );
}

#[test]
#[available_gas(100000000)]
fn g1_mul() {
    // g1_mul ... ok (gas: 1567090)
    // g1_mul ... ok (gas: 1571890)

    let g_3x = g1::one().multiply(3);

    assert(
        g_3x.x.c0 == 3353031288059533942658390886683067124040920775575537747144343083137631628272,
        'wrong add x'
    );
    assert(
        g_3x.y.c0 == 19321533766552368860946552437480515441416830039777911637913418824951667761761,
        'wrong add y'
    );
}
