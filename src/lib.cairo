mod traits;
use traits::{FieldOps, FieldUtils};

mod curve;
use curve::{groups as g, pairing};

mod math {
    mod i257;
    mod fast_mod;
// #[cfg(test)]
// mod fast_mod_tests;
}
use math::fast_mod;

mod fields {
    mod fq_generics;
    mod fq_sparse;
    mod fq_1;
    mod fq_2;
    mod fq_6;
    mod fq_12;
    mod fq_12_squaring;
    mod fq_12_exponentiation;
    mod frobenius;
    mod print;

    #[cfg(test)]
    mod tests { //
    // mod fq;
    // mod fq2;
    // mod fq6;
    // mod fq12;
    // mod fq12_expo;
    // mod fq_sparse;
    // mod u512;
    // mod frobenius;
    }

    use fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
    use fq_1::{Fq, FqOps, FqShort, FqMulShort, FqUtils, fq, FqIntoU512Tuple};
    use fq_2::{
        Fq2, Fq2Ops, Fq2Short, Fq2MulShort, Fq2Utils, fq2, Fq2Frobenius, Fq2IntoU512Tuple, ufq2_inv
    };
    use fq_6::{Fq6, Fq6Ops, Fq6Short, Fq6MulShort, Fq6Utils, fq6, Fq6Frobenius, SixU512};
    use fq_12::{Fq12, Fq12Ops, Fq12Utils, fq12, Fq12Frobenius};
    use fq_12_exponentiation::Fq12Exponentiation;
    use fq_sparse::{FqSparse, Fq12Sparse034, Fq12Sparse01234, Fq6Sparse01, sparse_fq6};
    use fq_12_squaring::{Fq12Squaring, Krbn2345};
    use bn::traits::{FieldOps, FieldUtils};
}

mod groth16 {
    mod utils;
    mod verifier;
    mod setup;
    mod fixture;
    use verifier::verify;
    use setup::setup_precompute;
    #[cfg(test)]
    mod tests;
}
// #[cfg(test)]
// mod playground;
// #[cfg(test)]
// mod tests;
// #[cfg(test)]
// mod bench;


