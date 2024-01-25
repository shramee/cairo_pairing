// use bn::curve::{fq12_non_residue};
use bn::traits::{FieldUtils, FieldOps};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq6, fq6, Fq6Utils};
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
        assert(false, 'no_impl: fq12 scale');
        Fq12Utils::one()
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq12,) -> Fq12 {
        assert(false, 'no_impl: fq12 non residue');
        Fq12Utils::one()
    }

    #[inline(always)]
    fn frobenius_map(self: Fq12, power: usize) -> Fq12 {
        assert(false, 'no_impl: fq12 frobenius');
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
        core::internal::revoke_ap_tracking();
        let Fq12{c0: a0, c1: a1 } = self;
        let Fq12{c0: b0, c1: b1 } = rhs;
        let u = a0 * b0;
        let v = a1 * b1;

        Fq12 { //
         c0: v.mul_by_nonresidue() + u, //
         c1: (a0 + a1) * (b0 + b1) - u - v, //
         }
    }

    #[inline(always)]
    fn div(self: Fq12, rhs: Fq12) -> Fq12 {
        self.mul(rhs.inv())
    }

    #[inline(always)]
    fn neg(self: Fq12) -> Fq12 {
        Fq12 { c0: -self.c0, c1: -self.c1, }
    }

    #[inline(always)]
    fn eq(lhs: @Fq12, rhs: @Fq12) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1
    }

    #[inline(always)]
    fn sqr(self: Fq12) -> Fq12 {
        core::internal::revoke_ap_tracking();
        let Fq12{c0: a0, c1: a1 } = self;
        let v = a0 * a1;
        // Same as in Fq2, BETA is non residue
        // c = a ^ 2 = a0*a0 + a0*a1*X + a1*a0*X + a1*a1*BETA
        // c = a0*a0 + a1*a1*BETA + (a0*a1 + a1*a0)*X
        // or c = (a0*a0 + a1*a1*BETA, a0*a1 + a0*a1)
        Fq12 { //
         c0: a0.sqr() + a1.sqr().mul_by_nonresidue(), //
         c1: v + v, //
         }
    }

    #[inline(always)]
    fn inv(self: Fq12) -> Fq12 {
        core::internal::revoke_ap_tracking();
        // "High-Speed Software Implementation of the Optimal Ate Pairing
        // over Barreto–Naehrig Curves"; Algorithm 8
        if self.c0 == Fq6Utils::zero() && self.c1 == self.c0 {
            return self;
        }

        let t = (self.c0.sqr() - (self.c1.sqr().mul_by_nonresidue())).inv();
        // if self.c0.c0 + self.c1.c0 == 0 {
        //     return Fq12 { c0: fq(0), c1: fq(0), };
        // }
        // let t = (self.c0.sqr() - (self.c1.sqr().mul_by_nonresidue())).inv();

        // Fq12 { c0: self.c0 * t, c1: self.c1 * -t, }
        Fq12 { c0: self.c0 * t, c1: -(self.c1 * t), }
    }
}
