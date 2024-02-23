use bn::traits::FieldShortcuts;
use bn::traits::FieldMulShortcuts;
use core::array::ArrayTrait;
use bn::curve::{u512, mul_by_xi, mul_by_v, U512BnAdd, U512BnSub, Tuple2Add, Tuple2Sub, FIELD};
use bn::fields::{FieldUtils, FieldOps, fq, Fq, Fq2, Fq6, Fq12, fq12, Fq12Frobenius, Fq12FinalExpo};
use bn::fields::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};

// raising f ∈ Fp12 to the power e = (p^12 - 1)/r can be done in three parts,
// e = (p^6 - 1) * (p^2 + 1) * (p4 − p2 + 1) / r

// #[inline(always)]
fn final_exponentiation(f: Fq12) -> Fq12 {
    internal::revoke_ap_tracking();
    let field_nz = FIELD.try_into().unwrap();

    f.pow_p6_minus_1().pow_p2_plus_1().pow_p4_minus_p2_plus_1(field_nz)
}
