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

#[cfg(test)]
mod test {
    use bn::curve::pairing::final_exponentiation::FinalExponentiationTrait;
    use bn::curve::pairing::final_exponentiation::final_exponentiation;
    use core::array::ArrayTrait;
    use bn::fields::{
        print::Fq12PrintImpl, print::FqPrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12,
        fq12, fq6
    };
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

    fn pair_result_21() -> Fq12 {
        fq12(
            0x67344e1277398709a07f22125f334c042889b9968132d91836456f02693e2aa,
            0x9eb543ae69ac30e7c5a1d8740db1a27b76ce7639c31b4c5097118031dcc9fd6,
            0x1a828818f6199acedcc7e3b04359dd558e34046b9367d4f43e90530a3241800e,
            0x50eba70419a4a7703a843ab3ba1d635378175acdf8eecbdf959bba7b7d30458,
            0x51c4fe05ca153f901a16e7aa2d17eaae8ba67e06ff0f36f6b039a1eacf2b6cf,
            0x65ff7c2e78658da7694f442878d48d346b33678a6fe2ead51b475977e2c4f7f,
            0xc13c405903b8328438e35f5eae314749ae264ffeb6c4e4429108b29338da611,
            0x9b07dee721f8a8468804de92b08bac6dae98d8246da83ff65b96a7ab3241652,
            0x19731a39f257d88617714358ee57d06ae39d2b51b07c9de926be9ae4fa4ed2cc,
            0x103dea7bed900dd8dbabac886bd24e973cee753d8c1781b71f8b40b3ecaeb04f,
            0x239d3477b8798bb2227e8e21d724419e093c5c678058049a61bb69e21e046c00,
            0x309258557eb06754d1dcfb8a6fa4a98c59538a8dc0317cbae8fd97078c36cf0,
        )
    }

    fn easy_result() -> Fq12 {
        fq12(
            0x2a4ca72fdd0af3ff86e646da9b96a7cc69407cc1e4f87dd12f6552d6168cc1cb,
            0x1e632505544fad7aa191c7b1c7cc7a816d43ea1e3c222a9f633f2532beba7a90,
            0x29f7ffe4990167e9c40b82e10d99104ed5d58a10505ca9df3fe6f89f6d724631,
            0x2ecce5bd65fbc42a4fbacc84ed28a52669da21815d300b2c1a85cf547f941dff,
            0x2379db1f2f5cc1fbc708decedaec77bef7d70e5b45e93e0e3f4ed386e4f98543,
            0x48bcf44109b965cfcb21c0fd27c8a6a46b85d3d6bc8eef39bf4808fd737cc9b,
            0x14d67d4a9d98bb99dca11a3dfdf7ee4655c5305123e8676abd56cef0448cf135,
            0x2f9b1014ad8e0e49630b434d1869fbf7172935beff46af19cd14415f3592b2a2,
            0x79cb3aad73095167444481a53809f754281e717954a8247baa89729918cb2ce,
            0x2a3b1205bc914c2659c0eeea8e956ca4fd0386d8e5a05ba73a44114db999f936,
            0x2ed2c21f4810cf49ad8f51cc1bd2d28972a066bb153f23f87e955496865cccb4,
            0x24c11b663b70d224c7c3f096026b6aa418a4945ffcc6d8aaa5522633b2836b49,
        )
    }

    fn final_result() -> Fq12 {
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

    // #[test]
    // #[available_gas(99999999999999)]
    // fn easy() {
    //     let f = pair_result();
    //     assert(f.pow_p6_minus_1().pow_p2_plus_1() == easy_result(), 'incorrect exponentiation');
    // }

    // #[test]
    // #[available_gas(99999999999999)]
    // fn hard() {
    //     let f = easy_result();
    //     assert(f.pow_p4_minus_p2_plus_1() == final_result(), 'incorrect exponentiation');
    // }

    #[test]
    #[available_gas(99999999999999)]
    fn exponentiation_compare() {
        let f12 = final_exponentiation(pair_result());
        let f21 = final_exponentiation(pair_result_21());
        let f_random = final_exponentiation(easy_result());

        assert(f12 != FieldUtils::one(), 'degenerate exponentiation');
        assert(f12 == f21, 'incorrect exponentiation');
        assert(f12 != f_random, 'incorrect match');
    }

    #[test]
    #[available_gas(100000000)]
    fn pow_test() {
        let x = easy_result();
        let o = (false, false);
        let p = (true, true);
        let n = (true, false);
        let xpow = x.exp_naf(array![n, o, o, p]);
        let expected = x.cyclotomic_sqr().cyclotomic_sqr().cyclotomic_sqr() / x;
        assert(xpow == expected, 'incorrect pow');
    }
// #[test]
// #[available_gas(99999999999999)]
// fn cyclotomic_sqr() {
//     let f = easy_result();
//     assert(f.sqr() == f.cyclotomic_sqr(), 'incorrect cyclo sqr');
// }
}
