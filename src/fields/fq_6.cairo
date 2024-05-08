use core::traits::TryInto;
use bn::curve::{FIELD, get_field_nz};
use bn::curve::{
    U512Fq2Ops, u512, U512BnAdd, Tuple2Add, U512BnSub, Tuple2Sub, mul_by_xi, mul_by_xi_nz,
    u512_reduce, u512_add, u512_sub
};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl, Fq6PrintImpl, Fq12PrintImpl};
use bn::fields::{Fq2, Fq2Ops, fq2, Fq2Frobenius};
use bn::traits::{FieldUtils, FieldOps, FieldShortcuts, FieldMulShortcuts};
use bn::fields::frobenius::fp6 as frob;
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{u512Display, Fq2Display, Fq6Display};

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
        let Fq6 { c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob0(),
            c1: c1.frob0() * fq2(frob::Q_0_C0, frob::Q_0_C1),
            c2: c2.frob0() * fq2(frob::Q2_0_C0, frob::Q2_0_C1),
        }
    }

    #[inline(always)]
    fn frob1(self: Fq6) -> Fq6 {
        let Fq6 { c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob1(),
            c1: c1.frob1() * fq2(frob::Q_1_C0, frob::Q_1_C1),
            c2: c2.frob1() * fq2(frob::Q2_1_C0, frob::Q2_1_C1),
        }
    }

    #[inline(always)]
    fn frob2(self: Fq6) -> Fq6 {
        let Fq6 { c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob0(),
            c1: c1.frob0() * fq2(frob::Q_2_C0, frob::Q_2_C1),
            c2: c2.frob0() * fq2(frob::Q2_2_C0, frob::Q2_2_C1),
        }
    }

    #[inline(always)]
    fn frob3(self: Fq6) -> Fq6 {
        let Fq6 { c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob1(),
            c1: c1.frob1() * fq2(frob::Q_3_C0, frob::Q_3_C1),
            c2: c2.frob1() * fq2(frob::Q2_3_C0, frob::Q2_3_C1),
        }
    }

    #[inline(always)]
    fn frob4(self: Fq6) -> Fq6 {
        let Fq6 { c0, c1, c2 } = self;
        Fq6 {
            c0: c0.frob0(),
            c1: c1.frob0() * fq2(frob::Q_4_C0, frob::Q_4_C1),
            c2: c2.frob0() * fq2(frob::Q2_4_C0, frob::Q2_4_C1),
        }
    }

    #[inline(always)]
    fn frob5(self: Fq6) -> Fq6 {
        let Fq6 { c0, c1, c2 } = self;
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
    fn u_sub(self: Fq6, rhs: Fq6) -> Fq6 {
        // Operation without modding can only be done like 4 times
        Fq6 { //
            c0: self.c0.u_sub(rhs.c0), //
            c1: self.c1.u_sub(rhs.c1), //
            c2: self.c2.u_sub(rhs.c2), //
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
    #[inline(always)]
    fn u512_add_fq(self: SixU512, rhs: Fq6) -> SixU512 {
        let (C0, C1, C2) = self;
        (C0.u512_add_fq(rhs.c0), C1.u512_add_fq(rhs.c1), C2.u512_add_fq(rhs.c2))
    }

    #[inline(always)]
    fn u512_sub_fq(self: SixU512, rhs: Fq6) -> SixU512 {
        let (C0, C1, C2) = self;
        (C0.u512_sub_fq(rhs.c0), C1.u512_sub_fq(rhs.c1), C2.u512_sub_fq(rhs.c2))
    }

    // A reimplementation in Karatsuba multiplication with lazy reduction
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // uppercase vars are u512, lower case are u256
    // #[inline(always)]
    fn u_mul(self: Fq6, rhs: Fq6) -> SixU512 {
        core::internal::revoke_ap_tracking();
        // Input:a = (a0 + a1v + a2v2) and b = (b0 + b1v + b2v2) ∈ Fp6
        // Output:c = a · b = (c0 + c1v + c2v2) ∈ Fp6
        let Fq6 { c0: a0, c1: a1, c2: a2 } = self;
        let Fq6 { c0: b0, c1: b1, c2: b2 } = rhs;
        let field_nz = get_field_nz();

        // v0 = a0b0, v1 = a1b1, v2 = a2b2
        let (V0, V1, V2,) = (a0.u_mul(b0), a1.u_mul(b1), a2.u_mul(b2),);

        // c0 = v0 + ξ((a1 + a2)(b1 + b2) - v1 - v2)
        let C0 = V0 + mul_by_xi_nz(a1.u_add(a2).u_mul(b1.u_add(b2)) - V1 - V2, field_nz);
        // c1 =(a0 + a1)(b0 + b1) - v0 - v1 + ξv2
        let C1 = a0.u_add(a1).u_mul(b0.u_add(b1)) - V0 - V1 + mul_by_xi_nz(V2, field_nz);
        // c2 = (a0 + a2)(b0 + b2) - v0 + v1 - v2,
        let C2 = a0.u_add(a2).u_mul(b0.u_add(b2)) - V0 + V1 - V2;

        (C0, C1, C2)
    }

    // CH-SQR2 squaring adapted to lazy reduction as described in
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // uppercase vars are u512, lower case are u256
    // #[inline(always)]
    fn u_sqr(self: Fq6) -> SixU512 {
        core::internal::revoke_ap_tracking();
        let Fq6 { c0, c1, c2 } = self;
        let field_nz = get_field_nz();

        // let s0 = c0.sqr();
        let S0 = c0.u_sqr();
        // let ab = c0 * c1;
        let AB = c0.u_mul(c1);
        // let s1 = ab + ab;
        let S1 = AB + AB;
        // let s2 = (c0 + c2 - c1).sqr();
        let S2 = (c0 + c2 - c1).u_sqr();
        // let bc = c1 * c2;
        let BC = c1.u_mul(c2);
        // let s3 = bc + bc;
        let S3 = BC + BC;
        // let s4 = self.c2.sqr();
        let S4 = c2.u_sqr();

        // let c0 = s0 + s3.mul_by_nonresidue();
        let C0 = S0 + mul_by_xi_nz(S3, field_nz);
        // let c1 = s1 + s4.mul_by_nonresidue();
        let C1 = S1 + mul_by_xi_nz(S4, field_nz);
        // let c2 = s1 + s2 + s3 - s0 - s4;
        let C2 = S1 + S2 + S3 - S0 - S4;

        (C0, C1, C2)
    }

    #[inline(always)]
    fn to_fq(self: SixU512, field_nz: NonZero<u256>) -> Fq6 {
        let (C0, C1, C2) = self;
        Fq6 { c0: C0.to_fq(field_nz), c1: C1.to_fq(field_nz), c2: C2.to_fq(field_nz) }
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
        let field_nz = FIELD.try_into().unwrap();
        self.u_mul(rhs).to_fq(field_nz)
    }

    #[inline(always)]
    fn div(self: Fq6, rhs: Fq6) -> Fq6 {
        let field_nz = get_field_nz();
        self.u_mul(rhs.inv(field_nz)).to_fq(field_nz)
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
        let field_nz = FIELD.try_into().unwrap();
        self.u_sqr().to_fq(field_nz)
    }

    #[inline(always)]
    fn inv(self: Fq6, field_nz: NonZero<u256>) -> Fq6 {
        core::internal::revoke_ap_tracking();
        let field_nz = FIELD.try_into().unwrap();
        let Fq6 { c0, c1, c2 } = self;
        // let c0 = self.c0.sqr() - self.c1 * self.c2.mul_by_nonresidue();
        let v0 = c0.u_sqr() - mul_by_xi_nz(c1.u_mul(c2), field_nz);
        let v0 = v0.to_fq(field_nz);
        // let c1 = self.c2.sqr().mul_by_nonresidue() - self.c0 * self.c1;
        let V1 = mul_by_xi_nz(c2.u_sqr(), field_nz) - c0.u_mul(c1);
        let v1 = V1.to_fq(field_nz);
        // let c2 = self.c1.sqr() - self.c0 * self.c2;
        let V2 = c1.u_sqr() - c0.u_mul(c2);
        let v2 = V2.to_fq(field_nz);
        // let t = ((self.c2 * c1 + self.c1 * c2).mul_by_nonresidue() + self.c0 * c0).inv();
        let t = (mul_by_xi_nz(c2.u_mul(v1) + c1.u_mul(v2), field_nz) + c0.u_mul(v0))
            .to_fq(field_nz)
            .inv(field_nz);
        Fq6 { c0: t * v0, c1: t * v1, c2: t * v2, }
    }
}

fn fq6_karatsuba_sqr(a: Fq6, rhs: Fq6) -> SixU512 {
    core::internal::revoke_ap_tracking();
    let Fq6 { c0: a0, c1: a1, c2: a2 } = a;
    let field_nz = get_field_nz();

    // Karatsuba squaring
    // v0 = a0a0, v1 = a1a1, v2 = a2a2
    let (V0, V1, V2,) = (a0.u_sqr(), a1.u_sqr(), a2.u_sqr(),);

    // c0 = v0 + ξ((a1 + a2)(a1 + a2) - v1 - v2)
    let C0 = V0 + mul_by_xi_nz((a1 + a2).u_sqr() - V1 - V2, field_nz);
    // c1 =(a0 + a1)(a0 + a1) - v0 - v1 + ξv2
    let C1 = (a0 + a1).u_sqr() - V0 - V1 + mul_by_xi_nz(V2, field_nz);
    // c2 = (a0 + a2)(a0 + a2) - v0 + v1 - v2,
    let C2 = (a0 + a2).u_sqr() - V0 + V1 - V2;
    (C0, C1, C2)
}
