mod math {
    mod i257;
    mod fast_mod;
// #[cfg(test)]
// mod fast_mod_tests;
}
mod traits;
mod fields {
    mod fq_generics;
    mod fq_1;
    mod fq_2;
    mod fq_6;
    mod fq_12;
    mod fq_12_expo;
    mod frobenius;
    mod print;

    #[cfg(test)]
    mod tests { //
        // mod bench;
        // mod fq;
        mod fq2;
        mod fq6;
    // mod fq12;
    // mod frobenius;
    }
    use fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
    use fq_1::{Fq, FqOps, FqShort, FqMulShort, FqUtils, fq};
    use fq_2::{Fq2, Fq2Ops, Fq2Short, Fq2MulShort, Fq2Utils, fq2, Fq2Frobenius, Fp2IntoU512Tuple};
    use fq_6::{Fq6, Fq6Ops, Fq6Short, Fq6MulShort, Fq6Utils, fq6, Fq6Frobenius};
    use fq_12::{Fq12, Fq12Ops, Fq12Utils, fq12, Fq12Frobenius};
    use fq_12_expo::Fq12FinalExpo;
    use bn::traits::{FieldOps, FieldUtils};
}

use bn::traits::{FieldOps, FieldUtils};
mod curve;
use math::fast_mod;
use curve::{groups as g, pairing};
// #[cfg(test)]
// mod playground;
// #[cfg(test)]
// mod tests;


