use bn::curve::{FIELD};
use bn::curve::{u512, U512BnAdd, Tuple2Add, U512BnSub, Tuple2Sub, mul_by_xi, u512_reduce};
use bn::fields::{print::Fq6PrintImpl, Fq2, Fq2Ops, fq2};
use bn::traits::{FieldUtils, FieldOps, FieldShortcuts, FieldMulShortcuts};
use bn::fields::frobenius::fp6 as frob;
use bn::fields::fq2_::Fq2Frobenius;
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

use debug::PrintTrait;

#[derive(Copy, Drop, Serde, Debug)]
struct Fq6 {
    c0: Fq2,
    c1: Fq2,
    c2: Fq2,
}

#[inline(always)]
fn fq6(c0: u256, c1: u256, c2: u256, c3: u256, c4: u256, c5: u256) -> Fq6 {
    Fq6 { c0: fq2(c0, c1), c1: fq2(c2, c3), c2: fq2(c4, c5) }
}

#[generate_trait]
impl Fq6Frobenius of Fq6FrobeniusTrait {
    #[inline(always)]
    fn frob0(self: Fq6) -> Fq6 {
        let Fq6{c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob0(),
            c1: c1.frob0() * fq2(frob::Q_0_C0, frob::Q_0_C1),
            c2: c2.frob0() * fq2(frob::Q2_0_C0, frob::Q2_0_C1),
        }
    }

    #[inline(always)]
    fn frob1(self: Fq6) -> Fq6 {
        let Fq6{c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob1(),
            c1: c1.frob1() * fq2(frob::Q_1_C0, frob::Q_1_C1),
            c2: c2.frob1() * fq2(frob::Q2_1_C0, frob::Q2_1_C1),
        }
    }

    #[inline(always)]
    fn frob2(self: Fq6) -> Fq6 {
        let Fq6{c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob0(),
            c1: c1.frob0() * fq2(frob::Q_2_C0, frob::Q_2_C1),
            c2: c2.frob0() * fq2(frob::Q2_2_C0, frob::Q2_2_C1),
        }
    }

    #[inline(always)]
    fn frob3(self: Fq6) -> Fq6 {
        let Fq6{c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob1(),
            c1: c1.frob1() * fq2(frob::Q_3_C0, frob::Q_3_C1),
            c2: c2.frob1() * fq2(frob::Q2_3_C0, frob::Q2_3_C1),
        }
    }

    #[inline(always)]
    fn frob4(self: Fq6) -> Fq6 {
        let Fq6{c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob0(),
            c1: c1.frob0() * fq2(frob::Q_4_C0, frob::Q_4_C1),
            c2: c2.frob0() * fq2(frob::Q2_4_C0, frob::Q2_4_C1),
        }
    }

    #[inline(always)]
    fn frob5(self: Fq6) -> Fq6 {
        let Fq6{c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob1(),
            c1: c1.frob1() * fq2(frob::Q_5_C0, frob::Q_5_C1),
            c2: c2.frob1() * fq2(frob::Q2_5_C0, frob::Q2_5_C1),
        }
    }
}

impl Fq6Utils of FieldUtils<Fq6, Fq2> {
    #[inline(always)]
    fn one() -> Fq6 {
        fq6(1, 0, 0, 0, 0, 0)
    }

    #[inline(always)]
    fn zero() -> Fq6 {
        fq6(0, 0, 0, 0, 0, 0)
    }

    #[inline(always)]
    fn scale(self: Fq6, by: Fq2) -> Fq6 {
        Fq6 { c0: self.c0 * by, c1: self.c1 * by, c2: self.c2 * by, }
    }

    #[inline(always)]
    fn conjugate(self: Fq6) -> Fq6 {
        assert(false, 'no_impl: fq6 conjugate');
        FieldUtils::zero()
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq6,) -> Fq6 {
        // https://github.com/paritytech/bn/blob/master/src/fields/fq6.rs#L110
        Fq6 { c0: self.c2.mul_by_nonresidue(), c1: self.c0, c2: self.c1, }
    }

    #[inline(always)]
    fn frobenius_map(self: Fq6, power: usize) -> Fq6 {
        let rem = power % 6;
        if rem == 0 {
            self.frob0()
        } else if rem == 1 {
            self.frob1()
        } else if rem == 2 {
            self.frob2()
        } else if rem == 3 {
            self.frob3()
        } else if rem == 4 {
            self.frob4()
        } else {
            self.frob5()
        }
    }
}

impl Fq6Short of FieldShortcuts<Fq6> {
    #[inline(always)]
    fn u_add(self: Fq6, rhs: Fq6) -> Fq6 {
        // Operation without modding can only be done like 4 times
        Fq6 { //
            c0: self.c0.u_add(rhs.c0), //
            c1: self.c1.u_add(rhs.c1), //
            c2: self.c2.u_add(rhs.c2), //
        }
    }
    #[inline(always)]
    fn fix_mod(self: Fq6) -> Fq6 {
        // Operation without modding can only be done like 4 times
        Fq6 { //
         c0: self.c0.fix_mod(), //
         c1: self.c1.fix_mod(), //
         c2: self.c2.fix_mod(), //
         }
    }
}

type SixU512 = ((u512, u512), (u512, u512), (u512, u512),);
// type SixU512 = ();

fn u512_dud() -> u512 {
    u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0, }
}

impl Fq6MulShort of FieldMulShortcuts<Fq6, SixU512> {
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // Algorithm 3 Multiplication in Fp6 without reduction (cost of 6m~u +28a~)
    // uppercase vars are u512, lower case are u256
    #[inline(always)]
    fn u_mul(self: Fq6, rhs: Fq6) -> SixU512 {
        // Input:a = (a0 + a1v + a2v2) and b = (b0 + b1v + b2v2) ∈ Fp6
        // Output:c = a · b = (c0 + c1v + c2v2) ∈ Fp6
        let Fq6{c0: a0, c1: a1, c2: a2 } = self;
        let Fq6{c0: b0, c1: b1, c2: b2 } = rhs;
        // 1: T0 ←a0 ×2 b0,T1 ←a1 ×2 b1,T2 ←a2 ×2 b2 
        let (T0, T1, T2,) = (a0.u_mul(b0), a1.u_mul(b1), a2.u_mul(b2));
        // 2: t0 ← a1 +2 a2, t1 ← b1 +2 b2
        let (t0, t1,) = (a1.u_add(a2), b1.u_add(b2));
        // 3: T3 ← t0 ×2 t1
        let T3 = t0.u_mul(t1);
        // 4: T4 ← T1 +2 T2
        let T4 = T1 + T2;
        // 5: T3,0 ← T3,0 ⊖ T4,0
        // 6: T3,1 ← T3,1 − T4,1
        let (T30, T31): (u512, u512) = T3;
        let (T40, T41): (u512, u512) = T4;
        let T3 = (T30 - T40, T31 - T41);
        // 7: T4,0 ←T3,0 ⊖T3,1, T4,1 ←T3,0 ⊕T3,1 (≡T4 ←ξ·T3)
        let T4 = mul_by_xi(T3);
        //  8: T5 ← T4 ⊕2 T0
        let T5 = T4 + T0;
        // 9: t0 ← a0 +2 a1, t1 ← b0 +2 b1
        let t0 = a0.u_add(a1);
        let t1 = b0.u_add(b1);

        // 10: T3 ← t0 ×2 t1
        let T3 = t0.u_mul(t1);

        // 11: T4 ← T0 +2 T1
        let T4 = T0 + T1;
        // 12: T3,0 ← T3,0 ⊖ T4,0
        // 13: T3,1 ← T3,1 − T4,1
        let (T30, T31): (u512, u512) = T3;
        let (T40, T41): (u512, u512) = T4;
        let T3 = (T30 - T40, T31 - T41);
        // 14: T4,0 ← T2,0 ⊖ T2,1
        // 15: T4,1 ←T2,0 +T2,1 (steps14-15≡T4 ←ξ·T2)
        let T4 = mul_by_xi(T2);
        // 16: T6 ← T3 ⊕2 T4
        let T6 = T3 + T4;
        // 17: t0 ←a0 +2 a2,t1 ←b0 +2 b2
        let (t0, t1,) = (a0.u_add(a2), b0.u_add(b2));
        // 18: T3 ← t0 ×2 t1
        let T3 = t0.u_mul(t1);
        // 19: T4 ← T0 +2 T2
        let T4 = T0 + T2;

        // 20: T3,0 ← T3,0 ⊖ T4,0
        // 21: T3,1 ← T3,1 − T4,1
        let (T30, T31): (u512, u512) = T3;
        let (T40, T41): (u512, u512) = T4;
        let T3 = (T30 - T40, T31 - T41);

        // 22: T7,0 ← T3,0 ⊕ T1,0
        // 23: T7,1 ← T3,1 + T1,1
        let (T30, T31): (u512, u512) = T3;
        let (T10, T11): (u512, u512) = T1;
        let T7 = (T30 + T10, T31 + T11);

        // 24: return c = (T5 + T6v + T7v2)
        (T5, T6, T7)
    }

    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // Algorithm 7 Squaring in Fp2 without reduction (cost of s~u = 2mu + 3a)
    // uppercase vars are u512, lower case are u256
    #[inline(always)]
    fn u_sqr(self: Fq6) -> SixU512 {
        // Input:a = (a0 + a1v + a2v2) ∈ Fp6
        // Output:c = a · b = (c0 + c1v + c2v2) ∈ Fp6
        let Fq6{c0: a0, c1: a1, c2: a2 } = self;
        // 1: T0 ←a0 ×2 a0,T1 ←a1 ×2 b1,T2 ←a2 ×2 a2 
        let (T0, T1, T2,) = (a0.u_sqr(), a1.u_sqr(), a2.u_sqr());
        // 2: t0 ← a1 +2 a2, t1 ← a1 +2 a2
        // let (t0, t1,) = (a1.u_add(a2), a1.u_add(a2));
        // 3: T3 ← t0 ×2 t1
        // t0 = t1 = a1 +2 a2
        let T3 = a1.u_add(a2).u_sqr();
        // 4: T4 ← T1 +2 T2
        let T4 = T1 + T2;
        // 5: T3,0 ← T3,0 ⊖ T4,0
        // 6: T3,1 ← T3,1 − T4,1
        let T3 = (T3 - T4);
        // 7: T4,0 ←T3,0 ⊖T3,1, T4,1 ←T3,0 ⊕T3,1 (≡T4 ←ξ·T3)
        let T4 = mul_by_xi(T3);
        //  8: T5 ← T4 ⊕2 T0
        let T5 = T4 + T0;
        // 9: t0 ← a0 +2 a1, t1 ← a0 +2 a1
        // let (t0,t1) = (a0.u_add(a1), a0.u_add(a1));
        // 10: T3 ← t0 ×2 t1
        // t0 = t1 = a0.u_add(a1);
        let T3 = a0.u_add(a1).u_sqr();

        // 11: T4 ← T0 +2 T1
        let T4 = T0 + T1;
        // 12: T3,0 ← T3,0 ⊖ T4,0
        // 13: T3,1 ← T3,1 − T4,1
        let T3 = T3 - T4;
        // 14: T4,0 ← T2,0 ⊖ T2,1
        // 15: T4,1 ←T2,0 +T2,1 (steps14-15≡T4 ←ξ·T2)
        let T4 = mul_by_xi(T2);
        // 16: T6 ← T3 ⊕2 T4
        let T6 = T3 + T4;
        // 17: t0 ←a0 +2 a2,t1 ←a0 +2 a2
        // let (t0, t1,) = (a0.u_add(a2), a0.u_add(a2));
        // 18: T3 ← t0 ×2 t1
        let T3 = a0.u_add(a2).u_sqr();
        // 19: T4 ← T0 +2 T2
        let T4 = T0 + T2;

        // 20: T3,0 ← T3,0 ⊖ T4,0
        // 21: T3,1 ← T3,1 − T4,1
        let (T30, T31): (u512, u512) = T3;
        let (T40, T41): (u512, u512) = T4;
        let T3 = (T30 - T40, T31 - T41);

        // 22: T7,0 ← T3,0 ⊕ T1,0
        // 23: T7,1 ← T3,1 + T1,1
        let (T30, T31): (u512, u512) = T3;
        let (T10, T11): (u512, u512) = T1;
        let T7 = (T30 + T10, T31 + T11);

        // 24: return c = (T5 + T6v + T7v2)
        (T5, T6, T7)
    }

    #[inline(always)]
    fn to_fq(self: SixU512) -> Fq6 {
        let (C0, C1, C2) = self;
        // let field_nz = FIELD.try_into().unwrap();
        Fq6 { c0: C0.to_fq(), c1: C1.to_fq(), c2: C2.to_fq() }
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
        core::internal::revoke_ap_tracking();

        let Fq6{c0: a0, c1: a1, c2: a2 } = self;
        let Fq6{c0: b0, c1: b1, c2: b2 } = rhs;
        let (v0, v1, v2,) = (a0 * b0, a1 * b1, a2 * b2,);
        Fq6 {
            c0: {
                // ((a1 + a2) * (b1 + b2) - v1 - v2).mul_by_nonresidue() + v0
                ((a1.u_add(a2) * b1.u_add(b2)).u_add(-v1).u_add(-v2))
                    .fix_mod()
                    .mul_by_nonresidue()
                    .u_add(v0)
                    .fix_mod()
            },
            c1: {
                //(a0 + a1) * (b0 + b1) - v0 - v1 + v2.mul_by_nonresidue()
                (a0.u_add(a1) * b0.u_add(b1))
                    .u_add(-v0)
                    .u_add(-v1)
                    .u_add(v2.mul_by_nonresidue())
                    .fix_mod()
            },
            c2: {
                // (a0 + a2) * (b0 + b2) - v0 + v1 - v2
                (a0.u_add(a2) * b0.u_add(b2)).u_add(-v0).u_add(-v2).u_add(v1).fix_mod()
            },
        }
    }

    #[inline(always)]
    fn div(self: Fq6, rhs: Fq6) -> Fq6 {
        self.u_mul(rhs.inv()).to_fq()
    }

    #[inline(always)]
    fn neg(self: Fq6) -> Fq6 {
        Fq6 { c0: -self.c0, c1: -self.c1, c2: -self.c2, }
    }

    #[inline(always)]
    fn eq(lhs: @Fq6, rhs: @Fq6) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1 && lhs.c2 == rhs.c2
    }

    #[inline(always)]
    fn sqr(self: Fq6) -> Fq6 {
        core::internal::revoke_ap_tracking();
        self.u_sqr().to_fq()
    // Fq6Utils::one()
    }

    #[inline(always)]
    fn inv(self: Fq6) -> Fq6 {
        let c0 = self.c0.sqr() - self.c1 * self.c2.mul_by_nonresidue();
        let c1 = self.c2.sqr().mul_by_nonresidue() - self.c0 * self.c1;
        let c2 = self.c1.sqr() - self.c0 * self.c2;
        let t = ((self.c2 * c1 + self.c1 * c2).mul_by_nonresidue() + self.c0 * c0).inv();
        Fq6 { c0: t * c0, c1: t * c1, c2: t * c2, }
    }
}

