trait ECOperations<TPoint> {
    fn add(self: @TPoint, rhs: TPoint) -> TPoint;
    fn double(self: @TPoint) -> TPoint;
    fn multiply(self: @TPoint, multiplier: u256) -> TPoint;
}
