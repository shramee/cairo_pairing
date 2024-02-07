use core::array::ArrayTrait;
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12, fq12};
use bn::fields::fq6_::Fq6Frobenius;
use bn::fields::fq12_::Fq12Frobenius;
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

// raising f ∈ Fp12 to the power e = (p^12 - 1)/r can be done in three parts,
// e = (p^6 - 1) * (p^2 + 1) * (p4 − p2 + 1) / r

#[generate_trait]
impl FinalExponentiation of FinalExponentiationTrait {
    #[inline(always)]
    fn cyclotomic_sqr(self: Fq12) -> Fq12 {
        core::internal::revoke_ap_tracking();

        let z0 = self.c0.c0;
        let z4 = self.c0.c1;
        let z3 = self.c0.c2;
        let z2 = self.c1.c0;
        let z1 = self.c1.c1;
        let z5 = self.c1.c2;
        let tmp = z0 * z1;
        let t0 = (z0 + z1) * (z1.mul_by_nonresidue() + z0) - tmp - tmp.mul_by_nonresidue();
        let t1 = tmp + tmp;

        let tmp = z2 * z3;
        let t2 = (z2 + z3) * (z3.mul_by_nonresidue() + z2) - tmp - tmp.mul_by_nonresidue();
        let t3 = tmp + tmp;

        let tmp = z4 * z5;
        let t4 = (z4 + z5) * (z5.mul_by_nonresidue() + z4) - tmp - tmp.mul_by_nonresidue();
        let t5 = tmp + tmp;

        let z0 = t0 - z0;
        let z0 = z0 + z0;
        let z0 = z0 + t0;

        let z1 = t1 + z1;
        let z1 = z1 + z1;
        let z1 = z1 + t1;

        let tmp = t5.mul_by_nonresidue();
        let z2 = tmp + z2;
        let z2 = z2 + z2;
        let z2 = z2 + tmp;

        let z3 = t4 - z3;
        let z3 = z3 + z3;
        let z3 = z3 + t4;

        let z4 = t2 - z4;
        let z4 = z4 + z4;
        let z4 = z4 + t2;

        let z5 = t3 + z5;
        let z5 = z5 + z5;
        let z5 = z5 + t3;

        Fq12 { c0: Fq6 { c0: z0, c1: z4, c2: z3 }, c1: Fq6 { c0: z2, c1: z1, c2: z5 }, }
    }

    fn exp_naf(mut self: Fq12, mut naf: Array<(bool, bool)>) -> Fq12 {
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

                    temp_sq = temp_sq.cyclotomic_sqr();
                },
                Option::None => { break; },
            }
        };
        result
    }

    #[inline(always)]
    fn exp_by_neg_x(mut self: Fq12) -> Fq12 {
        // Binary bools array of bn::curve::X
        self.exp_naf(bn::curve::x_naf()).conjugate()
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
    #[inline(always)]
    fn pow_p4_minus_p2_plus_1(self: Fq12) -> Fq12 {
        let a = self.exp_by_neg_x();
        let b = a.cyclotomic_sqr();
        let c = b.cyclotomic_sqr();
        let d = c * b;

        let e = d.exp_by_neg_x();
        let f = e.cyclotomic_sqr();
        let g = f.exp_by_neg_x();
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

// #[inline(always)]
fn final_exponentiation(f: Fq12) -> Fq12 {
    internal::revoke_ap_tracking();
    f.pow_p6_minus_1().pow_p2_plus_1().pow_p4_minus_p2_plus_1()
}
