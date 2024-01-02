mod traits;
use integer::u512;
use traits::{ECOperations};
use alexandria_math::mod_arithmetics::{add_mod, sub_mod, mult_mod, div_mod, add_inverse_mod};

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
        AffinePoint { x: 0, y: 0 }
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
mod tests {
    use super::{BNCurve, AffinePoint, AffineBNOps, ECOperations, aff_pt, bn254};
    use debug::PrintTrait;

    #[test]
    #[available_gas(100000000)]
    fn test_double() {
        let curve = bn254();

        let doubled = curve.double(aff_pt(1, 2));
        assert(
            doubled
                .x == 1368015179489954701390400359078579693043519447331113978918064868415326638035_u256,
            'incorrect double x'
        );
        assert(
            doubled
                .y == 9918110051302171585080402603319702774565515993150576347155970296011118125764_u256,
            'incorrect double y'
        );

        let doubled = curve.double(doubled);
        assert(
            doubled
                .x == 3010198690406615200373504922352659861758983907867017329644089018310584441462,
            'incorrect double x'
        );
        assert(
            doubled
                .y == 4027184618003122424972590350825261965929648733675738730716654005365300998076,
            'incorrect double y'
        );
    }
}
