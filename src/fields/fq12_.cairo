use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::traits::{FieldUtils, FieldOps};
use bn::fields::{fq6, Fq6, Fq6Utils};

#[derive(Copy, Drop, Serde)]
struct Fq12 {
    c0: Fq6,
    c1: Fq6,
}

#[inline(always)]
fn fq12(
    c0: u256,
    c1: u256,
    c2: u256,
    c3: u256,
    c4: u256,
    c5: u256,
    c6: u256,
    c7: u256,
    c8: u256,
    c9: u256,
    c10: u256,
    c11: u256
) -> Fq12 {
    Fq12 { c0: fq6(c0, c1, c2, c3, c4, c5), c1: fq6(c6, c7, c8, c9, c10, c11), }
}

#[generate_trait]
impl Fq12Ops of Fq12OpsTrait {}

#[generate_trait]
impl Fq12Utils of Fq12UtilsTrait {}
