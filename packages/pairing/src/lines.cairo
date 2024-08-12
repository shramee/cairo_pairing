use pairing::{
    Groth16MillerG1, Groth16MillerG2, PPrecompute, PairingUtilsTrait,
    {LineFn, LineResult, LnFn, LinesArrays}
};
use fq_types::{Fq2, F12S034};

pub trait StepLinesGet<T, TFq> {
    fn get_gamma_line(self: @T, line_index: u32) -> LineFn<Fq2<TFq>>;
    fn get_delta_line(self: @T, line_index: u32) -> LineFn<Fq2<TFq>>;
    fn get_gamma_lines(self: @T, line_index: u32) -> (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>);
    fn get_delta_lines(self: @T, line_index: u32) -> (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>);
}

pub impl LinesArrayGet<
    TFq, +Copy<TFq>, +Drop<TFq>
> of StepLinesGet<LinesArrays<Array<LineFn<Fq2<TFq>>>>, TFq> {
    fn get_gamma_line(
        self: @LinesArrays<Array<LineFn<Fq2<TFq>>>>, line_index: u32
    ) -> LineFn<Fq2<TFq>> {
        *self.gamma[line_index]
    }
    fn get_delta_line(
        self: @LinesArrays<Array<LineFn<Fq2<TFq>>>>, line_index: u32
    ) -> LineFn<Fq2<TFq>> {
        *self.delta[line_index]
    }
    fn get_gamma_lines(
        self: @LinesArrays<Array<LineFn<Fq2<TFq>>>>, line_index: u32
    ) -> (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>) {
        (*self.gamma[line_index], *self.gamma[line_index + 1])
    }
    fn get_delta_lines(
        self: @LinesArrays<Array<LineFn<Fq2<TFq>>>>, line_index: u32
    ) -> (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>) {
        (*self.delta[line_index], *self.delta[line_index + 1])
    }
}

pub trait FixedPointLinesTrait<T, TCurve, TFq> {
    fn with_fxd_pt_line(
        self: @T, ref curve: TCurve, ppc: @Groth16MillerG1<PPrecompute<TFq>>, ref line_count: u32
    ) -> LineResult<TFq>;
    fn with_fxd_pt_lines(
        self: @T, ref curve: TCurve, ppc: @Groth16MillerG1<PPrecompute<TFq>>, ref line_count: u32
    ) -> (LineResult<TFq>, LineResult<TFq>);
    fn lines_helper(
        self: @T,
        ref curve: TCurve,
        lines: (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>),
        p_prec: @PPrecompute<TFq>
    ) -> LineResult<TFq>;
}

pub impl FixedPointLines<
    T,
    TCurve,
    TFq,
    +StepLinesGet<T, TFq>,
    +PairingUtilsTrait<TCurve, TFq>,
    +Copy<TFq>,
    +Drop<TFq>,
    +Drop<TCurve>
> of FixedPointLinesTrait<T, TCurve, TFq> {
    // reimplementation of step_double for both gamma and delta at once
    // but instead of G2 point doublings, uses precomputed slope and const
    fn with_fxd_pt_line(
        self: @T, ref curve: TCurve, ppc: @Groth16MillerG1<PPrecompute<TFq>>, ref line_count: u32
    ) -> LineResult<TFq> {
        let line_index = line_count;
        line_count = line_count + 1;
        let a = curve.line_fn_at_p(self.get_gamma_line(line_index), ppc.k);
        // get line functions and multiply with p_precomputes
        (a, curve.line_fn_at_p(self.get_delta_line(line_index), ppc.pi_c))
    }

    // reimplementation of step_dbl_add for both gamma and delta at once
    // but instead of G2 point doublings, uses precomputed slope and const
    fn with_fxd_pt_lines(
        self: @T, ref curve: TCurve, ppc: @Groth16MillerG1<PPrecompute<TFq>>, ref line_count: u32
    ) -> (LineResult<TFq>, LineResult<TFq>) { //
        let line_index = line_count;
        line_count = line_count + 2;
        (
            // get line functions and multiply with p_precomputes
            self.lines_helper(ref curve, self.get_gamma_lines(line_index), ppc.k),
            self.lines_helper(ref curve, self.get_delta_lines(line_index), ppc.pi_c)
        )
    }

    #[inline(always)]
    fn lines_helper(
        self: @T,
        ref curve: TCurve,
        lines: (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>),
        p_prec: @PPrecompute<TFq>
    ) -> LineResult<TFq> {
        let (lf1, lf2) = lines;
        (curve.line_fn_at_p(lf1, p_prec), curve.line_fn_at_p(lf2, p_prec))
    }
}

