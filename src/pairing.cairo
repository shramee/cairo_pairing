use bn::g1::{AffineG1};
use bn::g2::{AffineG2};
use bn::fast_mod::bn254::{add, sub, mul, div};
use bn::FIELD;

fn line_func(a: AffineG1, b: AffineG1, t: AffineG1) -> u256 {
    let AffineG1{x: x1, y: y1 } = a;
    let AffineG1{x: x2, y: y2 } = b;
    let AffineG1{x: xt, y: yt } = t;

    if x1 != x2 {
        //m = (y2 - y1) / (x2 - x1)
        let m = div(sub(y2, y1), sub(x2, x1));
        //m * (xt - x1) - (yt - y1)
        sub(mul(m, sub(xt, x1)), sub(yt, y1))
    } else if y1 == y2 {
        //m = 3 * x1**2 / (2 * y1)
        let m = div(mul(3, mul(x1, x1)), mul(2, y1));
        //m * (xt - x1) - (yt - y1)
        sub(mul(m, sub(xt, x1)), sub(yt, y1))
    } else {
        //xt - x1
        sub(xt, x1)
    }
}
