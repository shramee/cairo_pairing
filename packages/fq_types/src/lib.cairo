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

pub type Fq6<T> = Fq3<Fq2<T>>;
pub type Fq12<T> = Fq2<Fq6<T>>;

pub fn fq2<T>(c0: T, c1: T) -> Fq2<T> {
    Fq2 { c0, c1 }
}

pub fn fq3<T>(c0: T, c1: T, c2: T) -> Fq3<T> {
    Fq3 { c0, c1, c2 }
}

// Sparse Fq12 element containing only c3 and c4 Fq2 (c0 is 1)
// Equivalent to,
// Fq12{
//   c0: Fq6{c0: 1, c1: 0, c2: 0},
//   c1: Fq6{c0: c3, c1: c4, c2: 0},
// }
#[derive(Copy, Drop, Serde)]
pub struct F12S034<T> {
    pub c3: T,
    pub c4: T,
}

// Sparse Fq12 element containing c0, c1, c2, c3 and c4 Fq2
#[derive(Copy, Drop, Serde)]
pub struct F12S01234<T> {
    pub c0: T,
    pub c1: T,
    pub c2: T,
    pub c3: T,
    pub c4: T,
}

pub trait FieldOps<TCurve, TFq> {
    fn add(ref self: TCurve, lhs: TFq, rhs: TFq) -> TFq;
    fn sub(ref self: TCurve, lhs: TFq, rhs: TFq) -> TFq;
    fn neg(ref self: TCurve, lhs: TFq) -> TFq;
    fn eq(self: @TCurve, lhs: @TFq, rhs: @TFq) -> bool;
    fn mul(ref self: TCurve, lhs: TFq, rhs: TFq) -> TFq;
    fn div(ref self: TCurve, lhs: TFq, rhs: TFq) -> TFq;
    fn sqr(ref self: TCurve, lhs: TFq) -> TFq;
    fn inv(ref self: TCurve, lhs: TFq) -> TFq;
}

pub trait FieldUtils<TCurve, TFq> {
    fn one(ref self: TCurve) -> TFq;
    fn zero(ref self: TCurve) -> TFq;
    fn conjugate(ref self: TCurve, el: TFq) -> TFq;
    fn mul_by_nonresidue(ref self: TCurve, el: TFq,) -> TFq;
    fn frobenius_map(ref self: TCurve, el: TFq, power: usize) -> TFq;
}

pub trait FieldOpsExtended<TCurve, TFq, TFqChildren, TFqU512> {
    fn scl(ref self: TCurve, lhs: TFq, rhs: TFqChildren) -> TFq;
    fn u_mul(ref self: TCurve, lhs: TFq, rhs: TFq) -> TFqU512;
    fn u_sqr(ref self: TCurve, lhs: TFq) -> TFqU512;
    fn u512_add_fq(ref self: TCurve, lhs: TFqU512, rhs: TFq) -> TFqU512;
    fn u512_sub_fq(ref self: TCurve, lhs: TFqU512, rhs: TFq) -> TFqU512;
    fn to_fq(ref self: TCurve, lhs: TFqU512) -> TFq;
}

pub type Fq4Direct<T> = (T, T, T, T);
pub type Fq12Direct<T> = (Fq4Direct<T>, Fq4Direct<T>, Fq4Direct<T>);
pub type F12S01234Direct<T> = ((T, T, T, T, T), (T, T, T, T, T));

pub use common::{
    Fq2Ops, Fq2PartialEq, Fq3Ops, Fq3PartialEq, fq2_scale, fq3_scale, fq2_conjugate, fq2_sqr_nbeta
};
