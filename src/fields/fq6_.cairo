use bn::fields::{Fq2, Fq2Ops, fq2};
use bn::traits::{FieldUtils, FieldOps};
use bn::curve::fq2_non_residue;
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
    fn zero() -> Fq6 {
        fq6(0, 0, 0, 0, 0, 0)
    }

    #[inline(always)]
    fn scale(self: Fq6, by: Fq2) -> Fq6 {
        Fq6 { c0: self.c0 * by, c1: self.c1 * by, c2: self.c2 * by, }
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq6,) -> Fq6 {
        Fq6 { c0: self.c2.mul_by_nonresidue(), c1: self.c0, c2: self.c1, }
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
        core::internal::revoke_ap_tracking();

        let Fq6{c0: a0, c1: a1, c2: a2 } = self;
        let Fq6{c0: b0, c1: b1, c2: b2 } = rhs;
        let (a_a, b_b, c_c,) = (a0 * b0, a1 * b1, a2 * b2,);
        Fq6 {
            c0: {
                ((a1 + a2) * (b1 + b2) - b_b - c_c).mul_by_nonresidue() + a_a
            },
            c1: {
                (a0 + a1) * (b0 + b1) - a_a - b_b + c_c.mul_by_nonresidue()
            },
            c2: {
                (a0 + a2) * (b0 + b2) - a_a + b_b - c_c
            },
        }
    }

    #[inline(always)]
    fn div(self: Fq6, rhs: Fq6) -> Fq6 {
        self.mul(rhs.inv())
    }

    #[inline(always)]
    fn neg(self: Fq6) -> Fq6 {
        assert(false, 'no_impl: fq6 mul non_res');
        // TODO
        Fq6Utils::one()
    }

    #[inline(always)]
    fn eq(lhs: @Fq6, rhs: @Fq6) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1 && lhs.c2 == rhs.c2
    }

    #[inline(always)]
    fn sqr(self: Fq6) -> Fq6 {
        let s0 = self.c0.sqr();
        let ab = self.c0 * self.c1;
        let s1 = ab + ab;
        let s2 = (self.c0 - self.c1 + self.c2).sqr();
        let bc = self.c1 * self.c2;
        let s3 = bc + bc;
        let s4 = self.c2.sqr();

        Fq6 {
            c0: s0 + s3.mul_by_nonresidue(),
            c1: s1 + s4.mul_by_nonresidue(),
            c2: s1 + s2 + s3 - s0 - s4,
        }
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

