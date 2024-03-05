use bn::fields::{Fq12, Fq12Utils, Fq2, Fq2Utils};
use bn::curve::groups::{g1, g2, ECGroup};
use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::traits::MillerEngine;

#[derive(Copy, Drop)]
struct PreCompute {}

type Pair = (AffineG1, AffineG2);

impl SinglePairMiller of MillerEngine<Pair, PreCompute, AffineG2, Fq12> {
    fn get_precompute_and_temp_r(self: @Pair) -> (PreCompute, AffineG2) {
        let (_, q) = self;
        (PreCompute {}, q.clone(),)
    }
    // 0 bit
    fn miller_bit_o(self: @Pair, pre_comp: @PreCompute, ref acc: AffineG2, ref f: Fq12) {}
    // 1 bit
    fn miller_bit_p(self: @Pair, pre_comp: @PreCompute, ref acc: AffineG2, ref f: Fq12) {}
    // -1 bit
    fn miller_bit_n(self: @Pair, pre_comp: @PreCompute, ref acc: AffineG2, ref f: Fq12) {}
}

// doubleAndAddStep doubles p1 and adds p2 to the result in affine coordinates, and evaluates the line in Miller loop
// https://eprint.iacr.org/2022/1162 (Section 6.1)
fn step_double_and_add(ref acc: AffineG2,) {}


// doubleAndAddStep doubles p1 and adds p2 to the result in affine coordinates, and evaluates the line in Miller loop
// https://eprint.iacr.org/2022/1162 (Section 6.1)
fn step_double(ref acc: AffineG2,) {}
