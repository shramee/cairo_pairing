mod fq_;
#[cfg(test)]
mod fq_tests;

mod fq2_;
#[cfg(test)]
mod fq2_tests;

mod fq6_;
mod fq12_;

mod fq_generics;
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::fq_::{FqOps, Fq, fq};
use bn::fields::fq2_::{Fq2, fq2};
use bn::fields::fq6_::{Fq6, fq6};
use bn::fields::fq12_::{Fq12, fq12};

use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse};
