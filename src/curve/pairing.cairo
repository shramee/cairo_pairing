use bn::g1::{AffineG1};
use bn::g2::{AffineG2};
use bn::curve::{add, sub, mul, div};
use bn::fields::{Fq, fq};
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::curve::FIELD;

// Finds the line going through points a and b
// and returns 0 is t falls on the line
#[inline(always)]
fn line_func(a: AffineG1, b: AffineG1, t: AffineG1) -> Fq {
    let AffineG1{x: x1, y: y1 } = a;
    let AffineG1{x: x2, y: y2 } = b;
    let AffineG1{x: xt, y: yt } = t;

    if x1.c0 != x2.c0 {
        //m = (y2 - y1) / (x2 - x1)
        let m = (y2 - y1) / (x2 - x1);
        //m * (xt - x1) - (yt - y1)
        m * (xt - x1) - (yt - y1)
    } else if y1.c0 == y2.c0 {
        //m = 3 * x1**2 / (2 * y1)
        let x1_2 = x1 * x1;
        let m = fq((x1_2.c0 + x1_2.c0 + x1_2.c0) % FIELD) / (y1 + y1);
        //m * (xt - x1) - (yt - y1)
        m * (xt - x1) - (yt - y1)
    } else {
        //xt - x1
        xt - x1
    }
}
