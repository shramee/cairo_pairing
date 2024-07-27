use core::traits::Into;
use bn254_u256::{Bn254U256Curve, Fq, Fq2, Fq6, Fq12, FqD12, PtG1, PtG2, F034, FqD4};
use bn254_u256::{U256IntoFq, Bn254FqOps, scale_9};
use fq_types::fq2 as fq2_from_fq;

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

pub fn fqd12(
    r0: u256,
    r1: u256,
    r2: u256,
    r3: u256,
    r4: u256,
    r5: u256,
    r6: u256,
    r7: u256,
    r8: u256,
    r9: u256,
    r10: u256,
    r11: u256
) -> FqD12 {
    (
        (r0.into(), r1.into(), r2.into(), r3.into(),),
        (r4.into(), r5.into(), r6.into(), r7.into(),),
        (r8.into(), r9.into(), r10.into(), r11.into(),),
    )
}

pub fn fq2(c0: u256, c1: u256) -> Fq2 {
    Fq2 { c0: c0.into(), c1: c1.into() }
}

pub fn tower_to_direct_fq12(ref curve: Bn254U256Curve, a: Fq12) -> FqD12 {
    let Fq12 { //
    c0: Fq6 { //
     c0: Fq2 { c0: a0, c1: a1 }, c1: Fq2 { c0: a2, c1: a3 }, c2: Fq2 { c0: a4, c1: a5 } },
    c1: Fq6 { //
     c0: Fq2 { c0: a6, c1: a7 }, c1: Fq2 { c0: a8, c1: a9 }, c2: Fq2 { c0: a10, c1: a11 } } //
    } =
        a;
    (
        (
            curve.sub(a0, scale_9(ref curve, a1)),
            curve.sub(a6, scale_9(ref curve, a7)),
            curve.sub(a2, scale_9(ref curve, a3)),
            curve.sub(a8, scale_9(ref curve, a9)),
        ),
        (curve.sub(a4, scale_9(ref curve, a5)), curve.sub(a10, scale_9(ref curve, a11)), a1, a7,),
        (a3, a9, a5, a11,)
    )
}

pub fn direct_to_tower_fq12(ref curve: Bn254U256Curve, a: FqD12) -> Fq12 {
    let ((a0, a1, a2, a3), (a4, a5, a6, a7), (a8, a9, a10, a11)) = a;

    Fq12 {
        c0: Fq6 {
            c0: fq2_from_fq(curve.add(a0, scale_9(ref curve, a6)), a6),
            c1: fq2_from_fq(curve.add(a2, scale_9(ref curve, a8)), a8),
            c2: fq2_from_fq(curve.add(a4, scale_9(ref curve, a10)), a10),
        },
        c1: Fq6 {
            c0: fq2_from_fq(curve.add(a1, scale_9(ref curve, a7)), a7),
            c1: fq2_from_fq(curve.add(a3, scale_9(ref curve, a9)), a9),
            c2: fq2_from_fq(curve.add(a5, scale_9(ref curve, a11)), a11),
        }
    }
}

pub fn direct_f034(ref curve: Bn254U256Curve, a: F034) -> FqD4 {
    let F034 { c3: Fq2 { c0: a6, c1: a7 }, c4: Fq2 { c0: a8, c1: a9 } } = a;
    (
        curve.sub(a6, scale_9(ref curve, a7)), // c1
        curve.sub(a8, scale_9(ref curve, a9)), // c3
        a7, // c7
        a9, // c9
    )
}
