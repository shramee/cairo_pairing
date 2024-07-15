use pairing::{LineFn, LinesArrayGet, FixedPointLines};
use pairing::{PairingUtils};
use bn254_u256::{Fq, Fq2, Fq12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve as Curve};
use bn254_u256::pairing::utils::{
    LnArrays, SZCommitment, SZPreCompute, SZAccumulator as Accumulator, LnFn
};
use bn_ate_loop::MillerRunner;
use schwartz_zippel::SchZipSteps;

type PreCompute<TSchZip> = SZPreCompute<LnArrays, TSchZip>;

// TODO: +SchZipSteps<Curve, TCommitment, Fq>

pub impl Miller_Bn254_U256<
    TSchZip, +SchZipSteps<Curve, TSchZip, (u32, Fq), Fq>
> of MillerRunner<Curve, PreCompute<TSchZip>, Accumulator> {
    // first and second step, O and N
    fn miller_bit_1_2(
        ref self: Curve, runner: @PreCompute<TSchZip>, i: (u32, u32), ref acc: Accumulator
    ) { //
        let (i1, i2) = i;
        // runner.schzip
        self.miller_bit_o(runner, i1, ref acc);
        self.miller_bit_n(runner, i2, ref acc);
    }

    // 0 bit
    fn miller_bit_o(
        ref self: Curve, runner: @PreCompute<TSchZip>, i: u32, ref acc: Accumulator
    ) { //
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let l1 = self.step_double(ref acc.g2.pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_line(ref self, g16.ppc, ref acc.line_index);
        self.sz_zero_bit(runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3));
    }

    // 1 bit
    fn miller_bit_p(
        ref self: Curve, runner: @PreCompute<TSchZip>, i: u32, ref acc: Accumulator
    ) { //
    // @TODO
    }

    // -1 bit
    fn miller_bit_n(
        ref self: Curve, runner: @PreCompute<TSchZip>, i: u32, ref acc: Accumulator
    ) { //
    // @TODO
    }

    // last step
    fn miller_last(ref self: Curve, runner: @PreCompute<TSchZip>, ref acc: Accumulator) { //
    // @TODO
    }
}
