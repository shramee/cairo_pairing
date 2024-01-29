use bn::traits::ECOperations;
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12, fq12};
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

// raising f ∈ Fp12 to the power e = (p^12 - 1)/r can be done in three parts,
// e = (p^6 - 1) * (p^2 + 1) * (p4 − p2 + 1) / r
// 
// 

#[generate_trait]
impl FinalExponentiation of FinalExponentiationTrait {
    fn conjugate(self: Fq12) -> Fq12 {
        Fq12 { c0: self.c0, c1: -self.c1, }
    }

    fn sqr_cyclotomic(self: Fq12) -> Fq12 {
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

    // Software Implementation of the Optimal Ate Pairing
    // Page 9, 4.2 Final exponentiation
    // f^(p^6-1) = conjugate(f) · f^(-1)
    // returns cyclotomic Fp12
    #[inline(always)]
    fn pow_p6_minus_1(b: Fq12) -> Fq12 {
        b.conjugate() / b
    }

    // Software Implementation of the Optimal Ate Pairing
    // Page 9, 4.2 Final exponentiation
    // Page 5 - 6, 3.2 Frobenius Operator
    // For f ∈ Fp12, f = g + hw with g, h ∈ Fp6
    // g = g0 + g1v + g2v^2, h = h0 + h1v + h2v^2 for gi, hi ∈ Fp2
    // p-power of an arbitrary element in the quadratic extension field Fp2 can be computed
    // essentially free of cost as follows.For b = b0 + b1u, b^(p^2i) = b
    //
    // f^(p^2+1) = f · f^(-1)
    // returns cyclotomic Fp12
    #[inline(always)]
    fn pow_p2_plus_1(b: Fq12) -> Fq12 {
        Fq12 { c0: b.c0, c1: -b.c1, } * b.inv()
    }
// Software Implementation of the Optimal Ate Pairing
// Page 9, 4.2 Final exponentiation
// 
}

