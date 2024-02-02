use core::array::ArrayTrait;
use bn::traits::ECOperations;
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12, fq12};
use bn::fields::fq12_::Fq12Frobenius;
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

// raising f ∈ Fp12 to the power e = (p^12 - 1)/r can be done in three parts,
// e = (p^6 - 1) * (p^2 + 1) * (p4 − p2 + 1) / r
// 
// 

fn fq2_frobenius(power: felt252) -> Fq2 {
    // TODO
    FieldUtils::one()
}

#[generate_trait]
impl FinalExponentiationFq6 of FinalExponentiationTraitFq6 { //
// #[inline(always)]
// fn frobenius_2(self: Fq6) -> Fq6 {
//     Fq6 { c0: self.c0.frobenius_map(2), c1: self.c1.frobenius_map(2) * fq2_frobenius(2), }
// }
}

#[generate_trait]
impl FinalExponentiation of FinalExponentiationTrait {
    #[inline(always)]
    fn frobenius_2(self: Fq12) -> Fq12 {
        // TODO
        Fq12 { c0: self.c0.frobenius_map(2), c1: self.c1.frobenius_map(2).scale(fq2_frobenius(2)), }
    }


    fn cyclotomic_sqr(self: Fq12) -> Fq12 {
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

        fq12(Fq6 { c0: z0, c1: z4, c2: z3 }, Fq6 { c0: z2, c1: z1, c2: z5 },)
    }

    fn exp_by_neg_x(mut self: Fq12) -> Fq12 {
        // Binary bools array of bn::curve::X
        let mut naf = bn::curve::x_naf();

        let mut temp_sq = self;

        loop {
            match naf.pop_front() {
                Option::Some(naf) => {
                    let (naf0, naf1) = naf;

                    if naf0 {
                        if naf1 {
                            self = self * temp_sq;
                        } else {
                            self = self * temp_sq.conjugate();
                        }
                    }

                    temp_sq = temp_sq.cyclotomic_sqr();
                },
                Option::None => { break; },
            }
        };

        FieldUtils::one()
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
    // For f ∈ Fp12, f = g + hw with g, h ∈ Fp6
    // g = g0 + g1v + g2v^2, h = h0 + h1v + h2v^2 for gi, hi ∈ Fp2
    // p-power of an arbitrary element in the quadratic extension field Fp2 can be computed
    // essentially free of cost as follows.For b = b0 + b1u, b^(p^2i) = b
    //
    // f^(p^2+1) = 
    #[inline(always)]
    fn pow_p2_plus_1(self: Fq12) -> Fq12 {
        self.frobenius_map(2) * self
    }

    #[inline(always)]
    fn final_exponentiation_last_chunk(self: Fq12) -> Fq12 {
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
// Software Implementation of the Optimal Ate Pairing
// Page 9, 4.2 Final exponentiation
// 
}

fn final_exponentiation(f: Fq12) -> Fq12 {
    let f = f.pow_p6_minus_1().pow_p2_plus_1();
    f
}
