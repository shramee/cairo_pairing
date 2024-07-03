use fq_types::{FieldCommonOps, FieldOps};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl};
use core::num::traits::One;

#[derive(Copy, Drop, Serde)]
struct Affine<T> {
    x: T,
    y: T
}

trait ECOperations<TCoord> {
    fn x_on_slope(self: @Affine<TCoord>, slope: TCoord, x2: TCoord) -> TCoord;
    fn y_on_slope(self: @Affine<TCoord>, slope: TCoord, x: TCoord) -> TCoord;
    fn pt_on_slope(self: @Affine<TCoord>, slope: TCoord, x2: TCoord) -> Affine<TCoord>;
    fn chord(self: @Affine<TCoord>, rhs: Affine<TCoord>) -> TCoord;
    fn add(self: @Affine<TCoord>, rhs: Affine<TCoord>) -> Affine<TCoord>;
    fn tangent(self: @Affine<TCoord>) -> TCoord;
    fn double(self: @Affine<TCoord>) -> Affine<TCoord>;
    fn multiply(self: @Affine<TCoord>, multiplier: u256) -> Affine<TCoord>;
    fn neg(self: @Affine<TCoord>) -> Affine<TCoord>;
}

impl AffinePartialEq<T, +PartialEq<T>> of PartialEq<Affine<T>> {
    fn eq(lhs: @Affine<T>, rhs: @Affine<T>) -> bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    fn ne(lhs: @Affine<T>, rhs: @Affine<T>) -> bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

impl AffineOps<
    T, +FieldOps<T>, +FieldCommonOps<T>, +Copy<T>, +Drop<T>, +One<Affine<T>>
> of ECOperations<T> {
    #[inline(always)]
    fn x_on_slope(self: @Affine<T>, slope: T, x2: T) -> T {
        // x = λ^2 - x1 - x2
        slope.sqr().sub(*self.x).sub(x2)
    }

    #[inline(always)]
    fn y_on_slope(self: @Affine<T>, slope: T, x: T) -> T {
        // y = λ(x1 - x) - y1
        slope.mul((*self.x).sub(x)).sub(*self.y)
    }

    fn pt_on_slope(self: @Affine<T>, slope: T, x2: T) -> Affine<T> {
        let x = self.x_on_slope(slope, x2);
        let y = self.y_on_slope(slope, x);
        Affine { x, y }
    }

    #[inline(always)]
    fn chord(self: @Affine<T>, rhs: Affine<T>) -> T {
        let Affine { x: x1, y: y1 } = *self;
        let Affine { x: x2, y: y2 } = rhs;
        // λ = (y2-y1) / (x2-x1)
        y2.sub(y1).div(x2.sub(x1))
    }

    fn add(self: @Affine<T>, rhs: Affine<T>) -> Affine<T> {
        self.pt_on_slope(self.chord(rhs), rhs.x)
    }

    fn tangent(self: @Affine<T>) -> T {
        let Affine { x, y } = *self;

        // λ = (3x^2 + a) / 2y
        // But BN curve has a == 0 so that's one less addition
        // λ = 3x^2 / 2y
        let x_2 = x.sqr();
        (x_2.add(x_2).add(x_2)).div(y.add(y))
    }

    fn double(self: @Affine<T>) -> Affine<T> {
        self.pt_on_slope(self.tangent(), *self.x)
    }

    fn multiply(self: @Affine<T>, mut multiplier: u256) -> Affine<T> {
        let nz2: NonZero<u256> = 2_u256.try_into().unwrap();
        let mut dbl_step = *self;
        let mut result = One::<Affine<T>>::one();
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
                        result.add(dbl_step)
                    }
            }

            if q == 0 {
                break;
            }
            dbl_step = dbl_step.double();
            multiplier = q;
        };
        result
    }

    #[inline(always)]
    fn neg(self: @Affine<T>) -> Affine<T> {
        Affine { x: *self.x, y: (*self.y).neg() }
    }
}
