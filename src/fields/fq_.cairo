use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse, inv};
use bn::traits::FieldOps;

#[derive(Copy, Drop, Serde)]
struct Fq {
    c0: u256
}

#[inline(always)]
fn fq(c0: u256) -> Fq {
    Fq { c0 }
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
    fn one() -> Fq {
        fq(1)
    }

    #[inline(always)]
    fn sqr(self: Fq) -> Fq {
        fq(mul(self.c0, self.c0))
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
