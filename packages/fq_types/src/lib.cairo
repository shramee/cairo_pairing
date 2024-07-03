#[derive(Copy, Drop, Serde)]
pub struct Fq2<T> {
    pub c0: T,
    pub c1: T,
}

#[derive(Copy, Drop, Serde)]
pub struct Fq3<T> {
    pub c0: T,
    pub c1: T,
    pub c2: T,
}

type Fq6<T> = Fq3<Fq2<T>>;
type Fq12<T> = Fq2<Fq3<Fq2<T>>>;

trait FieldOps<TFq> {
    fn add(self: TFq, rhs: TFq) -> TFq;
    fn sub(self: TFq, rhs: TFq) -> TFq;
    fn mul(self: TFq, rhs: TFq) -> TFq;
    fn div(self: TFq, rhs: TFq) -> TFq;
    fn sqr(self: TFq) -> TFq;
    fn neg(self: TFq) -> TFq;
    fn eq(lhs: @TFq, rhs: @TFq) -> bool;
    fn inv(self: TFq, field_nz: NonZero<u256>) -> TFq;
}

trait FieldOpsUnreduced<TFq, TFqU512> {
    fn u_add(self: TFq, rhs: TFq) -> TFq;
    fn u_sub(self: TFq, rhs: TFq) -> TFq;
    fn u_mul(self: TFq, rhs: TFq) -> TFqU512;
    fn u_sqr(self: TFq) -> TFqU512;
    fn u512_add_fq(self: TFqU512, rhs: TFq) -> TFqU512;
    fn u512_sub_fq(self: TFqU512, rhs: TFq) -> TFqU512;
    fn to_fq(self: TFqU512, field_nz: NonZero<u256>) -> TFq;
    fn fix_mod(self: TFq) -> TFq;
}

mod bn254;
