use bn::curve::U512Fq2OpsTrait;
use core::starknet::secp256_trait::Secp256PointTrait;
use core::traits::TryInto;
use bn::traits::FieldShortcuts;
use bn::traits::FieldMulShortcuts;
use core::array::ArrayTrait;
use bn::curve::{t_naf, FIELD, FIELD_X2};
use bn::curve::{
    u512, mul_by_xi_nz, mul_by_v, U512BnAdd, U512BnSub, Tuple2Add, Tuple2Sub, Tuple3Add, Tuple3Sub,
};
use bn::curve::{u512_add, u512_sub, u512_high_add, u512_high_sub, U512Fq2Ops};
use bn::fields::{
    FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, fq6, Fq12, fq12, Fq12Frobenius, Fq12Squaring
};
use bn::fields::fq_6::SixU512;
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{Fq2Display, FqDisplay, u512Display};

// Sparse Fp12 element containing only c3 and c4 Fq2s (c0 is 1)
// Equivalent to,
// Fq12{
//   c0: Fq6{c0: 1, c1: 0, c2: 0},
//   c1: Fq6{c0: c3, c1: c4, c2: 0},
// }
#[derive(Copy, Drop,)]
struct Fq12Sparse034 {
    c3: Fq2,
    c4: Fq2,
}

// Sparse Fp6 element derived from second Fq6 of a sparse Fq12 034
// containing only c0 and c1 Fq2s from c3 and c4 of sparse Fq12 034
// Equivalent to,
// Fq6{c0: c3, c1: c4, c2: 0}
#[derive(Copy, Drop,)]
struct Fq6Sparse01 {
    c0: Fq2,
    c1: Fq2,
}

fn sparse_fq6(c0: Fq2, c1: Fq2) -> Fq6Sparse01 {
    Fq6Sparse01 { c0, c1 }
}

// Sparse Fp12 element containing c0, c1, c2, c3 and c4 Fq2s
#[derive(Copy, Drop,)]
struct Fq12Sparse01234 {
    c0: Fq2,
    c1: Fq2,
    c2: Fq2,
    c3: Fq2,
    c4: Fq2,
}

// Sparse Fp12 element containing only c3 and c4 Fq2s (c0 is 1)
// Equivalent to,
// Fq12{
//   c0: Fq6{c0: 1, c1: 0, c2: 0},
//   c1: Fq6{c0: c3, c1: c4, c2: 0},
// }
#[generate_trait]
impl FqSparse of FqSparseTrait {
    //////////////////////////////////////////////////////////////
    /////////////////////// Fq6 sparse ///////////////////////////
    //////////////////////////////////////////////////////////////
    // These methods are used internally and work with Fq6Sparse01

    // Mul Fq6 with a sparse Fq6 01 derived from a sparse 034 Fq12
    // Same as Fq6 u_mul but with b2 as zero (and associated ops removed)
    #[inline(always)]
    fn u_mul_01(self: Fq6, rhs: Fq6Sparse01, field_nz: NonZero<u256>) -> SixU512 {
        core::internal::revoke_ap_tracking();
        // Input:a = (a0 + a1v + a2v2) and b = (b0 + b1v) ∈ Fp6
        // Output:c = a · b = (c0 + c1v + c2v2) ∈ Fp6
        let Fq6 { c0: a0, c1: a1, c2: a2 } = self;
        let Fq6Sparse01 { c0: b0, c1: b1, } = rhs;

        // b2 is zero so all ops associated ar removed

        // v0 = a0b0, v1 = a1b1, v2 = a2b2
        let (V0, V1,) = (a0.u_mul(b0), a1.u_mul(b1),);

        // c0 = v0 + ξ((a1 + a2)(b1 + b2) - v1 - v2)
        let C0 = V0 + mul_by_xi_nz(a1.u_add(a2).u_mul(b1) - V1, field_nz);
        // c1 =(a0 + a1)(b0 + b1) - v0 - v1 + ξv2
        let C1 = a0.u_add(a1).u_mul(b0.u_add(b1)) - V0 - V1;
        // c2 = (a0 + a2)(b0 + b2) - v0 + v1 - v2,
        let C2 = a0.u_add(a2).u_mul(b0) - V0 + V1;

        (C0, C1, C2)
    }

    // Mul Fq6 with a sparse Fq6 01 derived from a sparse 034 Fq12
    // Same as Fq6 u_mul but with a2 and b2 as zero (and associated ops removed)
    #[inline(always)]
    fn mul_01_by_01(self: Fq6Sparse01, rhs: Fq6Sparse01, field_nz: NonZero<u256>) -> SixU512 {
        // Input:a = (a0 + a1v) and b = (b0 + b1v) ∈ Fp6
        // Output:c = a · b = (c0 + c1v + c2v2) ∈ Fp6
        let Fq6Sparse01 { c0: a0, c1: a1, } = self;
        let Fq6Sparse01 { c0: b0, c1: b1, } = rhs;

        // a2 and b2 is zero so all ops associated ar removed

        // v0 = a0b0, v1 = a1b1, v2 = a2b2
        let (V0, V1,) = (a0.u_mul(b0), a1.u_mul(b1),);

        // c0 = v0 + ξ((a1 + a2)(b1 + b2) - v1 - v2)
        let C0 = V0 + mul_by_xi_nz(a1.u_mul(b1) - V1, field_nz);
        // c1 =(a0 + a1)(b0 + b1) - v0 - v1 + ξv2
        let C1 = a0.u_add(a1).u_mul(b0.u_add(b1)) - V0 - V1;
        // c2 = (a0 + a2)(b0 + b2) - v0 + v1 - v2,
        let C2 = a0.u_mul(b0) - V0 + V1;

        (C0, C1, C2)
    }

    //////////////////////////////////////////////////////////////
    /////////////////////// Fq12 sparse //////////////////////////
    //////////////////////////////////////////////////////////////

    // Mul a sparse 034 Fq12 by another 034 Fq12 resulting in a sparse 01234
    // https://github.com/Consensys/gnark/blob/v0.9.1/std/algebra/emulated/fields_bn254/e12_pairing.go#L150
    #[inline(always)]
    fn mul_034_by_034(
        self: Fq12Sparse034, rhs: Fq12Sparse034, field_nz: NonZero<u256>
    ) -> Fq12Sparse01234 {
        let Fq12Sparse034 { c3: c3, c4: c4 } = self;
        let Fq12Sparse034 { c3: d3, c4: d4 } = rhs;
        // x3 = c3 * d3
        let X3 = c3.u_mul(d3);
        // x4 = c4 * d4
        let X4 = c4.u_mul(d4);
        // x04 = c4 + d4
        let x04 = c4 + d4;
        // x03 = c3 + d3
        let x03 = c3 + d3;
        // tmp = c3 + c4
        let tmp = c3.u_add(c4);
        // x34 = d3 + d4
        let x34 = d3.u_add(d4);
        // x34 = x34 * tmp
        let X34 = x34.u_mul(tmp);
        // x34 = x34 - x3
        let X34 = X34 - X3;
        // x34 = x34 - x4
        let X34 = X34 - X4;

        // zC0B0 = ξx4
        // zC0B0 = zC0B0 + 1
        // zC0B1 = x3
        // zC0B2 = x34
        // zC1B0 = x03
        // zC1B1 = x04

        let mut zC0B0: Fq2 = X4.to_fq(field_nz).mul_by_nonresidue();
        zC0B0.c0.c0 = zC0B0.c0.c0 + 1; // POTENTIAL OVERFLOW
        Fq12Sparse01234 {
            c0: zC0B0, c1: X3.to_fq(field_nz), c2: X34.to_fq(field_nz), c3: x03, c4: x04,
        }
    }

    // Mul Fq12 with a sparse 034 Fq12
    // https://github.com/Consensys/gnark/blob/v0.9.1/std/algebra/emulated/fields_bn254/e12_pairing.go#L116
    #[inline(always)]
    fn mul_034(self: Fq12, rhs: Fq12Sparse034, field_nz: NonZero<u256>) -> Fq12 {
        let Fq12 { c0: a0, c1: a1 } = self;
        let Fq12Sparse034 { mut c3, c4 } = rhs;
        // a0 := z.C0
        // b := e.MulBy01(&z.C1, c3, c4)
        let B = a1.u_mul_01(sparse_fq6(c3, c4), field_nz);
        // c3 = e.Ext2.Add(e.Ext2.One(), c3)
        c3.c0.c0 += 1;
        // d := e.Ext6.Add(&z.C0, &z.C1)
        let d = a0 + a1; // Requires reduction, or overflow in next step
        // d = e.MulBy01(d, c3, c4)
        let D = d.u_mul_01(sparse_fq6(c3, c4), field_nz);

        // zC1 := e.Ext6.Add(&a0, b)
        // zC1 = e.Ext6.Neg(zC1)
        // zC1 = e.Ext6.Add(zC1, d)
        // C1 = D + (-(a0 + B))
        let C1 = D - B.u512_add_fq(a0);
        // zC0 := e.Ext6.MulByNonResidue(b)
        let C0 = mul_by_v(B);
        // zC0 = e.Ext6.Add(zC0, &a0)
        let C0 = C0.u512_add_fq(a0);

        Fq12 { //
         c0: C0.to_fq(field_nz), //
         c1: C1.to_fq(field_nz), //
         }
    }
}
