mod ec {
    type Point = (u256, u256);
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

    }

    fn add(a: Point, b: Point, field: u256) -> Point {
        let (x, y) = a;
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
