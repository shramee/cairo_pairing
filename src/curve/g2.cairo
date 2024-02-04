// Twisted BN curve
// E'/Fq2 : y^2 = x^3 + b/xi
// 

use bn::fields::{Fq, Fq2, Fq2Utils, fq2, FieldUtils};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use core::debug::PrintTrait;
use bn::traits::{ECOperations};
use bn::curve::groups::Affine;
use bn::curve::{FIELD, B};
use integer::{u256_safe_divmod};

type AffineG2 = Affine<Fq2>;

#[inline(always)]
fn pt(x1: u256, x2: u256, y1: u256, y2: u256) -> AffineG2 {
    AffineG2 { x: fq2(x1, x2), y: fq2(y1, y2) }
}

#[inline(always)]
fn one() -> AffineG2 {
    pt(
        10857046999023057135944570762232829481370756359578518086990519993285655852781,
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        8495653923123431417604973247489272438418190587263600148770280649306958101930,
        4082367875863433681332203403145435568316851327593401208105741076214120093531
    )
}

#[generate_trait]
impl AffineG2Impl of AffineG2Trait {
    fn to_tuple(self: AffineG2) -> (u256, u256, u256, u256) {
        (self.x.c0.c0, self.x.c1.c0, self.y.c0.c0, self.y.c1.c0,)
    }
}

impl AffineG2Ops of ECOperations<AffineG2> {
    fn add(self: @AffineG2, rhs: AffineG2) -> AffineG2 {
        let AffineG2{x: x1, y: y1 } = *self;
        let AffineG2{x: x2, y: y2 } = rhs;

        if x1.c0.c0 + x1.c1.c0 + y1.c0.c0 + y1.c1.c0 == 0 {
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
        AffineG2 { x, y }
    }

    fn double(self: @AffineG2) -> AffineG2 {
        let AffineG2{x, y } = *self;

        // λ = (3x^2 + a) / 2y
        // let lambda = div(
        //     add(mul(3, mul(x, x)), a),
        //     mul(2, y),
        //     FIELD
        // );
        // But BN curve has a == 0 so that's one less addition
        // λ = 3x^2 / 2y
        let x_2 = x * x;
        let lambda = fq2( //
            (x_2.c0.c0 + x_2.c0.c0 + x_2.c0.c0) % FIELD, //
            (x_2.c1.c0 + x_2.c1.c0 + x_2.c1.c0) % FIELD //
        )
            / (y + y);

        // v = y - λx
        let v = y - lambda * x;

        // New point
        // x = λ^2 - x - x
        let x = lambda * lambda - x - x;
        // y = - λx - v
        let y = -lambda * x - v;
        AffineG2 { x, y }
    }

    fn multiply(self: @AffineG2, mut multiplier: u256) -> AffineG2 {
        let nz2: NonZero<u256> = 2_u256.try_into().unwrap();
        let mut dbl_step = one();
        let mut result = pt(0, 0, 0, 0);

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

