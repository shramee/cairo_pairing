use bn::traits::FieldShortcuts;
use bn::traits::FieldMulShortcuts;
use core::array::ArrayTrait;
use bn::curve::{t_naf, FIELD, FIELD_X2};
use bn::curve::{u512, mul_by_xi_nz, mul_by_v, U512BnAdd, U512BnSub, Tuple2Add, Tuple2Sub,};
use bn::curve::{u512_add, u512_sub, u512_high_add, u512_high_sub, U512Fq2Ops};
use bn::fields::{FieldUtils, FieldOps, fq, Fq, Fq2, ufq2_inv, Fq6, Fq12, fq12, Fq12Frobenius};
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{Fq2Display, FqDisplay, u512Display};

#[derive(Copy, Drop,)]
struct Krbn2345 {
    g2: Fq2,
    g3: Fq2,
    g4: Fq2,
    g5: Fq2,
}

#[inline(always)]
fn x2(a: Fq2) -> Fq2 {
    a.u_add(a)
}

#[inline(always)]
fn x4(a: Fq2) -> Fq2 {
    let a_twice = x2(a);
    a_twice.u_add(a_twice)
}

#[inline(always)]
fn X2(a: (u512, u512)) -> (u512, u512) {
    a + a
}

#[generate_trait]
impl Fq12Squaring of Fq12SquaringTrait {
    // Karabina compress Fq12 a0, a1, a2, a3, a4, a5 to a2, a3, a4, a5
    // For Karabina sqr 2345
    //
    // https://github.com/mratsim/constantine/blob/c7979b003372b329dd450ff152bb5945cafb0db5/constantine/math/pairings/cyclotomic_subgroups.nim#L639
    // Karabina uses the cubic over quadratic representation
    // But we use the quadratic over cubic Fq12 -> Fq6 -> Fq2
    // `Fq12` --quadratic-- `Fq6` --cubic-- `Fq2`
    // canonical <=> cubic over quadratic <=> quadratic over cubic
    //    c0     <=>        g0            <=>            b0
    //    c1     <=>        g2            <=>            b3
    //    c2     <=>        g4            <=>            b1
    //    c3     <=>        g1            <=>            b4
    //    c4     <=>        g3            <=>            b2
    //    c5     <=>        g5            <=>            b5
    #[inline(always)]
    fn krbn_compress_2345(self: Fq12) -> Krbn2345 {
        let Fq12 { c0: Fq6 { c0: _0, c1: g4, c2: g3 }, c1: Fq6 { c0: g2, c1: _1, c2: g5 } } = self;
        Krbn2345 { g2, g3, g4, g5 }
    }

    // Karabina decompress a2, a3, a4, a5 to Fq12 a0, a1, a2, a3, a4, a5
    fn krbn_decompress(self: Krbn2345, field_nz: NonZero<u256>) -> Fq12 {
        core::internal::revoke_ap_tracking();
        let Krbn2345 { g2, g3, g4, g5 } = self;
        // Si = gi^2
        if g2.c0.c0 == 0 && g2.c1.c0 == 0 {
            // g1 = 2g4g5/g3
            let t2g4g5 = x2(g4 * g5);
            let g1 = t2g4g5 * g3.inv(field_nz);

            // g0 = (2S1 - 3g3g4)ξ + 1
            let S1 = g1.u_sqr();
            let T_g3g4 = g3.u_mul(g4);
            let Tmp = X2(S1 - T_g3g4); // 2S1 - 2g3g4
            let G0 = Tmp - T_g3g4; // 2S1 - 3g3g4
            let mut g0: Fq2 = G0.to_fq(field_nz).mul_by_nonresidue(); // (2S1 - 3g3g4)ξ
            g0.c0.c0 = g0.c0.c0 + 1; // Add 1, POTENTIAL OVERFLOW

            Fq12 { c0: Fq6 { c0: g0, c1: g4, c2: g3 }, c1: Fq6 { c0: g2, c1: g1, c2: g5 } }
        } else {
            // g1 = (S5ξ + 3S4 - 2g3)/4g2
            let S5xi = mul_by_xi_nz(g5.u_sqr(), field_nz);
            let S4 = g4.u_sqr();
            let Tmp = S4.u512_sub_fq(g3); // S4 - g3
            let g1: Fq2 = (S5xi + S4.u_add(Tmp.u_add(Tmp))).to_fq(field_nz); // (S5ξ + 3S4 - 2g3)
            let g1 = g1.mul(ufq2_inv(x4(g2), field_nz)); // div by 4g2

            // g0 = (2S1 + g2g5 - 3g3g4)ξ + 1
            let S1 = g1.u_sqr();
            let T_g3g4 = g3.u_mul(g4);
            let T_g2g5 = g2.u_mul(g5);
            let Tmp = X2(S1 - T_g3g4); // 2S1 - 2g3g4
            let G0 = Tmp + T_g2g5 - T_g3g4; // 2S1 + g2g5 - 3g3g4
            let mut g0: Fq2 = G0.to_fq(field_nz).mul_by_nonresidue(); // (2S1 + g2g5 - 3g3g4)ξ
            g0.c0.c0 = g0.c0.c0 + 1; // Add 1, POTENTIAL OVERFLOW

            Fq12 { c0: Fq6 { c0: g0, c1: g4, c2: g3 }, c1: Fq6 { c0: g2, c1: g1, c2: g5 } }
        }
    }

    // This Karabina implementation is adjusted for the quadratic over cubic representation
    // https://github.com/Consensys/gnark-crypto/blob/v0.12.1/ecc/bn254/internal/fptower/e12.go#L143
    fn sqr_krbn_1235(self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        core::internal::revoke_ap_tracking();
        let Fq12 { c0: Fq6 { c0: _g0, c1: g1, c2: g2 }, c1: Fq6 { c0: g3, c1: _g4, c2: g5 } } =
            self;

        let S1: (u512, u512) = g1.u_sqr();
        let S2: (u512, u512) = g2.u_sqr();
        let S3: (u512, u512) = g3.u_sqr();
        let S5: (u512, u512) = g5.u_sqr();
        let S1_5: (u512, u512) = (g1 + g5).u_sqr();
        let S2_3: (u512, u512) = (g2 + g3).u_sqr();

        // h1 = 3 * g3² + 3 * nr * g2² - 2*g1
        let Tmp = S3 + mul_by_xi_nz(S2, field_nz); // g3² + nr * g2²
        let h1 = X2(Tmp.u512_sub_fq(g1)) + Tmp;
        let h1 = h1.to_fq(field_nz);

        // h2 = 3 * nr * g5² + 3 * g1² - 2*g2
        let Tmp = mul_by_xi_nz(S5, field_nz) + S1; // nr * g5² + g1²
        let h2 = X2(Tmp.u512_sub_fq(g2)) + Tmp;
        let h2 = h2.to_fq(field_nz);

        // 2 * g1 * g5 = (S1_5 - S1 - S5)
        // h3 = 6 * nr * g1 * g5 + 2*g3
        let Tmp = mul_by_xi_nz(S1_5 - S1 - S5, field_nz); // 2 * g1 * g5
        let h3 = X2(Tmp.u512_add_fq(g3)) + Tmp;
        let h3 = h3.to_fq(field_nz);

        // 2 * g3 * g2 = (S2_3 - S2 - S3)
        // h5 = 6 * g3 * g2 + 2*g5
        let Tmp = S2_3 - S2 - S3; // 2 * g2 * g3
        let h5 = X2(Tmp.u512_add_fq(g5)) + Tmp;
        let h5 = h5.to_fq(field_nz);

        let _0 = FieldUtils::zero();

        Fq12 { c0: Fq6 { c0: _0, c1: h1, c2: h2 }, c1: Fq6 { c0: h3, c1: _0, c2: h5 } }
    }

    // https://eprint.iacr.org/2010/542.pdf
    // Compressed Karabina 2345 square
    fn sqr_krbn(self: Krbn2345, field_nz: NonZero<u256>) -> Krbn2345 {
        core::internal::revoke_ap_tracking();
        // Input: self = (a2 +a3s)t+(a4 +a5s)t2 ∈ Gφ6(Fp2)
        // Output: self^2 = (c2 +c3s)t+(c4 +c5s)t2 ∈ Gφ6 (Fp2 ).
        let Krbn2345 { g2, g3, g4, g5 } = self;

        // Si,j = (gi + gj )^2 and Si = gi^2
        let S2: (u512, u512) = g2.u_sqr();
        let S3: (u512, u512) = g3.u_sqr();
        let S4: (u512, u512) = g4.u_sqr();
        let S5: (u512, u512) = g5.u_sqr();
        let S4_5: (u512, u512) = (g4 + g5).u_sqr();
        let S2_3: (u512, u512) = (g2 + g3).u_sqr();

        // h2 = 3(S4_5 − S4 − S5)ξ + 2g2;
        let Tmp = mul_by_xi_nz(S4_5 - S4.u_add(S5), field_nz);
        let h2 = X2(Tmp.u512_add_fq(g2)) + Tmp;
        let h2 = h2.to_fq(field_nz);

        // h3 = 3(S4 + S5ξ) - 2g3;
        let Tmp = S4 + mul_by_xi_nz(S5, field_nz);
        let h3 = X2(Tmp.u512_sub_fq(g3)) + Tmp;
        let h3 = h3.to_fq(field_nz);

        // h4 = 3(S2 + S3ξ) - 2g4;
        let Tmp = S2 + mul_by_xi_nz(S3, field_nz);
        let h4 = X2(Tmp.u512_sub_fq(g4)) + Tmp;
        let h4 = h4.to_fq(field_nz);

        // h5 = 3(S2_3 - S2 - S3) + 2g5;
        let Tmp = S2_3 - S2.u_add(S3);
        let h5 = X2(Tmp.u512_add_fq(g5)) + Tmp;
        let h5 = h5.to_fq(field_nz);

        Krbn2345 { g2: h2, g3: h3, g4: h4, g5: h5, }
    }

    #[inline(always)]
    fn krbn_sqr_4x(self: Krbn2345, field_nz: NonZero<u256>) -> Krbn2345 {
        self.sqr_krbn(field_nz).sqr_krbn(field_nz).sqr_krbn(field_nz).sqr_krbn(field_nz)
    }

    fn sqr_6_times(self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        core::internal::revoke_ap_tracking();
        self
            .krbn_compress_2345()
            .krbn_sqr_4x(field_nz) // ^2^4
            .sqr_krbn(field_nz) // ^2^5
            .sqr_krbn(field_nz) // ^2^6
            .krbn_decompress(field_nz)
    }

    // Called only once hence inlined
    #[inline(always)]
    fn sqr_7_times(self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        core::internal::revoke_ap_tracking();
        self
            .krbn_compress_2345()
            .krbn_sqr_4x(field_nz) // ^2^4
            .sqr_krbn(field_nz) // ^2^5
            .sqr_krbn(field_nz) // ^2^6
            .sqr_krbn(field_nz) // ^2^7
            .krbn_decompress(field_nz)
    }

    fn sqr_8_times(self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        core::internal::revoke_ap_tracking();
        self
            .krbn_compress_2345()
            .krbn_sqr_4x(field_nz)
            .krbn_sqr_4x(field_nz)
            .krbn_decompress(field_nz)
    }

    // Called only once hence inlined
    #[inline(always)]
    fn sqr_10_times(self: Fq12, field_nz: NonZero<u256>) -> Fq12 {
        core::internal::revoke_ap_tracking();
        self
            .krbn_compress_2345()
            .krbn_sqr_4x(field_nz) // ^2^4
            .krbn_sqr_4x(field_nz) // ^2^8
            .sqr_krbn(field_nz) // ^2^9
            .sqr_krbn(field_nz) // ^2^10
            .krbn_decompress(field_nz)
    }

    // Cyclotomic squaring 
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
        let T0 = z0.u_add(z1).u_mul(z1.mul_by_nonresidue().u_add(z0))
            - Tmp
            - mul_by_xi_nz(Tmp, field_nz);
        // let t1 = tmp + tmp;
        let T1 = Tmp + Tmp;

        // let tmp = z2 * z3;
        let Tmp = z2.u_mul(z3);
        // let t2 = (z2 + z3) * (z3.mul_by_nonresidue() + z2) - tmp - tmp.mul_by_nonresidue();
        let T2 = z2.u_add(z3).u_mul(z3.mul_by_nonresidue().u_add(z2))
            - Tmp
            - mul_by_xi_nz(Tmp, field_nz);
        // let t3 = tmp + tmp;
        let T3 = Tmp + Tmp;

        // let tmp = z4 * z5;
        let Tmp = z4.u_mul(z5);
        // let t4 = (z4 + z5) * (z5.mul_by_nonresidue() + z4) - tmp - tmp.mul_by_nonresidue();
        let T4 = z4.u_add(z5).u_mul(z5.mul_by_nonresidue().u_add(z4))
            - Tmp
            - mul_by_xi_nz(Tmp, field_nz);
        // let t5 = tmp + tmp;
        let T5 = Tmp + Tmp;

        let Z0 = T0.u512_sub_fq(z0);
        let Z0 = Z0 + Z0;
        let Z0 = Z0 + T0;

        let Z1 = T1.u512_add_fq(z1);
        let Z1 = Z1 + Z1;
        let Z1 = Z1 + T1;

        let Tmp = mul_by_xi_nz(T5, field_nz);
        let Z2 = Tmp.u512_add_fq(z2);
        let Z2 = Z2 + Z2;
        let Z2 = Z2 + Tmp;

        let Z3 = T4.u512_sub_fq(z3);
        let Z3 = Z3 + Z3;
        let Z3 = Z3 + T4;

        let Z4 = T2.u512_sub_fq(z4);
        let Z4 = Z4 + Z4;
        let Z4 = Z4 + T2;

        let Z5 = T3.u512_add_fq(z5);
        let Z5 = Z5 + Z5;
        let Z5 = Z5 + T3;

        Fq12 {
            c0: Fq6 { c0: Z0.to_fq(field_nz), c1: Z4.to_fq(field_nz), c2: Z3.to_fq(field_nz) },
            c1: Fq6 { c0: Z2.to_fq(field_nz), c1: Z1.to_fq(field_nz), c2: Z5.to_fq(field_nz) },
        }
    }
}
