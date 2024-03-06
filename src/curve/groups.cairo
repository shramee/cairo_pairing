use bn::traits::{FieldOps as FOps, FieldShortcuts as FShort};
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl};
use bn::fields::{fq, Fq, fq2, Fq2};
use debug::PrintTrait as Print;

type AffineG1 = Affine<Fq>;
type AffineG2 = Affine<Fq2>;

#[derive(Copy, Drop)]
struct Affine<T> {
    x: T,
    y: T
}

trait ECGroup<TCoord> {
    fn one() -> Affine<TCoord>;
}

trait ECOperations<TCoord> {
    fn pt_on_slope(self: @Affine<TCoord>, slope: TCoord, x2: TCoord) -> Affine<TCoord>;
    fn chord(self: @Affine<TCoord>, rhs: Affine<TCoord>) -> TCoord;
    fn add(self: @Affine<TCoord>, rhs: Affine<TCoord>) -> Affine<TCoord>;
    fn tangent(self: @Affine<TCoord>) -> TCoord;
    fn double(self: @Affine<TCoord>) -> Affine<TCoord>;
    fn multiply(self: @Affine<TCoord>, multiplier: u256) -> Affine<TCoord>;
}

impl AffineOps<
    T, +FOps<T>, +FShort<T>, +Copy<T>, +Print<T>, +Drop<T>, impl ECGImpl: ECGroup<T>
> of ECOperations<T> {
    #[inline(always)]
    fn pt_on_slope(self: @Affine<T>, slope: T, x2: T) -> Affine<T> {
        let Affine { x: sx, y: sy } = *self;
        // x = λ^2 - sx - x2
        let x = slope.sqr() - sx - x2;
        // y = λ(sx - x) - sy
        let y = slope * (sx - x) - sy;
        Affine { x, y }
    }

    fn chord(self: @Affine<T>, rhs: Affine<T>) -> T {
        let Affine { x: x1, y: y1 } = *self;
        let Affine { x: x2, y: y2 } = rhs;
        (y2 - y1) / (x2 - x1)
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
        x_2.u_add(x_2).u_add(x_2) / y.u_add(y)
    }

    fn double(self: @Affine<T>) -> Affine<T> {
        self.pt_on_slope(self.tangent(), *self.x)
    }

    fn multiply(self: @Affine<T>, mut multiplier: u256) -> Affine<T> {
        let nz2: NonZero<u256> = 2_u256.try_into().unwrap();
        let mut dbl_step = ECGImpl::one();
        let mut result = ECGImpl::one();
        let mut first_add_done = false;

        // TODO: optimise with u128 ops
        // Replace u256 multiplier loop with 2x u128 loops
        loop {
            let (q, r, _) = integer::u256_safe_divmod(multiplier, nz2);

            if r == 1 {
                result =
                    if !first_add_done {
                        first_add_done = true;
                        // self is zero, return rhs
                        dbl_step
                    } else {
                        result.add(@dbl_step)
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
}

#[inline(always)]
fn g1(x: u256, y: u256) -> Affine<Fq> {
    Affine { x: fq(x), y: fq(y) }
}

fn g2(x1: u256, x2: u256, y1: u256, y2: u256) -> Affine<Fq2> {
    Affine { x: fq2(x1, x2), y: fq2(y1, y2) }
}

impl AffineG1Impl of ECGroup<Fq> {
    #[inline(always)]
    fn one() -> Affine<Fq> {
        g1(1, 2)
    }
}

impl AffineG2Impl of ECGroup<Fq2> {
    #[inline(always)]
    fn one() -> AffineG2 {
        g2(
            10857046999023057135944570762232829481370756359578518086990519993285655852781,
            11559732032986387107991004021392285783925812861821192530917403151452391805634,
            8495653923123431417604973247489272438418190587263600148770280649306958101930,
            4082367875863433681332203403145435568316851327593401208105741076214120093531
        )
    }
}
