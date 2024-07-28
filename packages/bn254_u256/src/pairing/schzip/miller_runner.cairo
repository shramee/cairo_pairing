use pairing::{LineFn, LinesArrayGet, FixedPointLines};
use pairing::{PairingUtils, PiMapping};
use bn254_u256::{
    {Fq, Fq2, fq2, FqD12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve as Curve,},
    print::{FqDisplay, G2Display, G1Display}, pi_mapping,
    pairing::utils::{
        LnArrays, LnFn,
        {SZCommitment, SZCommitmentAccumulator, SZPrecompute, SZAccumulator as Accumulator}
    }
};
use bn_ate_loop::MillerRunner;
use schwartz_zippel::SchZipSteps;

type Precompute<TSchZip> = SZPrecompute<LnArrays, TSchZip>;

// TODO: +SchZipSteps<Curve, TCommitment, Fq>

pub impl Miller_Bn254_U256<
    TSchZip, +SchZipSteps<Curve, TSchZip, SZCommitmentAccumulator, Fq, FqD12>
> of MillerRunner<Curve, Precompute<TSchZip>, Accumulator> {
    // first and second step, O and N
    fn miller_bit_1_2(
        ref self: Curve, runner: @Precompute<TSchZip>, i: (u32, u32), ref acc: Accumulator
    ) { //
        self.sz_init(runner.schzip, ref acc.schzip, ref acc.f);
        let (i1, i2) = i;
        self.miller_bit_o(runner, i1, ref acc);
        self.miller_bit_n(runner, i2, ref acc);
    }

    // 0 bit
    fn miller_bit_o(
        ref self: Curve, runner: @Precompute<TSchZip>, i: u32, ref acc: Accumulator
    ) { //
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;

        let l1 = self.step_double(ref acc.g2.pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_line(ref self, g16.ppc, ref acc.line_index);
        self.sz_zero_bit(runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3));
    }

    // 1 bit
    fn miller_bit_p(ref self: Curve, runner: @Precompute<TSchZip>, i: u32, ref acc: Accumulator) {
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let pi_b = runner.g16.q.pi_b;

        let l1 = self.step_dbl_add(ref acc.g2.pi_b, *pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref acc.line_index);
        self
            .sz_nz_bit(
                runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3), *g16.residue_witness_inv
            );
    }

    // -1 bit
    fn miller_bit_n(
        ref self: Curve, runner: @Precompute<TSchZip>, i: u32, ref acc: Accumulator
    ) { //
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;
        // use neg q
        let pi_b = runner.g16.neg_q.pi_b;

        let l1 = self.step_dbl_add(ref acc.g2.pi_b, *pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref acc.line_index);
        self
            .sz_nz_bit(
                runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3), *g16.residue_witness
            );
    }

    // last step
    fn miller_last(ref self: Curve, runner: @Precompute<TSchZip>, ref acc: Accumulator) { //
        core::internal::revoke_ap_tracking();
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let pi_b = runner.g16.q.pi_b;

        let l1 = self.correction_step(ref acc.g2.pi_b, *pi_b, pi_mapping(), ppc.pi_a);

        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref acc.line_index);
        self.sz_last_step(runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3));
    }
}
