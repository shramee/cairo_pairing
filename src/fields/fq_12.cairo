use bn::traits::{FieldUtils, FieldOps};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq6, fq6, Fq6Utils, fq2, Fq6Frobenius};
use bn::fields::frobenius::fp12 as frob;
use debug::PrintTrait;

#[derive(Copy, Drop, Serde, Debug)]
struct Fq12 {
    c0: Fq6,
    c1: Fq6,
}

// Extension field is represented as two number with X (a root of an polynomial in Fq which doesn't exist in Fq).
// X for field extension is equivalent to imaginary i for real numbers.
// number a: Fq12 = (a0, a1), mathematically, a = a0 + a1 * X

type ui = u256;

#[inline(always)]
fn fq12(
    a0: ui, a1: ui, a2: ui, a3: ui, a4: ui, a5: ui, b0: ui, b1: ui, b2: ui, b3: ui, b4: ui, b5: ui
) -> Fq12 {
    Fq12 { c0: fq6(a0, a1, a2, a3, a4, a5), c1: fq6(b0, b1, b2, b3, b4, b5), }
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
        let rem = power % 12;
        if rem == 1 {
            self.frob1()
        } else if rem == 2 {
            self.frob2()
        } else if rem == 3 {
            self.frob3()
        } else if rem == 4 {
            self.frob4()
        } else if rem == 5 {
            self.frob5()
        } else if rem == 6 {
            self.frob6()
        } else if rem == 7 {
            self.frob7()
        } else if rem == 8 {
            self.frob8()
        } else if rem == 9 {
            self.frob9()
        } else if rem == 10 {
            self.frob10()
        } else if rem == 11 {
            self.frob11()
        } else {
            self.frob0()
        }
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
        // Complex squaring
        let v = a0 * a1;
        // (a0 + a1) * (a0 + βa1) - v - βv
        let c0 = (a0 + a1) * (a0 + a1.mul_by_nonresidue()) - v - v.mul_by_nonresidue();
        // 2v
        let c1 = v + v;
        Fq12 { c0, c1 }
    }

    #[inline(always)]
    fn inv(self: Fq12) -> Fq12 {
        core::internal::revoke_ap_tracking();
        // "High-Speed Software Implementation of the Optimal Ate Pairing
        // over Barreto–Naehrig Curves"; Algorithm 8
        let t = (self.c0.sqr() - (self.c1.sqr().mul_by_nonresidue())).inv();
        // if self.c0.c0 + self.c1.c0 == 0 {
        //     return Fq12 { c0: fq(0), c1: fq(0), };
        // }
        // let t = (self.c0.sqr() - (self.c1.sqr().mul_by_nonresidue())).inv();

        // Fq12 { c0: self.c0 * t, c1: self.c1 * -t, }
        Fq12 { c0: self.c0 * t, c1: -(self.c1 * t), }
    }
}
