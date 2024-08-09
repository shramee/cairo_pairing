use pairing::{LineFn, LinesArrays, LinesArrayGet, FixedPointLines};
use pairing::{PairingUtils, PiMapping};
use fq_types::{Fq2, Fq12Direct,};
use bn254_u256::{
    {Fq, Bn254U256Curve as Curve,}, pairing::utils::{SZCommitmentAccumulator, SZMillerRunner}
};
use bn_ate_loop::MillerRunner;
use schwartz_zippel::SchZipSteps;

pub type LnFn<T> = LineFn<Fq2<T>>;
pub type LnArrays<T> = LinesArrays<Array<LnFn<T>>>;

type FqD12<T> = Fq12Direct<T>;

type PreCompute<T, TSchZip> = SZMillerRunner<LnArrays<T>, TSchZip>;

pub impl Miller_Bn254<
    TSchZip, +SchZipSteps<Curve, TSchZip, SZCommitmentAccumulator, Fq, FqD12<Fq>>
> of MillerRunner<Curve, PreCompute<Fq, TSchZip>> {
    // first and second step, O and N
    fn miller_bit_1_2(ref self: Curve, ref runner: PreCompute<Fq, TSchZip>, i: (u32, u32)) { //
        self.sz_init(runner.schzip, ref runner.acc.schzip, ref runner.acc.f);
        let (i1, i2) = i;
        self.miller_bit_o(ref runner, i1);
        self.miller_bit_n(ref runner, i2);
    }

    // 0 bit
    fn miller_bit_o(ref self: Curve, ref runner: PreCompute<Fq, TSchZip>, i: u32) { //
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;

        let l1 = self.step_double(ref runner.acc.g2.pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_line(ref self, g16.ppc, ref runner.acc.line_index);
        self.sz_zero_bit(ref runner.schzip, ref runner.acc.f, (l1, l2, l3));
    }

    // 1 bit
    fn miller_bit_p(ref self: Curve, ref runner: PreCompute<Fq, TSchZip>, i: u32) {
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let pi_b = runner.g16.q.pi_b;

        let l1 = self.step_dbl_add(ref runner.acc.g2.pi_b, *pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref runner.acc.line_index);
        self.sz_nz_bit(ref runner.schzip, ref runner.acc.f, (l1, l2, l3), *g16.residue_witness_inv);
    }

    // -1 bit
    fn miller_bit_n(ref self: Curve, ref runner: PreCompute<Fq, TSchZip>, i: u32) { //
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
    fn miller_last(ref self: Curve, ref runner: PreCompute<Fq, TSchZip>) { //
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
