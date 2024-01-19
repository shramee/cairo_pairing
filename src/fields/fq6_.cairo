use bn::fields::{Fq2, Fq2Ops, fq2};
use bn::traits::{FieldUtils, FieldOps};
use bn::fq2_non_residue;
use debug::PrintTrait;

#[derive(Copy, Drop, Serde)]
struct Fq6 {
    c0: Fq2,
    c1: Fq2,
    c2: Fq2,
}

#[inline(always)]
fn fq6(c0: u256, c1: u256, c2: u256, c3: u256, c4: u256, c5: u256) -> Fq6 {
    Fq6 { c0: fq2(c0, c1), c1: fq2(c2, c3), c2: fq2(c4, c5) }
}

impl Fq6Utils of FieldUtils<Fq6, Fq2> {
    #[inline(always)]
    fn one() -> Fq6 {
        fq6(1, 0, 0, 0, 0, 0)
    }
    #[inline(always)]
    fn scale(self: Fq6, by: Fq2) -> Fq6 {
        Fq6 { c0: self.c0 * by, c1: self.c1 * by, c2: self.c2 * by, }
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq6,) -> Fq6 {
        // TODO
        assert(false, 'unimp: fq6 mul non_res');
        Fq6Utils::one()
    }

    #[inline(always)]
    fn frobenius_map(self: Fq6, power: usize) -> Fq6 {
        if power % 2 == 0 {
            self
        } else {
            Fq6 { c0: self.c0, c2: self.c2, c1: self.c1 * fq2_non_residue(), }
        }
    }
}

impl Fq6Ops of FieldOps<Fq6> {
    #[inline(always)]
    fn add(self: Fq6, rhs: Fq6) -> Fq6 {
        Fq6 { c0: self.c0 + rhs.c0, c1: self.c1 + rhs.c1, c2: self.c2 + rhs.c2, }
    }

    #[inline(always)]
    fn sub(self: Fq6, rhs: Fq6) -> Fq6 {
        Fq6 { c0: self.c0 - rhs.c0, c1: self.c1 - rhs.c1, c2: self.c2 - rhs.c2, }
    }

    #[inline(always)]
    fn mul(self: Fq6, rhs: Fq6) -> Fq6 {
        // TODO
        Fq6Utils::one()
    }

    #[inline(always)]
    fn div(self: Fq6, rhs: Fq6) -> Fq6 {
        assert(false, 'unimp: fq6 mul non_res');
        // TODO
        Fq6Utils::one()
    }

    #[inline(always)]
    fn neg(self: Fq6) -> Fq6 {
        assert(false, 'unimp: fq6 mul non_res');
        // TODO
        Fq6Utils::one()
    }

    #[inline(always)]
    fn eq(lhs: @Fq6, rhs: @Fq6) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1 && lhs.c2 == rhs.c2
    }

    #[inline(always)]
    fn sqr(self: Fq6) -> Fq6 {
        // TODO
        Fq6Utils::one()
    }

    #[inline(always)]
    fn inv(self: Fq6) -> Fq6 {
        // TODO
        Fq6Utils::one()
    }
}

