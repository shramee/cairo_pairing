use bn::curve::{FIELD, add, sub, mul, scale, sqr, div, add_inverse, inv};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::traits::{FieldUtils, FieldOps, FieldShortcuts};
use debug::PrintTrait;

#[derive(Copy, Drop, Serde)]
struct Fq {
    c0: u256
}

#[inline(always)]
fn fq(c0: u256) -> Fq {
    Fq { c0 }
}

impl FqShort of FieldShortcuts<Fq> {
    #[inline(always)]
    fn x_add(self: Fq, rhs: Fq) -> Fq {
        // Operation without modding can only be done like 4 times
        Fq { c0: self.c0 + rhs.c0, }
    }

    #[inline(always)]
    fn fix_mod(self: Fq) -> Fq {
        // Operation without modding can only be done like 4 times
        Fq { c0: self.c0 % FIELD }
    }
}

impl FqUtils of FieldUtils<Fq, u128> {
    #[inline(always)]
    fn one() -> Fq {
        fq(1)
    }

    #[inline(always)]
    fn zero() -> Fq {
        fq(0)
    }

    #[inline(always)]
    fn scale(self: Fq, by: u128) -> Fq {
        Fq { c0: scale(self.c0, by) }
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq,) -> Fq {
        if self.c0 > 0 {
            -self
        } else {
            self
        }
    }

    #[inline(always)]
    fn conjugate(self: Fq) -> Fq {
        assert(false, 'no_impl: fq conjugate');
        FieldUtils::zero()
    }

    #[inline(always)]
    fn frobenius_map(self: Fq, power: usize) -> Fq {
        assert(false, 'no_impl: fq frobenius_map');
        fq(0)
    }
}

impl FqOps of FieldOps<Fq> {
    #[inline(always)]
    fn add(self: Fq, rhs: Fq) -> Fq {
        fq(add(self.c0, rhs.c0))
    }

    #[inline(always)]
    fn sub(self: Fq, rhs: Fq) -> Fq {
        fq(sub(self.c0, rhs.c0))
    }

    #[inline(always)]
    fn mul(self: Fq, rhs: Fq) -> Fq {
        fq(mul(self.c0, rhs.c0))
    }

    #[inline(always)]
    fn div(self: Fq, rhs: Fq) -> Fq {
        fq(div(self.c0, rhs.c0))
    }

    #[inline(always)]
    fn neg(self: Fq) -> Fq {
        fq(add_inverse(self.c0))
    }

    #[inline(always)]
    fn eq(lhs: @Fq, rhs: @Fq) -> bool {
        *lhs.c0 == *rhs.c0
    }

    #[inline(always)]
    fn sqr(self: Fq) -> Fq {
        fq(sqr(self.c0))
    }

    #[inline(always)]
    fn inv(self: Fq) -> Fq {
        fq(inv(self.c0))
    }
}

impl FqIntoU256 of Into<Fq, u256> {
    #[inline(always)]
    fn into(self: Fq) -> u256 {
        self.c0
    }
}
impl U256IntoFq of Into<u256, Fq> {
    #[inline(always)]
    fn into(self: u256) -> Fq {
        fq(self)
    }
}
impl Felt252IntoFq of Into<felt252, Fq> {
    #[inline(always)]
    fn into(self: felt252) -> Fq {
        fq(self.into())
    }
}
