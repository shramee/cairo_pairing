use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse};

#[derive(Copy, Drop, Serde)]
struct Fq {
    c0: u256
}

#[inline(always)]
fn fq(c0: u256) -> Fq {
    Fq { c0 }
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

impl FqAdd of Add<Fq> {
    #[inline(always)]
    fn add(lhs: Fq, rhs: Fq) -> Fq {
        fq(add(lhs.c0, rhs.c0))
    }
}
impl FqSub of Sub<Fq> {
    #[inline(always)]
    fn sub(lhs: Fq, rhs: Fq) -> Fq {
        fq(sub(lhs.c0, rhs.c0))
    }
}
impl FqMul of Mul<Fq> {
    #[inline(always)]
    fn mul(lhs: Fq, rhs: Fq) -> Fq {
        fq(mul(lhs.c0, rhs.c0))
    }
}
impl FqDiv of Div<Fq> {
    #[inline(always)]
    fn div(lhs: Fq, rhs: Fq) -> Fq {
        fq(div(lhs.c0, rhs.c0))
    }
}
impl FqNeg of Neg<Fq> {
    #[inline(always)]
    fn neg(a: Fq) -> Fq {
        fq(add_inverse(a.c0))
    }
}

impl FqPartialEq of PartialEq<Fq> {
    #[inline(always)]
    fn eq(lhs: @Fq, rhs: @Fq) -> bool {
        *lhs.c0 == *rhs.c0
    }

    #[inline(always)]
    fn ne(lhs: @Fq, rhs: @Fq) -> bool {
        lhs.c0 != rhs.c0
    }
}
