use cairo_ec::traits::{ECOperations};
use cairo_ec::fast_mod::{add_mod, sub_mod, div_mod, mult_mod, add_inverse_mod};

#[derive(Copy, Drop)]
struct AffineG1 {
    x: u256,
    y: u256
}

fn aff_pt(x: u256, y: u256) -> AffineG1 {
    AffineG1 { x, y }
}

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

impl AffineBNOps of ECOperations<BNCurve, AffineG1> {
    fn add(self: @BNCurve, lhs: AffineG1, rhs: AffineG1) -> AffineG1 {
        let BNCurve{field, b } = *self;
        let AffineG1{x: x1, y: y1 } = lhs;
        let AffineG1{x: x2, y: y2 } = rhs;

        // λ = (y2 - y1) / (x2 - x1)
        let lambda = div_mod(sub_mod(y2, y1, field), sub_mod(x2, x1, field), field);

        // v = y - λx
        let v = sub_mod(y1, mult_mod(lambda, x1, field), field);

        // New point
        let x = sub_mod(sub_mod(mult_mod(lambda, lambda, field), x1, field), x2, field);
        let y = sub_mod(add_inverse_mod(mult_mod(lambda, x, field), field), v, field);
        AffineG1 { x, y }
    }

    fn double(self: @BNCurve, point: AffineG1) -> AffineG1 {
        let BNCurve{field, b } = *self;
        let AffineG1{x, y } = point;

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
        AffineG1 { x, y }
    }

    fn scalar_mult(self: @BNCurve, point: AffineG1, multiplier: u256) -> AffineG1 {
        AffineG1 { x: 0, y: 0 }
    }
}
