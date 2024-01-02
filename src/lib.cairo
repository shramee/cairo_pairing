mod traits;
use traits::{EllipticCurveOperations};
use alexandria_math::mod_arithmetics::{
    add_mod, sub_mod, mult_mod, div_mod, pow_mod, add_inverse_mod
};
type Point = (u256, u256);

#[derive(Copy, Drop)]
struct EC256Def {
    field: u256,
    a: u256,
    b: u256,
}

#[generate_trait]
impl EC256DefUtils of EC256DefUtilsTrait {
    fn new(field: u256, a: u256, b: u256,) -> EC256Def {
        EC256Def { field, a, b }
    }
}

impl EC256AffineImpl of EllipticCurveOperations<EC256Def, Point> {
    fn add(self: @EC256Def, lhs: Point, rhs: Point) -> Point {
        (0, 0)
    }

    fn double(self: @EC256Def, point: Point) -> Point {
        let EC256Def{field, a, b } = *self;
        let (x, y) = point;

        // λ = (3x^2 + a) / 2y
        let lambda_numerator = add_mod(mult_mod(3, mult_mod(x, x, field), field), a, field);
        let lambda = div_mod(lambda_numerator, mult_mod(2, y, field), field);

        // v = y - λx
        let v = sub_mod(y, mult_mod(lambda, x, field), field);
        let res_x = sub_mod(mult_mod(lambda, lambda, field), mult_mod(2, x, field), field);
        let res_y = sub_mod(add_inverse_mod(mult_mod(lambda, res_x, field), field), v, field);

        // (res_x, res_y)
        (0, 0)
    }

    fn scalar_mult(self: @EC256Def, point: Point, multiplier: u256) -> Point {
        (0, 0)
    }
}

#[cfg(test)]
mod tests {
    use super::ec::{point, add};

    #[test]
    #[available_gas(100000)]
    fn test_add() {
        let (x, y) = add(point(1, 5), point(1, 5), 11);
        assert(x == 0, 'it works!');
    }
}
