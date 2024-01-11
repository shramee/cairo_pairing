use cairo_ec::bn::curve::{BNCurve, ECOperations, aff_pt, bn254};
use debug::PrintTrait;

const dbl_x: u256 = 1368015179489954701390400359078579693043519447331113978918064868415326638035;
const dbl_y: u256 = 9918110051302171585080402603319702774565515993150576347155970296011118125764;

#[test]
#[available_gas(100000000)]
fn test_double() {
    let curve = bn254();

    let doubled = aff_pt(1, 2).double();
    assert(doubled.x == dbl_x, 'wrong double x');
    assert(doubled.y == dbl_y, 'wrong double y');
}

#[test]
#[available_gas(100000000)]
fn test_add() {
    let curve = bn254();
    (2_u128 + 5 + 8 % 5_u128).print();

    let g_x3 = aff_pt(1, 2).add(aff_pt(dbl_x, dbl_y));

    assert(
        g_x3.x == 3353031288059533942658390886683067124040920775575537747144343083137631628272,
        'wrong add x'
    );
    assert(
        g_x3.y == 19321533766552368860946552437480515441416830039777911637913418824951667761761,
        'wrong add y'
    );
}
