mod fq_;
#[cfg(test)]
mod fq_tests;

mod fq2_;
#[cfg(test)]
mod fq2_tests;

mod fq6_;
#[cfg(test)]
mod fq6_tests;

mod fq12_;

#[cfg(test)]
mod bench;
mod print {
    use super::{Fq, Fq2, Fq6, Fq12};
    use debug::PrintTrait;
    #[cfg(test)]
    impl FqPrintImpl of PrintTrait<Fq> {
        fn print(self: Fq) {
            self.c0.print();
        }
    }

    #[cfg(test)]
    impl Fq2PrintImpl of PrintTrait<Fq2> {
        fn print(self: Fq2) {
            self.c0.print();
            self.c1.print();
        }
    }

    #[cfg(test)]
    impl Fq6PrintImpl of PrintTrait<Fq6> {
        fn print(self: Fq6) {
            self.c0.print();
            self.c1.print();
            self.c2.print();
        }
    }

    #[cfg(test)]
    impl Fq12PrintImpl of PrintTrait<Fq12> {
        fn print(self: Fq12) {
            self.c0.print();
            self.c1.print();
        }
    }
}
mod fq_generics;
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::fq_::{Fq, FqOps, FqUtils, fq};
use bn::fields::fq2_::{Fq2, Fq2Ops, Fq2Utils, fq2};
use bn::fields::fq6_::{Fq6, Fq6Ops, Fq6Utils, fq6};
use bn::fields::fq12_::{Fq12, Fq12Ops, Fq12Utils, fq12};
use bn::traits::{FieldOps, FieldUtils};

use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse};
