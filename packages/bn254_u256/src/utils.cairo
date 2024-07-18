use core::traits::Into;
use bn254_u256::{Fq, Fq2, Fq6, Fq12, U256IntoFq, PtG1, PtG2};

pub fn g1(x: u256, y: u256) -> PtG1 {
    let x = x.into();
    let y = y.into();
    PtG1 { x, y }
}
pub fn g2(x0: u256, x1: u256, y0: u256, y1: u256) -> PtG2 {
    PtG2 { x: fq2(x0, x1), y: fq2(y0, y1) }
}
pub fn fq12(
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
    c11: u256,
) -> Fq12 {
    Fq12 {
        c0: Fq6 { c0: fq2(c0, c1), c1: fq2(c2, c3), c2: fq2(c4, c5) },
        c1: Fq6 { c0: fq2(c6, c7), c1: fq2(c8, c9), c2: fq2(c10, c11) },
    }
}

pub fn fq(c0: u256) -> Fq {
    c0.into()
}

pub fn fq2(c0: u256, c1: u256) -> Fq2 {
    Fq2 { c0: c0.into(), c1: c1.into() }
}
