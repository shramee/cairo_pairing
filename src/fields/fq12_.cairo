// use bn::curve::{fq12_non_residue};
use bn::traits::{FieldUtils, FieldOps};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq6, fq6,};
use debug::PrintTrait;

#[derive(Copy, Drop, Serde)]
struct Fq12 {
    c0: Fq6,
    c1: Fq6,
}

// Extension field is represented as two number with X (a root of an polynomial in Fq which doesn't exist in Fq).
// X for field extension is equivalent to imaginary i for real numbers.
// number a: Fq12 = (a0, a1), mathematically, a = a0 + a1 * X

#[inline(always)]
fn fq12(c0: Fq6, c1: Fq6) -> Fq12 {
    Fq12 { c0, c1, }
}

impl Fq12Utils of FieldUtils<Fq12, Fq6> {
    #[inline(always)]
    fn one() -> Fq12 {
        Fq12 { c0: FieldUtils::one(), c1: FieldUtils::zero(), }
    }

    #[inline(always)]
    fn zero() -> Fq12 {
        Fq12 { c0: FieldUtils::zero(), c1: FieldUtils::zero(), }
    }

    #[inline(always)]
    fn scale(self: Fq12, by: Fq6) -> Fq12 {
        assert(false, 'fq12 scale unimplemented');
        Fq12Utils::one()
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq12,) -> Fq12 {
        assert(false, 'fq12 non residue unimplemented');
        Fq12Utils::one()
    }

    #[inline(always)]
    fn frobenius_map(self: Fq12, power: usize) -> Fq12 {
        assert(false, 'fq12 non residue unimplemented');
        Fq12Utils::one()
    }
}

impl Fq12Ops of FieldOps<Fq12> {
    #[inline(always)]
    fn add(self: Fq12, rhs: Fq12) -> Fq12 {
        Fq12 { c0: self.c0 + rhs.c0, c1: self.c1 + rhs.c1, }
    }

    #[inline(always)]
    fn sub(self: Fq12, rhs: Fq12) -> Fq12 {
        Fq12 { c0: self.c0 - rhs.c0, c1: self.c1 - rhs.c1, }
    }

    #[inline(always)]
    fn mul(self: Fq12, rhs: Fq12) -> Fq12 {
    }

    #[inline(always)]
    fn div(self: Fq12, rhs: Fq12) -> Fq12 {
    }

    #[inline(always)]
    fn neg(self: Fq12) -> Fq12 {
    }

    #[inline(always)]
    fn eq(lhs: @Fq12, rhs: @Fq12) -> bool {
    }

    #[inline(always)]
    fn sqr(self: Fq12) -> Fq12 {
    }

    #[inline(always)]
    fn inv(self: Fq12) -> Fq12 {
    }
}
