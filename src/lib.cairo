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
        mod fq12;
    }
    mod fq_generics;
    use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
    use bn::fields::fq_::{Fq, FqOps, FqUtils, fq};
    use bn::fields::fq2_::{Fq2, Fq2Ops, Fq2Utils, fq2};
    use bn::fields::fq6_::{Fq6, Fq6Ops, Fq6Utils, fq6};
    use bn::fields::fq12_::{Fq12, Fq12Ops, Fq12Utils, fq12};
    use bn::traits::{FieldOps, FieldUtils};
}

#[cfg(test)]
mod experiments;

use bn::traits::{FieldOps, FieldUtils};
mod curve;
use math::fast_mod;
use curve::{g1, g2, pairing};
