mod ec {
    type Point = (u256, u256);
mod traits;

    fn point(x: u256, y: u256) -> Point {
        (x, y)
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
