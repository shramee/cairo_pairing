mod math {
    mod i257;
    mod fast_mod;
    #[cfg(test)]
    mod fast_mod_tests;
}
mod traits;
mod fields {
    mod fq_;
    mod fq2_;
    mod fq6_;
    mod fq12_;
    mod print;

    #[cfg(test)]
    mod tests {
        mod bench;
        mod fq;
        mod fq2;
        mod fq6;
    }
    mod fq_generics;
    use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
    use bn::fields::fq_::{Fq, FqOps, FqUtils, fq};
    use bn::fields::fq2_::{Fq2, Fq2Ops, Fq2Utils, fq2};
    use bn::fields::fq6_::{Fq6, Fq6Ops, Fq6Utils, fq6};
    use bn::fields::fq12_::{Fq12, Fq12Ops, Fq12Utils, fq12};
    use bn::traits::{FieldOps, FieldUtils};
}

use bn::traits::{FieldOps, FieldUtils};
mod bn254 {
    use bn::fields as f;
    // These paramas from:
    // https://hackmd.io/@jpw/bn254
    const ORDER: u256 =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    const FIELD: u256 =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;
    const B: u256 = 3;

    fn fq_non_residue() -> f::Fq {
        f::fq(21888242871839275222246405745257275088696311157297823662689037894645226208582)
    }

    fn fq2_non_residue() -> f::Fq2 {
        f::fq2(9, 1)
    }

    const ATE_LOOP_COUNT: u128 = 29793968203157093288;
    const LOG_ATE_LOOP_COUNT: u128 = 63;

    #[cfg(test)]
    mod tests {
        mod g1;
        mod pairing;
    }
    mod g1;
    mod g2;
    mod pairing;
    use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse};
}
use math::fast_mod;
use bn254::{g1, g2, pairing};
