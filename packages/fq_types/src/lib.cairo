pub mod common;

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

// Sparse Fq12 element containing only c3 and c4 Fq2 (c0 is 1)
// Equivalent to,
// Fq12{
//   c0: Fq6{c0: 1, c1: 0, c2: 0},
//   c1: Fq6{c0: c3, c1: c4, c2: 0},
// }
#[derive(Copy, Drop, Serde)]
struct F12S034<T> {
    pub c3: T,
    pub c4: T,
}

// Sparse Fq12 element containing c0, c1, c2, c3 and c4 Fq2
#[derive(Copy, Drop, Serde)]
struct F12S01234<T> {
    pub c0: T,
    pub c1: T,
    pub c2: T,
    pub c3: T,
    pub c4: T,
}

pub trait FieldCommonOps<TFq> {
    fn add(self: TFq, rhs: TFq) -> TFq;
    fn sub(self: TFq, rhs: TFq) -> TFq;
    // fn scl(self: TFq, rhs: TFqChildren) -> TFq;
    fn neg(self: TFq) -> TFq;
    fn eq(self: @TFq, rhs: @TFq) -> bool;
}

pub trait FieldOps<TFq, TFqChildren, TFqU512> {
    fn scl(self: TFq, rhs: TFqChildren) -> TFq;
    fn mul(self: TFq, rhs: TFq) -> TFq;
    fn div(self: TFq, rhs: TFq) -> TFq;
    fn sqr(self: TFq) -> TFq;
    fn inv(self: TFq, field_nz: NonZero<u256>) -> TFq;
    fn u_mul(self: TFq, rhs: TFq) -> TFqU512;
    fn u_sqr(self: TFq) -> TFqU512;
    fn u512_add_fq(self: TFqU512, rhs: TFq) -> TFqU512;
    fn u512_sub_fq(self: TFqU512, rhs: TFq) -> TFqU512;
    fn to_fq(self: TFqU512, field_nz: NonZero<u256>) -> TFq;
}

type Fq12Direct<T> = (T, T, T, T, T, T, T, T, T, T, T, T);
type F12S01234Direct<T> = ((T, T, T, T, T), (T, T, T, T, T));

pub use common::{Fq2CommonOps, Fq3CommonOps};
