use bn::fields::fq_sparse::FqSparseTrait;
use bn::fields::{fq12, fq2, Fq12, FqOps};
use bn::groth16::utils::{ICProcess, G16CircuitSetup, PPrecompute};
use bn::groth16::utils::{Groth16MillerG1, Groth16MillerG2, PPrecomputeX3, F034, F01234, LineResult};
use bn::pairing::optimal_ate_utils::{p_precompute, line_fn_at_p, LineFn};

#[generate_trait]
impl LineResult01234 of LineResult01234Trait {
    #[inline(always)]
    fn as_01234(self: LineResult, field_nz: NonZero<u256>) -> F01234 {
        let (l1, l2) = self;
        l1.mul_034_by_034(l2, field_nz)
    }
}

#[derive(Drop, Serde)]
struct LinesArray {
    gamma: Array<LineFn>,
    delta: Array<LineFn>,
}

#[inline(always)]
fn line_fn_from_u256(slope_c0: u256, slope_c1: u256, c_c0: u256, c_c1: u256) -> LineFn {
    LineFn { slope: fq2(slope_c0, slope_c1), c: fq2(c_c0, c_c1), }
}

#[inline(always)]
fn fq12_034_034_034(ref f: Fq12, l1: F034, l2: F034, l3: F034, field_nz: NonZero<u256>) {
    let tmp = l1.mul_034_by_034(l2, field_nz).mul_01234_034(l3, field_nz);
    f = f.mul(tmp);
}

trait StepLinesTrait<T> {
    fn with_fxd_pt_line(
        self: @T, ppc: @PPrecomputeX3, ref acc: Groth16MillerG2, step: u32, field_nz: NonZero<u256>
    ) -> LineResult;
    fn with_fxd_pt_lines(
        self: @T, ppc: @PPrecomputeX3, ref acc: Groth16MillerG2, step: u32, field_nz: NonZero<u256>
    ) -> (LineResult, LineResult);
    fn lines_helper(
        self: @T, lines: (LineFn, LineFn), p_prec: @PPrecompute, field_nz: NonZero<u256>
    ) -> LineResult;
}

trait StepLinesGet<T> {
    fn get_gamma_line(self: @T, step: u32, line_index: u32) -> LineFn;
    fn get_delta_line(self: @T, step: u32, line_index: u32) -> LineFn;
    fn get_gamma_lines(self: @T, step: u32, line_index: u32) -> (LineFn, LineFn);
    fn get_delta_lines(self: @T, step: u32, line_index: u32) -> (LineFn, LineFn);
}

trait StepLinesSet<T> {
    fn set_gamma_line(ref self: T, step: u32, line: LineFn);
    fn set_delta_line(ref self: T, step: u32, line: LineFn);
    fn set_gamma_lines(ref self: T, step: u32, lines: (LineFn, LineFn));
    fn set_delta_lines(ref self: T, step: u32, lines: (LineFn, LineFn));
}

impl Groth16PrecomputedStep<T, +StepLinesGet<T>> of StepLinesTrait<T> {
    // reimplementation of step_double for both gamma and delta at once
    // but instead of G2 point doublings, uses precomputed slope and const
    fn with_fxd_pt_line(
        self: @T, ppc: @PPrecomputeX3, ref acc: Groth16MillerG2, step: u32, field_nz: NonZero<u256>
    ) -> LineResult {
        let line_index = acc.line_count;
        let (_, c_ppc, k_ppc) = ppc;
        acc.line_count = acc.line_count + 1;
        // get line functions and multiply with p_precomputes
        (
            line_fn_at_p(self.get_gamma_line(step, line_index), k_ppc),
            line_fn_at_p(self.get_delta_line(step, line_index), c_ppc)
        )
    }

    // reimplementation of step_dbl_add for both gamma and delta at once
    // but instead of G2 point doublings, uses precomputed slope and const
    fn with_fxd_pt_lines(
        self: @T, ppc: @PPrecomputeX3, ref acc: Groth16MillerG2, step: u32, field_nz: NonZero<u256>
    ) -> (LineResult, LineResult) { //
        let line_index = acc.line_count;
        let (_, c_p, k_p) = ppc;
        acc.line_count = acc.line_count + 2;
        (
            // get line functions and multiply with p_precomputes
            self.lines_helper(self.get_gamma_lines(step, line_index), k_p, field_nz),
            self.lines_helper(self.get_delta_lines(step, line_index), c_p, field_nz)
        )
    }

    #[inline(always)]
    fn lines_helper(
        self: @T, lines: (LineFn, LineFn), p_prec: @PPrecompute, field_nz: NonZero<u256>
    ) -> LineResult {
        let (lf1, lf2) = lines;
        // line_fn_at_p(lf1, p_prec).mul_034_by_034(line_fn_at_p(lf2, p_prec), field_nz)
        (line_fn_at_p(lf1, p_prec), line_fn_at_p(lf2, p_prec))
    }
}

impl LinesArrayGet of StepLinesGet<LinesArray> {
    fn get_gamma_line(self: @LinesArray, step: u32, line_index: u32) -> LineFn {
        // let l1: LineFn = *self.gamma[line_index];
        // println!("Get {}.{} {}", step, line_index, l1.slope.c0.c0.low);
        *self.gamma[line_index]
    }
    fn get_delta_line(self: @LinesArray, step: u32, line_index: u32) -> LineFn {
        *self.delta[line_index]
    }
    fn get_gamma_lines(self: @LinesArray, step: u32, line_index: u32) -> (LineFn, LineFn) {
        // let l1: LineFn = *self.gamma[line_index + 1];
        // println!("Get {}.{} {}", step, line_index, l1.slope.c0.c0.low);
        (*self.gamma[line_index], *self.gamma[line_index + 1])
    }
    fn get_delta_lines(self: @LinesArray, step: u32, line_index: u32) -> (LineFn, LineFn) {
        (*self.delta[line_index], *self.delta[line_index + 1])
    }
}

impl LinesArraySet of StepLinesSet<LinesArray> {
    fn set_gamma_line(ref self: LinesArray, step: u32, line: LineFn) {
        // println!("Set {}.{} {}", step, self.gamma.len(), line.slope.c0.c0.low);
        self.gamma.append(line);
    }
    fn set_delta_line(ref self: LinesArray, step: u32, line: LineFn) {
        self.delta.append(line);
    }
    fn set_gamma_lines(ref self: LinesArray, step: u32, lines: (LineFn, LineFn)) {
        let (l1, l2) = lines;
        // println!("Set {}.{} {}", step, self.gamma.len(), l2.slope.c0.c0.low);
        self.gamma.append(l1);
        self.gamma.append(l2);
    }
    fn set_delta_lines(ref self: LinesArray, step: u32, lines: (LineFn, LineFn)) {
        let (l1, l2) = lines;
        self.delta.append(l1);
        self.delta.append(l2);
    }
}
