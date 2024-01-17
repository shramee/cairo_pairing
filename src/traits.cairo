trait ECOperations<TPoint> {
    fn add(self: @TPoint, rhs: TPoint) -> TPoint;
    fn double(self: @TPoint) -> TPoint;
    fn multiply(self: @TPoint, multiplier: u256) -> TPoint;
}

trait FieldOps<TFq> {
    fn add(self: TFq, rhs: TFq) -> TFq;
    fn sub(self: TFq, rhs: TFq) -> TFq;
    fn mul(self: TFq, rhs: TFq) -> TFq;
    fn div(self: TFq, rhs: TFq) -> TFq;
    fn sqr(self: TFq) -> TFq;
    fn neg(self: TFq) -> TFq;
    fn eq(lhs: @TFq, rhs: @TFq) -> bool;
    fn one() -> TFq;
    fn inv(self: TFq) -> TFq;
}
