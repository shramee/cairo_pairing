use super::{Affine, ECOperations, ECGroupUtils, FieldOps, One};

pub impl AffineOpsBn<
    TCurve, T, +FieldOps<TCurve, T>, +Copy<T>, +Drop<TCurve>, +Drop<T>, +ECGroupUtils<TCurve, T>
> of ECOperations<TCurve, T> {
    #[inline(always)]
    fn x_on_slope(ref self: TCurve, pt: Affine<T>, slope: T, x2: T) -> T {
        // x = λ^2 - x1 - x2
        self.sub(self.sub(self.sqr(slope), pt.x), x2)
    }

    #[inline(always)]
    fn y_on_slope(ref self: TCurve, pt: Affine<T>, slope: T, x: T) -> T {
        // y = λ(x1 - x) - y1
        self.sub(self.mul(slope, self.sub(pt.x, x)), pt.y)
    }

    fn pt_on_slope(ref self: TCurve, pt: Affine<T>, slope: T, x2: T) -> Affine<T> {
        let x = self.x_on_slope(pt, slope, x2);
        let y = self.y_on_slope(pt, slope, x);
        Affine { x, y }
    }

    #[inline(always)]
    fn chord(ref self: TCurve, pt: Affine<T>, rhs: Affine<T>) -> T {
        let Affine { x: x1, y: y1 } = pt;
        let Affine { x: x2, y: y2 } = rhs;
        // λ = (y2-y1) / (x2-x1)
        self.div(self.sub(y2, y1), self.sub(x2, x1))
    }
    fn tangent(ref self: TCurve, pt: Affine<T>) -> T {
        let Affine { x, y } = pt;

        // λ = (3x^2 + a) / 2y
        // But BN curve has a == 0 so that's one less addition
        // λ = 3x^2 / 2y
        let x_2 = self.sqr(x);
        let three_x2 = self.add(self.add(x_2, x_2), x_2);
        self.div(three_x2, self.add(y, y))
    }

    #[inline(always)]
    fn pt_add(ref self: TCurve, pt: Affine<T>, rhs: Affine<T>) -> Affine<T> {
        self.pt_on_slope(pt, self.chord(pt, rhs), rhs.x)
    }


    fn pt_dbl(ref self: TCurve, pt: Affine<T>) -> Affine<T> {
        self.pt_on_slope(pt, self.tangent(pt), pt.x)
    }

    fn pt_mul(ref self: TCurve, pt: Affine<T>, mut multiplier: u256) -> Affine<T> {
        let nz2: NonZero<u256> = 2_u256.try_into().unwrap();
        let mut dbl_step = pt;
        let mut result: Affine<T> = self.pt_one();
        let mut first_add_done = false;

        // TODO: optimise with u128 ops
        // Replace u256 multiplier loop with 2x u128 loops
        loop {
            let (q, r) = DivRem::div_rem(multiplier, nz2);

            if r == 1 {
                result =
                    if !first_add_done {
                        first_add_done = true;
                        // self is zero, return rhs
                        dbl_step
                    } else {
                        self.pt_add(result, dbl_step)
                    }
            }

            if q == 0 {
                break;
            }
            dbl_step = self.pt_dbl(dbl_step);
            multiplier = q;
        };
        result
    }

    #[inline(always)]
    fn pt_neg(ref self: TCurve, pt: Affine<T>) -> Affine<T> {
        Affine { x: pt.x, y: self.neg(pt.y) }
    }
}

