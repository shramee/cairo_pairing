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

