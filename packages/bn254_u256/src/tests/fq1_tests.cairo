// This is not included in the package

pub use bn254_u256::{Bn254U256Curve, bn254_curve, Fq, Bn254FqOps};
const A: u256 = 25;
const B: u256 = 34;
fn fq(c0: u256) -> Fq {
    Fq { c0 }
}

#[test]
fn test_add() {
    let mut curve = bn254_curve();
    let result = curve.add(fq(A), fq(B));
    assert_eq!(result, fq(A + B));
}

#[test]
fn test_sub() {
    let mut curve = bn254_curve();
    let result = curve.sub(fq(A), fq(B));
    assert_eq!(result, fq(A + curve.q - B));
}

#[test]
fn test_neg() {
    let mut curve = bn254_curve();
    let result = curve.neg(fq(A));
    assert_eq!(result, fq(curve.q - A));
}

#[test]
fn test_mul() {
    let mut curve = bn254_curve();
    let result = curve.mul(fq(A), fq(B));
    assert_eq!(result, fq(A * B));
}

#[test]
fn test_div() {
    let mut curve = bn254_curve();
    let ab = fq(A * B); // ensure the dividend is exactly divisible by the divisor
    let result = curve.div(ab, fq(B));
    assert_eq!(result, fq(A));
}

#[test]
fn test_sqr() {
    let mut curve = bn254_curve();
    let result = curve.sqr(fq(A));
    assert_eq!(result, fq(A * A));
}

#[test]
fn test_inv() {
    let mut curve = bn254_curve();
    let inv_a = curve.inv(fq(A));
    let one = fq(1);
    assert_eq!(curve.mul(fq(A), inv_a), one);
}
