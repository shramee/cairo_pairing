mod fast_mod;
mod i257;
mod bn {
    mod curve;
    mod pt;
}
mod traits;

use fast_mod::{add_mod, sub_mod, div_mod, mult_mod, add_inverse_mod};


#[cfg(test)]
mod bn254_tests {
    use cairo_ec::bn::curve::{BNCurve, AffinePoint, AffineBNOps, ECOperations, aff_pt, bn254};
    use debug::PrintTrait;

    const dbl_x: u256 =
        1368015179489954701390400359078579693043519447331113978918064868415326638035;
    const dbl_y: u256 =
        9918110051302171585080402603319702774565515993150576347155970296011118125764;

    #[test]
    #[available_gas(100000000)]
    fn test_double() {
        let curve = bn254();

        let doubled = curve.double(aff_pt(1, 2));
        assert(doubled.x == dbl_x, 'wrong double x');
        assert(doubled.y == dbl_y, 'wrong double y');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_add() {
        let curve = bn254();

        let g_3 = curve.add(aff_pt(1, 2), aff_pt(dbl_x, dbl_y));

        assert(
            g_3.x == 3353031288059533942658390886683067124040920775575537747144343083137631628272,
            'wrong add x'
        );
        assert(
            g_3.y == 19321533766552368860946552437480515441416830039777911637913418824951667761761,
            'wrong add y'
        );
    }
}

#[cfg(test)]
mod mod_ops_tests {
    // REFERENCE: u128 operations in u256
    // plain_arithmetic::div gas usage: 11450
    // plain_arithmetic::add gas usage: 6830
    // plain_arithmetic::mul gas usage: 21190
    // plain_arithmetic::sub gas usage: 6830

    use core::option::OptionTrait;
    use core::traits::TryInto;
    use super::fast_mod;
    use super::{BNCurve, AffinePoint, AffineBNOps, ECOperations, aff_pt, bn254};
    use super::{add_mod, sub_mod, mult_mod, div_mod, add_inverse_mod};
    use debug::PrintTrait;

    const a: u256 = 9099547013904003590785796930435194473319680151794113978918064868415326638035;
    const b: u256 = 8021715850804026033197027745655159931503181100513576347155970296011118125764;


    #[test]
    #[available_gas(1000000)]
    fn test_add_mod() {
        add_mod(a, b, bn254().field);
    }

    #[test]
    #[available_gas(1000000)]
    fn test_sub_mod() {
        sub_mod(a, b, bn254().field);
    }

    #[test]
    #[available_gas(1000000)]
    fn test_mult_mod() {
        let m = mult_mod(a, b, bn254().field);
    }

    #[test]
    #[available_gas(100000000)]
    fn test_div_mod() {
        let a = div_mod(a, b, bn254().field);
    }
}
