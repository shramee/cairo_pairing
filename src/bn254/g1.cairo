use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use core::debug::PrintTrait;
use bn::traits::{ECOperations};
// use bn::fast_mod::bn254::{add, sub, div, mul, add_inverse};
use bn::bn254::{FIELD, B};
use integer::{u256_safe_divmod};
use bn::fields::{Fq, fq};

#[derive(Copy, Drop)]
struct AffineG1 {
    x: Fq,
    y: Fq
}

#[inline(always)]
fn pt(x: u256, y: u256) -> AffineG1 {
    AffineG1 { x: fq(x), y: fq(y) }
}

#[inline(always)]
fn one() -> AffineG1 {
    pt(1, 2)
}

impl AffineG1Ops of ECOperations<AffineG1> {
    fn add(self: @AffineG1, rhs: AffineG1) -> AffineG1 {
        let AffineG1{x: x1, y: y1 } = *self;
        let AffineG1{x: x2, y: y2 } = rhs;

        if x1.c0 + y1.c0 == 0 {
            // self is zero, return rhs
            return rhs;
        }

        // λ = (y2 - y1) / (x2 - x1)
        let lambda = (y2 - y1) / (x2 - x1);

        // v = y - λx
        let v = y1 - lambda * x1;

        // x = λ^2 - x1 - x2
        let x = lambda * lambda - x1 - x2;
        // y = - λx - v
        let y = -lambda * x - v;
        AffineG1 { x, y }
    }

    fn double(self: @AffineG1) -> AffineG1 {
        let AffineG1{x, y } = *self;

        // λ = (3x^2 + a) / 2y
        // let lambda = div(
        //     add(mul(3, mul(x, x)), a),
        //     mul(2, y),
        //     FIELD
        // );
        // But BN curve has a == 0 so that's one less addition
        // λ = 3x^2 / 2y
        let x_2 = x * x;
        let lambda = fq((x_2.c0 + x_2.c0 + x_2.c0) % FIELD) / (y + y);

        // v = y - λx
        let v = y - lambda * x;

        // New point
        // x = λ^2 - x - x
        let x = lambda * lambda - x - x;
        // y = - λx - v
        let y = -lambda * x - v;
        AffineG1 { x, y }
    }

    fn multiply(self: @AffineG1, mut multiplier: u256) -> AffineG1 {
        let nz2: NonZero<u256> = 2_u256.try_into().unwrap();
        let mut dbl_step = one();
        let mut result = pt(0, 0);

        // TODO: optimise with u128 ops
        // Replace u256 multiplier loop with 2x u128 loops
        loop {
            let (q, r, _) = u256_safe_divmod(multiplier, nz2);

            if r == 1 {
                result = result.add(dbl_step);
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
