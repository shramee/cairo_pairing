// use bn::curve::{fq12_non_residue};
use bn::traits::{FieldUtils, FieldOps};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq6, fq6, Fq6Utils, fq2};
use bn::fields::fq6_::{Fq6Frobenius};
use bn::fields::frobenius::fp12 as frob;
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
fn fq12(
    c0: u256,
    c1: u256,
    c2: u256,
    c3: u256,
    c4: u256,
    c5: u256,
    c20: u256,
    c21: u256,
    c22: u256,
    c23: u256,
    c24: u256,
    c25: u256
) -> Fq12 {
    Fq12 { c0: fq6(c0, c1, c2, c3, c4, c5,), c1: fq6(c20, c21, c22, c23, c24, c25,), }
}

#[generate_trait]
impl Fq12Frobenius of Fq12FrobeniusTrait {
    #[inline(always)]
    fn frob0(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob0(), c1: c1.frob0().scale(fq2(frob::Q_0_C0, frob::Q_0_C1)), }
    }

    #[inline(always)]
    fn frob1(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob1(), c1: c1.frob1().scale(fq2(frob::Q_1_C0, frob::Q_1_C1)), }
    }

    #[inline(always)]
    fn frob2(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob2(), c1: c1.frob2().scale(fq2(frob::Q_2_C0, frob::Q_2_C1)), }
    }

    #[inline(always)]
    fn frob3(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob3(), c1: c1.frob3().scale(fq2(frob::Q_3_C0, frob::Q_3_C1)), }
    }

    #[inline(always)]
    fn frob4(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob4(), c1: c1.frob4().scale(fq2(frob::Q_4_C0, frob::Q_4_C1)), }
    }

    #[inline(always)]
    fn frob5(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob5(), c1: c1.frob5().scale(fq2(frob::Q_5_C0, frob::Q_5_C1)), }
    }

    #[inline(always)]
    fn frob6(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob0(), c1: c1.frob0().scale(fq2(frob::Q_6_C0, frob::Q_6_C1)), }
    }

    #[inline(always)]
    fn frob7(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob1(), c1: c1.frob1().scale(fq2(frob::Q_7_C0, frob::Q_7_C1)), }
    }

    #[inline(always)]
    fn frob8(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob2(), c1: c1.frob2().scale(fq2(frob::Q_8_C0, frob::Q_8_C1)), }
    }

    #[inline(always)]
    fn frob9(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob3(), c1: c1.frob3().scale(fq2(frob::Q_9_C0, frob::Q_9_C1)), }
    }

    #[inline(always)]
    fn frob10(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob4(), c1: c1.frob4().scale(fq2(frob::Q_10_C0, frob::Q_10_C1)), }
    }


    #[inline(always)]
    fn frob11(self: Fq12) -> Fq12 {
        let Fq12{c0, c1 } = self;
        Fq12 { c0: c0.frob5(), c1: c1.frob5().scale(fq2(frob::Q_11_C0, frob::Q_11_C1)), }
    }
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
    fn conjugate(self: Fq12) -> Fq12 {
        Fq12 { c0: self.c0, c1: -self.c1, }
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
