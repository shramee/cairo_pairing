use bn::fields::{Fq, fq,};

#[derive(Copy, Drop, Serde)]
struct Fq2 {
    c0: Fq,
    c1: Fq,
}

#[inline(always)]
fn fq2(c0: u256, c1: u256) -> Fq2 {
    Fq2 { c0: fq(c0), c1: fq(c1), }
}

impl Fq2Add of Add<Fq2> {
    #[inline(always)]
    fn add(lhs: Fq2, rhs: Fq2) -> Fq2 {
        Fq2 { c0: lhs.c0 + rhs.c0, c1: lhs.c1 + rhs.c1, }
    }
}
impl Fq2Sub of Sub<Fq2> {
    #[inline(always)]
    fn sub(lhs: Fq2, rhs: Fq2) -> Fq2 {
        Fq2 { c0: lhs.c0 - rhs.c0, c1: lhs.c1 - rhs.c1, }
    }
}
impl Fq2Mul of Mul<Fq2> {
    #[inline(always)]
    fn mul(lhs: Fq2, rhs: Fq2) -> Fq2 {
        // fq(mul(lhs.c0, rhs.c0))
        fq2(0, 0)
    }
}
impl Fq2Div of Div<Fq2> {
    #[inline(always)]
    fn div(lhs: Fq2, rhs: Fq2) -> Fq2 {
        // fq(div(lhs.c0, rhs.c0))
        fq2(0, 0)
    }
}
impl Fq2Neg of Neg<Fq2> {
    #[inline(always)]
    fn neg(a: Fq2) -> Fq2 {
        // fq(add_inverse(a.c0))
        fq2(0, 0)
    }
}

impl Fq2PartialEq of PartialEq<Fq2> {
    #[inline(always)]
    fn eq(lhs: @Fq2, rhs: @Fq2) -> bool {
        *lhs.c0 == *rhs.c0 && *lhs.c1 == *rhs.c1
    }

    #[inline(always)]
    fn ne(lhs: @Fq2, rhs: @Fq2) -> bool {
        lhs != rhs
    }
}
