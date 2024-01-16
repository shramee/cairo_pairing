use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse};
use bn::traits::FieldOperations;

#[derive(Copy, Drop, Serde)]
struct Fq {
    c0: u256
}

#[inline(always)]
fn fq(c0: u256) -> Fq {
    Fq { c0 }
}

impl FqOperations of FieldOperations<Fq> {
    #[inline(always)]
    fn add(lhs: Fq, rhs: Fq) -> Fq {
        fq(add(lhs.c0, rhs.c0))
    }

    #[inline(always)]
    fn sub(lhs: Fq, rhs: Fq) -> Fq {
        fq(sub(lhs.c0, rhs.c0))
    }

    #[inline(always)]
    fn mul(lhs: Fq, rhs: Fq) -> Fq {
        fq(mul(lhs.c0, rhs.c0))
    }

    #[inline(always)]
    fn div(lhs: Fq, rhs: Fq) -> Fq {
        fq(div(lhs.c0, rhs.c0))
    }

    #[inline(always)]
    fn neg(a: Fq) -> Fq {
        fq(add_inverse(a.c0))
    }

    #[inline(always)]
    fn eq(lhs: @Fq, rhs: @Fq) -> bool {
        *lhs.c0 == *rhs.c0
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
