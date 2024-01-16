mod fq_;
#[cfg(test)]
mod fq_tests;

mod fq2_;
mod fq6_;
mod fq12_;

use bn::fields::fq_::{Fq, fq};
use bn::fields::fq2_::{Fq2, fq2};
use bn::fields::fq6_::{Fq6, fq6};
use bn::fields::fq12_::{Fq12, fq12};

use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse};
