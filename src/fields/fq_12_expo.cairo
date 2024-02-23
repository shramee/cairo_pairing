use core::traits::TryInto;
use bn::traits::FieldShortcuts;
use bn::traits::FieldMulShortcuts;
use core::array::ArrayTrait;
use bn::curve::{u512, mul_by_xi, mul_by_v, U512BnAdd, U512BnSub, Tuple2Add, Tuple2Sub, FIELD};
use bn::fields::{FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12, fq12, Fq12Frobenius};
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

#[generate_trait]
impl Fq12FinalExpo of FinalExponentiationTrait {
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // Algorithm 8 Compressed squaring in Gφ6 (Fp2 ) (cost of 6s ̃u + 4r ̃ + 31a ̃)
    #[inline(always)]
    fn compressed_sqr(self: Fq12) -> Fq12 {
        // Input: self = (a2 +a3s)t+(a4 +a5s)t2 ∈ Gφ6(Fp2)
        // Output: a^2 = (c2 +c3s)t+(c4 +c5s)t2 ∈ Gφ6 (Fp2 ).
        // let a0 = self.c0.c0;
        // let a1 = self.c0.c1;
        // let a2 = self.c0.c2;
        // let a3 = self.c1.c0;
        // let a4 = self.c1.c1;
        // let a5 = self.c1.c2;

        // 1: T0 ← a4 ×2 a4 , T1 ← a5 ×2 a5 , t0 ← a4 ⊕2 a5
        // let T0 = a4.mul(a4);
        // let T1 = a5 * a5;
        // let t0 = a4 + a5;
        // 2: T2 ← t0 ×2 t0 , T3 ← T0 +2 T1 , T3 ← T0 ⊖2 T3
        // 3: t0 ← T3 mod2 p , t1 ← a2 ⊕2 a3 , T3 ← t1 ×2 t1 , T2 ← a2 ×2 a2 4: t1,0 ← t0,0 ⊖t0,1 , t1,1 ← t0,0 ⊕t0,1 (≡t1←ξ·t0)
        // 5: t0 ← t1 ⊕2 a2 , t0 ← t0 ⊕2 t0
        // 6: c2 ←  t0 ⊕2 t1
        // 7: T4,0 ← T1,0 ⊖T1,1 , T4,1 ← T1,0 ⊕T1,1 (≡T4 ← ξ·T1)
        // 8: T4 ←  T0 ⊕2 T4
        // 9: t0 ← T4 mod2 p , t1 ← t0 ⊖2 a3 , t1 ← t1 ⊕2 t1
        // 10: c3 ←  t1 ⊕2 t0
        // 11: T1 ←  a3 ×2 a3
        // 12: T4,0 ← T1,0 ⊖T1,1 , T4,1 ← T1,0 ⊕T1,1 (≡T4 ← ξ·T1) 13: T4 ←  T2 ⊕2 T4
        // 14: t0 ← T4 mod2 p , t1 ← t0 ⊖2 a4 , t1 ← t1 ⊕2 t1
        // 15: c4 ←  t1 ⊕2 t0
        // 16: T0 ← T2 +2 T1 , T3 ← T3 ⊖2 T0
        // 17: t0 ← T3 mod2 p , t1 ← t0 ⊖2 a5 , t1 ← t1 ⊕2 t1
        // 18: c5 ← t1 ⊕2 t0
        // 19: return C = (c2 + c3s)t + (c4 + c5s)t2
        panic!("Unimplemented: Fq12 compressed sq");
        FieldUtils::one()
    }

    // Cyclotomic squaring 
    // #[inline(always)]
    fn cyclotomic_sqr(self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        core::internal::revoke_ap_tracking();

        let z0 = self.c0.c0;
        let z4 = self.c0.c1;
        let z3 = self.c0.c2;
        let z2 = self.c1.c0;
        let z1 = self.c1.c1;
        let z5 = self.c1.c2;
        // let tmp = z0 * z1;
        let Tmp = z0.u_mul(z1);
        // let t0 = (z0 + z1) * (z1.mul_by_nonresidue() + z0) - tmp - tmp.mul_by_nonresidue();
        let T0 = z0.u_add(z1).u_mul(z1.mul_by_nonresidue().u_add(z0)) - Tmp - mul_by_xi(Tmp);
        // let t1 = tmp + tmp;
        let T1 = Tmp + Tmp;

        // let tmp = z2 * z3;
        let Tmp = z2.u_mul(z3);
        // let t2 = (z2 + z3) * (z3.mul_by_nonresidue() + z2) - tmp - tmp.mul_by_nonresidue();
        let T2 = z2.u_add(z3).u_mul(z3.mul_by_nonresidue().u_add(z2)) - Tmp - mul_by_xi(Tmp);
        // let t3 = tmp + tmp;
        let T3 = Tmp + Tmp;

        // let tmp = z4 * z5;
        let Tmp = z4.u_mul(z5);
        // let t4 = (z4 + z5) * (z5.mul_by_nonresidue() + z4) - tmp - tmp.mul_by_nonresidue();
        let T4 = z4.u_add(z5).u_mul(z5.mul_by_nonresidue().u_add(z4)) - Tmp - mul_by_xi(Tmp);
        // let t5 = tmp + tmp;
        let T5 = Tmp + Tmp;

        let Z0 = T0 - z0.into();
        let Z0 = Z0 + Z0;
        let Z0 = Z0 + T0;

        let Z1 = T1 + z1.into();
        let Z1 = Z1 + Z1;
        let Z1 = Z1 + T1;

        let Tmp = mul_by_xi(T5);
        let Z2 = Tmp + z2.into();
        let Z2 = Z2 + Z2;
        let Z2 = Z2 + Tmp;

        let Z3 = T4 - z3.into();
        let Z3 = Z3 + Z3;
        let Z3 = Z3 + T4;

        let Z4 = T2 - z4.into();
        let Z4 = Z4 + Z4;
        let Z4 = Z4 + T2;

        let Z5 = T3 + z5.into();
        let Z5 = Z5 + Z5;
        let Z5 = Z5 + T3;

        Fq12 {
            c0: Fq6 { c0: Z0.to_fq(field_nz), c1: Z4.to_fq(field_nz), c2: Z3.to_fq(field_nz) },
            c1: Fq6 { c0: Z2.to_fq(field_nz), c1: Z1.to_fq(field_nz), c2: Z5.to_fq(field_nz) },
        }
    }

    fn exp_naf(mut self: Fq12, mut naf: Array<(bool, bool)>, field_nz: NonZero<u256>) -> Fq12 {
        let mut temp_sq = self;
        let mut result = FieldUtils::one();

        loop {
            match naf.pop_front() {
                Option::Some(naf) => {
                    let (naf0, naf1) = naf;

                    if naf0 {
                        if naf1 {
                            result = result * temp_sq;
                        } else {
                            result = result * temp_sq.conjugate();
                        }
                    }

                    temp_sq = temp_sq.cyclotomic_sqr(field_nz);
                },
                Option::None => { break; },
            }
        };
        result
    }

    #[inline(always)]
    fn exp_by_neg_x(mut self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        // let result = FieldUtils::one(); // Results init as self
        // P
        let result = self;
        let temp_sq = self.cyclotomic_sqr(field_nz);
        // OOO
        let temp_sq = temp_sq
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz);
        // N
        let result = result * temp_sq.conjugate();
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OOOO
        let temp_sq = temp_sq
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OOOO
        let temp_sq = temp_sq
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OO
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // N
        let result = result * temp_sq.conjugate();
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OO
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OOO
        let temp_sq = temp_sq
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // N
        let result = result * temp_sq.conjugate();
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // N
        let result = result * temp_sq.conjugate();
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // N
        let result = result * temp_sq.conjugate();
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OO
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz);
        // N
        let result = result * temp_sq.conjugate();
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // N
        let result = result * temp_sq.conjugate();
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OO
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // O
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        let temp_sq = temp_sq.cyclotomic_sqr(field_nz);
        // OOO
        let temp_sq = temp_sq
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz)
            .cyclotomic_sqr(field_nz);
        // P
        let result = result * temp_sq;
        result.conjugate()
    }

    // Software Implementation of the Optimal Ate Pairing
    // Page 9, 4.2 Final exponentiation

    // f^(p^6-1) = conjugate(f) · f^(-1)
    // returns cyclotomic Fp12
    #[inline(always)]
    fn pow_p6_minus_1(self: Fq12) -> Fq12 {
        self.conjugate() / self
    }

    // Software Implementation of the Optimal Ate Pairing
    // Page 9, 4.2 Final exponentiation
    // Page 5 - 6, 3.2 Frobenius Operator
    // f^(p^2+1) = f^(p^2) * f = f.frob2() * f
    #[inline(always)]
    fn pow_p2_plus_1(self: Fq12) -> Fq12 {
        self.frob2() * self
    }

    // p^4 - p^2 + 1
    // This seems to be the most efficient counting operations performed
    // https://github.com/paritytech/bn/blob/master/src/fields/fq12.rs#L75
    #[inline(always)]
    fn pow_p4_minus_p2_plus_1(self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        internal::revoke_ap_tracking();
        let field_nz = FIELD.try_into().unwrap();

        let a = self.exp_by_neg_x(field_nz);
        let b = a.cyclotomic_sqr(field_nz);
        let c = b.cyclotomic_sqr(field_nz);
        let d = c * b;

        let e = d.exp_by_neg_x(field_nz);
        let f = e.cyclotomic_sqr(field_nz);
        let g = f.exp_by_neg_x(field_nz);
        let h = d.conjugate();
        let i = g.conjugate();

        let j = i * e;
        let k = j * h;
        let l = k * b;
        let m = k * e;
        let n = self * m;

        let o = l.frob1();
        let p = o * n;

        let q = k.frob2();
        let r = q * p;

        let s = self.conjugate();
        let t = s * l;
        let u = t.frob3();
        let v = u * r;

        v
    }
}
