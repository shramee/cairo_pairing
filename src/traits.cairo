trait ECOperations<TPoint> {
    fn add(self: @TPoint, rhs: TPoint) -> TPoint;
    fn double(self: @TPoint) -> TPoint;
    fn multiply(self: @TPoint, multiplier: u256) -> TPoint;
}

trait FieldOperations<TFq> {
    fn add(lhs: TFq, rhs: TFq) -> TFq;
    fn sub(lhs: TFq, rhs: TFq) -> TFq;
    fn mul(lhs: TFq, rhs: TFq) -> TFq;
    fn div(lhs: TFq, rhs: TFq) -> TFq;
    fn neg(a: TFq) -> TFq;
    fn eq(lhs: @TFq, rhs: @TFq) -> bool;
}
