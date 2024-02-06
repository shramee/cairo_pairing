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
        self
    }

    #[inline(always)]
    fn exp_by_neg_x(mut self: Fq12) -> Fq12 {
        // Binary bools array of bn::curve::X
        self.exp_naf(bn::curve::x_naf())
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
        self.frob2() * self
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
}

// #[inline(always)]
fn final_exponentiation(f: Fq12) -> Fq12 {
    internal::revoke_ap_tracking();
    f.pow_p6_minus_1().pow_p2_plus_1().final_exponentiation_last_chunk()
}

#[cfg(test)]
mod test {
    use core::array::ArrayTrait;
    use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12, fq12, fq6};
    use bn::fields::fq6_::Fq6Frobenius;
    use bn::fields::fq12_::Fq12Frobenius;
    use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

    fn pair_result() -> Fq12 {
        fq12(
            0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
            0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
            0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
            0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
            0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
            0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
            0x2da44e38ec26bde1ad31495943114856dd885beb7889c590079bb300bb6ec023,
            0x1c40f4619c21dbd91ba610a8943188e35402e587a071361f60288e7e96fa33b,
            0x9ebfb41a99f28109afed1112aab3c8ab4ff6dd90097e880669c960f11106b52,
            0x2d0c275838257edb77665b9aafbbd40626b6a35fe12b4ccacee5613bf3408fc2,
            0x289d6d934bc5994e10f4dc4bfe3a5ac9cddfce66ee76df1e751b064bfdb5533d,
            0x1e18e64906693e6f4c9cd40273060c504a78843d903489abb13377666679d33f,
        )
    }

    fn exp_result() -> Fq12 {
        fq12(
            0x1025124034fecc32ba2c3bbbcdb356c5bd84a787f0a9c5e1f9a34d5b87dae85a,
            0x1aafb1f7de052c1c1187f7d294d2204bf4e854a05965817e51014a355d917f96,
            0x26c79392cd82f5f15f1366f8c70f618837fe6ccc10c10815369bc8e1412caae,
            0x1d65be11b6b500a55c3c53ca4c033319626a9bc82fa79316bfb14bcd86f0aca5,
            0x8bd3e1971621469e271e9b18016edbc3517c94001240a1e5ef3b07c10860383,
            0xe5327ccc2114231fcd953aa29ccc1fd04ec1bced962c7f9534b9a001dd41a75,
            0x2b7c8e0abca6a7476f0936f535c5e6469ad4b94f8f24c6f437f6d6686a1b381b,
            0x29679b4f134ab2b2e02d2c82a385b12d2ee2272a7e350fba6f80588c0e0afa13,
            0x29163531c4ea85c647a9cd25e2de1433f12569f772eb83fcd8a997f3ca309cee,
            0x23bc9fb95fcf761320a0a287addd92dfaeb1ffc8bf8a943e703fc39f1e9d3085,
            0x236942b30ace732d8b186b0702ea748b375e4405799aa59cf2ae5459f99216f4,
            0x10fc55420be890b138082d746e66bf86f4efe8190cc83313a792dd156bc76e1f,
        )
    }

    fn pair_mul_exp_result() -> Fq12 {
        fq12(
            0x280d0beb03619826096b4b048e2abb1af592d3d56efa2dc7fd9ce4b9a5b0c1b7,
            0x116f1c822ef34231f506b9afd9edb357ce0adb6320f5f929e477df81198b309d,
            0x2a42bcd10a9b003bf1f8afd65cf2831d708322383d498a4a1bb3ae5c20a243eb,
            0x2a0819f95ecf7e8a4405e1e706726a638550b3b20eebb66b97804be88854e679,
            0x2b2cc91cb1e19ce8b66da51c7b08643286216118bb8e062e3827b8c1f6d74e7,
            0x214dcdee43ebc72e673cc19f993703e1ad1db17113f7ae41cbddd709380d184d,
            0x18aa857acdd6783733aae6be98bf7fa14ac053fbf6f042b35bedf374eb124084,
            0x16db5d26558eb13f21bb538eafdef3d71c7738a901361fe37b2b1632c0beca,
            0x1a79cd9802cd1685c7c387362a3f2cb31c96b59d100cb38c724ad70077dd940,
            0x19e48782b668248e46f48104f64925e8a67006556a09df165e2a0ad5c0bf1cb2,
            0x2b9d548b03eb32bac1bb1dd98188668cc01dc7afcf0de68b9f5a35c2ca16813b,
            0x18ff99c25f448b082571917c3f5d9b8c6b2ec2956103c0027dbedd72ecd16c6e,
        )
    }

    #[test]
    #[available_gas(99999999999999)]
    fn test_final_exponentiation() {
        let f = pair_result();
        let result = exp_result();
        let exponent = super::final_exponentiation(f);
        assert(exponent == result, 'incorrect exponentiation');
    }
}
