use ec_groups::{LineFn, LinesArray, LinesArrayGet};
use bn254_u256::{Fq, Fq2, Fq12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve as Curve};
use bn254_u256::pairing::utils::{
    LnArray, SZCommitment, SZPreCompute, SZAccumulator as Accumulator, LnFn
};
use bn_ate_loop::MillerRunner;
use schwartz_zippel::SchZipSteps;

type PreCompute = SZPreCompute<LnArray, SZCommitment>;

// TODO: +SchZipSteps<Curve, TCommitment, Fq>

pub impl Miller_Bn254_U256 of MillerRunner<Curve, PreCompute, Accumulator> {
    // first and second step, O and N
    fn miller_bit_1_2(
        ref self: Curve, runner: @PreCompute, i: (u32, u32), ref acc: Accumulator
    ) { //
        let (i1, i2) = i;
        self.miller_bit_o(runner, i1, ref acc);
        self.miller_bit_n(runner, i2, ref acc);
    }

    // 0 bit
    fn miller_bit_o(ref self: Curve, runner: @PreCompute, i: u32, ref acc: Accumulator) { //
    // @TODO
    }

    // 1 bit
    fn miller_bit_p(ref self: Curve, runner: @PreCompute, i: u32, ref acc: Accumulator) { //
    // @TODO
    }

    // -1 bit
    fn miller_bit_n(ref self: Curve, runner: @PreCompute, i: u32, ref acc: Accumulator) { //
    // @TODO
    }

    // last step
    fn miller_last(ref self: Curve, runner: @PreCompute, ref acc: Accumulator) { //
    // @TODO
    }
}
// Trait has no implementation in context: MillerRunner<Bn254U256Curve, SZPreCompute<LinesArray<LineFn<Fq>>, SZCommitment>, SZAccumulator>


