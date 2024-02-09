use bn::traits::{FieldUtils, FieldOps, FieldShortcuts, FieldMulShortcuts};
use bn::fast_mod::{u512, u512Add, u512Sub, u512_pad, u512_reduce};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::curve::FIELD;
use bn::fields::{Fq, fq,};
use debug::PrintTrait;

#[derive(Copy, Drop, Serde, Debug)]
struct Fq2 {
    c0: Fq,
    c1: Fq,
}

impl TupleU512IntoFq2 of Into<(u512, u512), Fq2> {
    #[inline(always)]
    fn into(self: (u512, u512)) -> Fq2 {
        let (C0, C1) = self;
        let field_nz = FIELD.try_into().unwrap();
        fq2(u512_reduce(C0, field_nz), u512_reduce(C1, field_nz))
    }
}

// Extension field is represented as two number with X (a root of an polynomial in Fq which doesn't exist in Fq).
// X for field extension is equivalent to imaginary i for real numbers.
// number a: Fq2 = (a0, a1), mathematically, a = a0 + a1 * X

#[inline(always)]
fn fq2(c0: u256, c1: u256) -> Fq2 {
    Fq2 { c0: fq(c0), c1: fq(c1), }
}

#[generate_trait]
impl Fq2Frobenius of Fq2FrobeniusTrait {
    #[inline(always)]
    fn frob0(self: Fq2) -> Fq2 {
        self
    }

    #[inline(always)]
    fn frob1(self: Fq2) -> Fq2 {
        self.conjugate()
    }
}

impl Fq2Utils of FieldUtils<Fq2, Fq> {
    #[inline(always)]
    fn one() -> Fq2 {
        fq2(1, 0)
    }

    #[inline(always)]
    fn zero() -> Fq2 {
        fq2(0, 0)
    }

    #[inline(always)]
    fn scale(self: Fq2, by: Fq) -> Fq2 {
        Fq2 { c0: self.c0 * by, c1: self.c1 * by, }
    }

    #[inline(always)]
    fn conjugate(self: Fq2) -> Fq2 {
        Fq2 { c0: self.c0, c1: -self.c1, }
    }

    #[inline(always)]
    fn mul_by_nonresidue(self: Fq2,) -> Fq2 {
        // fq2(9, 1)
        let Fq2{c0: a0, c1: a1 } = self;
        Fq2 { //
         //  a0 * b0 + a1 * βb1,
        c0: a0.scale(9) - a1, //
         //  c1: a0 * b1 + a1 * b0,
        c1: a0 + a1.scale(9), //
         }
    }

    #[inline(always)]
    fn frobenius_map(self: Fq2, power: usize) -> Fq2 {
        if power % 2 == 0 {
            self
        } else {
            // Fq2 { c0: self.c0, c1: self.c1.mul_by_nonresidue(), }
            self.conjugate()
        }
    }
}

fn u512_dummy() -> u512 {
    u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0, }
}

impl Fq2Short of FieldShortcuts<Fq2> {
    #[inline(always)]
    fn u_add(self: Fq2, rhs: Fq2) -> Fq2 {
        // Operation without modding can only be done like 4 times
        Fq2 { //
         c0: self.c0.u_add(rhs.c0), //
         c1: self.c1.u_add(rhs.c1), //
         }
    }
    #[inline(always)]
    fn fix_mod(self: Fq2) -> Fq2 {
        // Operation without modding can only be done like 4 times
        Fq2 { //
         c0: self.c0.fix_mod(), //
         c1: self.c1.fix_mod(), //
         }
    }
}

impl Fq2MulShort of FieldMulShortcuts<Fq2, (u512, u512)> {
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // Algorithm 2 Multiplication in Fp2 without reduction (cost m~u = 3mu +8a)
    // uppercase vars are u512, lower case are u256
    #[inline(always)]
    fn u_mul(self: Fq2, rhs: Fq2) -> (u512, u512) {
        // Input: a = (a0 + a1i) and b = (b0 + b1i) ∈ Fp2 Output: c = a·b = (c0 +c1i) ∈ Fp2
        let Fq2{c0: a0, c1: a1 } = self;
        let Fq2{c0: b0, c1: b1 } = rhs;

        // 1: T0 ←a0 × b0, T1 ←a1 × b1,
        let T0 = a0.u_mul(b0); // Karatsuba V0
        let T1 = a1.u_mul(b1); // Karatsuba V1
        // t0 ←a0 +a1, t1 ←b0 +b1 2: T2 ←t0 × t1
        let T2 = a0.u_add(a1).u_mul(b0.u_add(b1));
        // T3 ←T0 +T1
        let T3 = T0 + T1;

        // 3: T3 ←T2 − T3
        let T3 = T2 - T3;
        // 4: T4 ← T0 ⊖ T1
        let T4 = u512_pad(T0, FIELD) - T1;
        // 5: return c = (T4 + T3i)
        (T4, T3)
    }

    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // Algorithm 7 Squaring in Fp2 without reduction (cost of s~u = 2mu + 3a)
    // uppercase vars are u512, lower case are u256
    #[inline(always)]
    fn u_sqr(self: Fq2) -> (u512, u512) {
        (u512_dummy(), u512_dummy())
    }

    #[inline(always)]
    fn u_scl(self: Fq2, rhs: u128) -> (u512, u512) {
        (u512_dummy(), u512_dummy())
    }
}

impl Fq2Ops of FieldOps<Fq2> {
    #[inline(always)]
    fn add(self: Fq2, rhs: Fq2) -> Fq2 {
        Fq2 { c0: self.c0 + rhs.c0, c1: self.c1 + rhs.c1, }
    }

    #[inline(always)]
    fn sub(self: Fq2, rhs: Fq2) -> Fq2 {
        Fq2 { c0: self.c0 - rhs.c0, c1: self.c1 - rhs.c1, }
    }

    #[inline(always)]
    fn mul(self: Fq2, rhs: Fq2) -> Fq2 {
        // Aranha mul_u + 2r
        self.u_mul(rhs).into()
    // Karatsuba
    // let Fq2{c0: a0, c1: a1 } = self;
    // let Fq2{c0: b0, c1: b1 } = rhs;
    // let v0 = a0 * b0;
    // let v1 = a1 * b1;
    // // v0 + βv1, β = -1
    // let c0 = v0 - v1;
    // // (a0 + a1) * (b0 + b1) - v0 - v1
    // let c1 = a0.u_add(a1) * b0.u_add(b1) - v0 - v1;
    // Fq2 { c0, c1 }
    // Derived (schoolbook)
    // let Fq2{c0: a0, c1: a1 } = self;
    // let Fq2{c0: b0, c1: b1 } = rhs;
    // // Multiplying ab in Fq2 mod X^2 + BETA
    // // c = ab = a0*b0 + a0*b1*X + a1*b0*X + a0*b0*BETA
    // // c = a0*b0 + a0*b0*BETA + (a0*b1 + a1*b0)*X
    // // or c = (a0*b0 + a0*b0*BETA, a0*b1 + a1*b0)
    // Fq2 { //
    //  c0: a0 * b0 + a1 * b1.mul_by_nonresidue(), //
    //  c1: a0 * b1 + a1 * b0, //
    //  }
    }

    #[inline(always)]
    fn div(self: Fq2, rhs: Fq2) -> Fq2 {
        self.mul(rhs.inv())
    }

    #[inline(always)]
    fn neg(self: Fq2) -> Fq2 {
        Fq2 { c0: -self.c0, c1: -self.c1, }
    }

    #[inline(always)]
    fn eq(lhs: @Fq2, rhs: @Fq2) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1
    }

    #[inline(always)]
    fn sqr(self: Fq2) -> Fq2 {
        // Aranha sqr_u + 2r
        self.u_sqr().into()
    // // Complex squaring
    // let Fq2{c0: a0, c1: a1 } = self;
    // let v = a0 * a1;
    // // (a0 + a1) * (a0 + βa1) - v - βv, β = -1
    // let c0 = a0.u_add(a1) * a0.u_add(-a1);
    // // 2v
    // let c1 = v + v;
    // Fq2 { c0, c1 }
    }

    #[inline(always)]
    fn inv(self: Fq2) -> Fq2 {
        // "High-Speed Software Implementation of the Optimal Ate Pairing
        // over Barreto–Naehrig Curves"; Algorithm 8
        if self.c0.c0 + self.c1.c0 == 0 {
            return Fq2 { c0: fq(0), c1: fq(0), };
        }
        // let t = (self.c0.sqr() - (self.c1.sqr().mul_by_nonresidue())).inv();
        // Mul by non residue -1 makes negative
        let t = (self.c0.sqr() + self.c1.sqr()).inv();

        Fq2 { c0: self.c0 * t, c1: self.c1 * -t, }
    }
}
