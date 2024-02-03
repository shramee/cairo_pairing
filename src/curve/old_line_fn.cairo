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

#[cfg(tests)]
mod tests {
    use bn::traits::ECOperations;
    use super::line_func;
    use bn::{g1, g2};
    use bn::curve::ORDER;

    #[test]
    #[available_gas(2000000000)]
    fn test_line_func() {
        let one = g1::one();
        let two = one.double();
        let three = two.add(one);
        let negthree = g1::one().multiply(ORDER - 3);
        // let negtwo = g1::one().multiply(ORDER - 2);
        let negtwo = negthree.add(g1::one());
        // let negone = g1::one().multiply(ORDER - 1);
        let negone = negtwo.add(g1::one());

        // Adding a tenth test breaks stuff with:
        //  #747->#748: Got 'Offset overflow' error while moving [29].

        // assert(line_func(one, two, one).c0 == 0, 'wrong line one, two, one');
        assert(line_func(one, two, two).c0 == 0, 'wrong line one, two, two');
        assert(line_func(one, two, three).c0 != 0, 'wrong line one, two, three');
        assert(line_func(one, two, negthree).c0 == 0, 'wrong line one, two, negthree');
        assert(line_func(one, negone, one).c0 == 0, 'wrong line one, negone, one');
        assert(line_func(one, negone, negone).c0 == 0, 'wrong line one, negone, negone');
        assert(line_func(one, negone, two).c0 != 0, 'wrong line one, negone, two');
        assert(line_func(one, one, one).c0 == 0, 'wrong line one, one, one');
        assert(line_func(one, one, two).c0 != 0, 'wrong line one, one, two');
        assert(line_func(one, one, negtwo).c0 == 0, 'wrong line one, one, negtwo');
    }

    #[test]
    #[available_gas(200000000)]
    fn bench_line_func() {
        // bench_line_func ... ok (gas: 350050)
        // bench_line_func ... ok (gas: 287880)
        line_func(g1::one(), g1::one(), g1::one());
    }
}
