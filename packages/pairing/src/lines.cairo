use pairing::{Groth16MillerG1, Groth16MillerG2, PPrecompute, PairingUtilsTrait};
use fq_types::{Fq2, F12S034};

#[derive(Copy, Drop, Serde)]
pub struct LineFn<TFq> {
    pub slope: TFq,
    pub c: TFq,
}

type LineResult<T> = (F12S034<Fq2<T>>, F12S034<Fq2<T>>);
type LnFn<T> = LineFn<Fq2<T>>;

pub trait StepLinesGet<T, TFq> {
    fn get_gamma_line(self: @T, line_index: u32) -> LineFn<Fq2<TFq>>;
    fn get_delta_line(self: @T, line_index: u32) -> LineFn<Fq2<TFq>>;
    fn get_gamma_lines(self: @T, line_index: u32) -> (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>);
    fn get_delta_lines(self: @T, line_index: u32) -> (LineFn<Fq2<TFq>>, LineFn<Fq2<TFq>>);
}

#[derive(Drop, Serde)]
pub struct LinesArrays<TLinesArray> {
    gamma: TLinesArray,
    delta: TLinesArray,
}

pub impl LinesArrayGet<
    TFq, +Copy<TFq>, +Drop<TFq>
> of StepLinesGet<LinesArrays<Array<LineFn<Fq2<TFq>>>>, TFq> {
    fn get_gamma_line(
        self: @LinesArrays<Array<LineFn<Fq2<TFq>>>>, line_index: u32
    ) -> LineFn<Fq2<TFq>> {
        // let l1: LineFn = *self.gamma[line_index];
        // println!("Get {}.{} {}", step, line_index, l1.slope.c0.c0.low);
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
