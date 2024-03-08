use bn::curve::U512Fq2OpsTrait;
use core::starknet::secp256_trait::Secp256PointTrait;
use core::traits::TryInto;
use bn::traits::FieldShortcuts;
use bn::traits::FieldMulShortcuts;
use core::array::ArrayTrait;
use bn::curve::{t_naf, FIELD, FIELD_X2};
use bn::curve::{u512, mul_by_xi_nz, mul_by_v, U512BnAdd, U512BnSub, Tuple2Add, Tuple2Sub,};
use bn::curve::{u512_add, u512_sub, u512_high_add, u512_high_sub, U512Fq2Ops};
use bn::fields::{FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12, fq12, Fq12Frobenius, Fq12Squaring};
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

// Sparse Fp12 element containing c0, c1, c2, c3 and c4 Fq2s
#[derive(Copy, Drop,)]
struct Fq12Sparse01234 {
    c0: Fq2,
    c1: Fq2,
    c2: Fq2,
    c3: Fq2,
    c4: Fq2,
}

#[generate_trait]
impl FqSparse of FqSparseTrait {
    // Sparse Fp12 element containing only c3 and c4 Fq2s (c0 is 1)
    // Equivalent to,
    // Fq12{
    //   c0: Fq6{c0: 1, c1: 0, c2: 0},
    //   c1: Fq6{c0: c3, c1: c4, c2: 0},
    // }
    // https://github.com/Consensys/gnark/blob/v0.9.1/std/algebra/emulated/fields_bn254/e12_pairing.go#L150
    #[inline(always)]
    fn mul_034_by_034(self: Fq12Sparse034, rhs: Fq12Sparse034) -> Fq12Sparse01234 {
        let field_nz = FIELD.try_into().unwrap();
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

    #[inline(always)]
    fn mul_034(self: Fq12, rhs: Fq12Sparse034) -> Fq12 {
        FieldUtils::one()
    }
}
