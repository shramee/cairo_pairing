trait ECOperations<TCurve, TPoint> {
    fn add(self: @TCurve, lhs: TPoint, rhs: TPoint) -> TPoint;
    fn double(self: @TCurve, point: TPoint) -> TPoint;
    fn scalar_mult(self: @TCurve, point: TPoint, multiplier: u256) -> TPoint;
}
