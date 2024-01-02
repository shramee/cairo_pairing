trait EllipticCurveOperations<T, Point> {
    fn add(self: @T, lhs: Point, rhs: Point) -> Point;

    fn double(self: @T, point: Point) -> Point;

    fn scalar_mult(self: @T, point: Point, multiplier: u256) -> Point;
}
