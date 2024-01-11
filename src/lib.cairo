mod fast_mod;
mod i257;
mod traits;
use integer::u512;
use traits::{ECOperations};
use alexandria_math::mod_arithmetics::{mult_mod, div_mod, add_inverse_mod};
// use alexandria_math::mod_arithmetics::{add_mod, sub_mod};
use fast_mod::{add_mod, sub_mod};

#[derive(Copy, Drop)]
struct AffinePoint {
    x: u256,
    y: u256
}

fn aff_pt(x: u256, y: u256) -> AffinePoint {
    AffinePoint { x, y }
}

// #[derive(Copy, Drop)]
// struct JacobianPoint {
//     x: u256,
//     y: u256,
//     z: u256
// }

#[derive(Copy, Drop)]
struct BNCurve {
    field: u256,
    b: u256,
}

fn bn254() -> BNCurve {
    let field = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    let b = 3;
    BNCurve { field, b }
// fq2_modulus_coeffs: (1, 0),
// fq12_modulus_coeffs: (82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0),  // Implied + [1]

}

impl AffineBNOps of ECOperations<BNCurve, AffinePoint> {
    fn add(self: @BNCurve, lhs: AffinePoint, rhs: AffinePoint) -> AffinePoint {
        let BNCurve{field, b } = *self;
        let AffinePoint{x: x1, y: y1 } = lhs;
        let AffinePoint{x: x2, y: y2 } = rhs;

        // λ = (y2 - y1) / (x2 - x1)
        let lambda = div_mod(sub_mod(y2, y1, field), sub_mod(x2, x1, field), field);

        // v = y - λx
        let v = sub_mod(y1, mult_mod(lambda, x1, field), field);

        // New point
        let x = sub_mod(sub_mod(mult_mod(lambda, lambda, field), x1, field), x2, field);
        let y = sub_mod(add_inverse_mod(mult_mod(lambda, x, field), field), v, field);
        AffinePoint { x, y }
    }

    fn double(self: @BNCurve, point: AffinePoint) -> AffinePoint {
        let BNCurve{field, b } = *self;
        let AffinePoint{x, y } = point;

        // λ = (3x^2 + a) / 2y
        // let lambda = div_mod(
        //     add_mod(mult_mod(3, mult_mod(x, x, field), field), a, field),
        //     mult_mod(2, y, field),
        //     field
        // );
        // But BN curve has a == 0 so that's one less addition
        // λ = 3x^2 / 2y
        let lambda = div_mod(
            mult_mod(3, mult_mod(x, x, field), field), // Numerator
            mult_mod(2, y, field), // Denominator
            field
        );

        // v = y - λx
        let v = sub_mod(y, mult_mod(lambda, x, field), field);

        // New point
        let x = sub_mod(mult_mod(lambda, lambda, field), mult_mod(2, x, field), field);
        let y = sub_mod(add_inverse_mod(mult_mod(lambda, x, field), field), v, field);
        AffinePoint { x, y }
    }

    fn scalar_mult(self: @BNCurve, point: AffinePoint, multiplier: u256) -> AffinePoint {
        AffinePoint { x: 0, y: 0 }
    }
}

#[cfg(test)]
mod bn254_tests {
    use super::{BNCurve, AffinePoint, AffineBNOps, ECOperations, aff_pt, bn254};
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
