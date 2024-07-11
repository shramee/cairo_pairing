pub mod bn;
pub mod lines;
use fq_types::{FieldOps};
use core::num::traits::One;
pub use bn::AffineOpsBn;
pub use lines::{LineFn, StepLinesGet, LinesArray, LinesArrayGet};

#[derive(Copy, Drop, Serde)]
pub struct Affine<T> {
    pub x: T,
    pub y: T
}

#[derive(Copy, Drop)]
pub struct Groth16MillerG1<TG1> { // Points in G1
    pi_a: Affine<TG1>,
    pi_c: Affine<TG1>,
    k: Affine<TG1>,
}

#[derive(Copy, Drop)]
pub struct Groth16MillerG2<TG2> { // Points in <TG2>
    pi_b: Affine<TG2>,
    delta: Affine<TG2>,
    gamma: Affine<TG2>,
}

pub trait ECOperations<TCurve, TFq> {
    fn x_on_slope(ref self: TCurve, pt: Affine<TFq>, slope: TFq, x2: TFq) -> TFq;
    fn y_on_slope(ref self: TCurve, pt: Affine<TFq>, slope: TFq, x: TFq) -> TFq;
    fn pt_on_slope(ref self: TCurve, pt: Affine<TFq>, slope: TFq, x2: TFq) -> Affine<TFq>;
    fn chord(ref self: TCurve, pt: Affine<TFq>, rhs: Affine<TFq>) -> TFq;
    fn tangent(ref self: TCurve, pt: Affine<TFq>) -> TFq;
    fn pt_add(ref self: TCurve, pt: Affine<TFq>, rhs: Affine<TFq>) -> Affine<TFq>;
    fn pt_dbl(ref self: TCurve, pt: Affine<TFq>) -> Affine<TFq>;
    fn pt_mul(ref self: TCurve, pt: Affine<TFq>, multiplier: u256) -> Affine<TFq>;
    fn pt_neg(ref self: TCurve, pt: Affine<TFq>) -> Affine<TFq>;
}

pub trait ECGroupUtils<TCurve, TFq> {
    fn pt_one(ref self: TCurve) -> Affine<TFq>;
}

pub impl AffinePartialEq<T, +PartialEq<T>> of PartialEq<Affine<T>> {
    fn eq(lhs: @Affine<T>, rhs: @Affine<T>) -> bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    fn ne(lhs: @Affine<T>, rhs: @Affine<T>) -> bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}
