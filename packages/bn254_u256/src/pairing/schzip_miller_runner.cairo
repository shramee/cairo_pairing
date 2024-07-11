use ec_groups::{LineFn, LinesArray, LinesArrayGet};
use bn254_u256::{Fq, Fq2, Fq12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve};
use bn254_u256::pairing::utils::{SZCommitment, SZPreCompute, SZAccumulator, LnFn, SZPreComLines};
use bn_ate_loop::MillerRunner;

pub impl Miller_Bn254_U256 of MillerRunner<Bn254U256Curve, SZPreComLines, SZAccumulator> {
    // first and second step, O and N
    fn bit_1st_2nd(
        self: @SZPreComLines, ref curve: Bn254U256Curve, i1: u32, i2: u32, ref acc: SZAccumulator
    ) { //
        self.bit_o(ref curve, i1, ref acc);
        self.bit_n(ref curve, i2, ref acc);
    }

    // 0 bit
    fn bit_o(self: @SZPreComLines, ref curve: Bn254U256Curve, i: u32, ref acc: SZAccumulator) { //
    // @TODO
    }

    // 1 bit
    fn bit_p(self: @SZPreComLines, ref curve: Bn254U256Curve, i: u32, ref acc: SZAccumulator) { //
    // @TODO
    }

    // -1 bit
    fn bit_n(self: @SZPreComLines, ref curve: Bn254U256Curve, i: u32, ref acc: SZAccumulator) { //
    // @TODO
    }

    // last step
    fn last(self: @SZPreComLines, ref curve: Bn254U256Curve, ref acc: SZAccumulator) { //
    // @TODO
    }
}
