use pairing::{LineFn, LinesArrays, LinesArrayGet, FixedPointLinesTrait};
use pairing::{PairingUtilsTrait, PiMapping};
use pairing::{PPrecompute, Groth16PreCompute, Groth16MillerG1, Groth16MillerG2,};
use fq_types::{Fq2, Fq12Direct, FieldOps, FieldUtils, Fq2Ops};
use ec_groups::{Affine, ECOperations};
use bn_ate_loop::MillerRunnerTrait;
use schwartz_zippel::SchZipSteps;
pub use pairing::{MillerAcc, MillerRunner, LnArrays, FqD12,};

type Acc<TFq> = MillerAcc<TFq>;


pub impl Miller_Bn254<
    TCurve,
    TFq,
    TSZ,
    +FieldOps<TCurve, TFq>,
    +FieldUtils<TCurve, TFq>,
    +ECOperations<TCurve, TFq>,
    +ECOperations<TCurve, Fq2<TFq>>,
    impl FxdPtLines: FixedPointLinesTrait<LnArrays<TFq>, TCurve, TFq>,
    +SchZipSteps<TCurve, TSZ, TFq, FqD12<TFq>>,
    +Drop<TSZ>,
    +Copy<TFq>,
    +Drop<TFq>,
> of MillerRunnerTrait<TCurve, MillerRunner<TFq, TSZ, Acc<TFq>>> {
    // first and second step, O and N
    fn miller_bit_1_2(
        ref self: TCurve, ref runner: MillerRunner<TFq, TSZ, Acc<TFq>>, i: (u32, u32)
    ) { //
        self.sz_init(ref runner.schzip, ref runner.acc.f);
        let (i1, i2) = i;
        self.miller_bit_o(ref runner, i1);
        self.miller_bit_n(ref runner, i2);
    }

    // 0 bit
    fn miller_bit_o(ref self: TCurve, ref runner: MillerRunner<TFq, TSZ, Acc<TFq>>, i: u32) { //
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;

        let _acc = ppc.pi_a;

        let l1 = self.step_double(ref runner.acc.g2.pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_line(ref self, ppc, ref runner.acc.line_index);
        self.sz_zero_bit(ref runner.schzip, ref runner.acc.f, (l1, l2, l3));
    }

    // 1 bit
    fn miller_bit_p(ref self: TCurve, ref runner: MillerRunner<TFq, TSZ, Acc<TFq>>, i: u32) {
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let pi_b = runner.g16.q.pi_b;

        let l1 = self.step_dbl_add(ref runner.acc.g2.pi_b, *pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref runner.acc.line_index);
        self.sz_nz_bit(ref runner.schzip, ref runner.acc.f, (l1, l2, l3), *g16.residue_witness_inv);
    }

    // -1 bit
    fn miller_bit_n(ref self: TCurve, ref runner: MillerRunner<TFq, TSZ, Acc<TFq>>, i: u32) { //
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;
        // use neg q
        let pi_b = runner.g16.neg_q.pi_b;

        let l1 = self.step_dbl_add(ref runner.acc.g2.pi_b, *pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref runner.acc.line_index);
        self.sz_nz_bit(ref runner.schzip, ref runner.acc.f, (l1, l2, l3), *g16.residue_witness);
    }

    // last step
    fn miller_last(ref self: TCurve, ref runner: MillerRunner<TFq, TSZ, Acc<TFq>>) { //
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let pi_b = runner.g16.q.pi_b;

        let l1 = self
            .correction_step(ref runner.acc.g2.pi_b, *pi_b, runner.g16.pi_mapping, ppc.pi_a);

        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref runner.acc.line_index);
        self.sz_last_step(ref runner.schzip, ref runner.acc.f, (l1, l2, l3));
    }
}
