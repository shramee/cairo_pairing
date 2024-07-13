#[derive(Copy, Drop, Serde)]
pub struct LineFn<TFq> {
    pub slope: TFq,
    pub c: TFq,
}

pub trait StepLinesGet<T, TLnFn> {
    fn get_gamma_line(self: @T, step: u32, line_index: u32) -> TLnFn;
    fn get_delta_line(self: @T, step: u32, line_index: u32) -> TLnFn;
    fn get_gamma_lines(self: @T, step: u32, line_index: u32) -> (TLnFn, TLnFn);
    fn get_delta_lines(self: @T, step: u32, line_index: u32) -> (TLnFn, TLnFn);
}

#[derive(Drop, Serde)]
pub struct LinesArrays<TLinesArray> {
    gamma: TLinesArray,
    delta: TLinesArray,
}

pub impl LinesArrayGet<
    TLnFn, +Copy<TLnFn>, +Drop<TLnFn>
> of StepLinesGet<LinesArrays<Array<TLnFn>>, TLnFn> {
    fn get_gamma_line(self: @LinesArrays<Array<TLnFn>>, step: u32, line_index: u32) -> TLnFn {
        // let l1: LineFn = *self.gamma[line_index];
        // println!("Get {}.{} {}", step, line_index, l1.slope.c0.c0.low);
        *self.gamma[line_index]
    }
    fn get_delta_line(self: @LinesArrays<Array<TLnFn>>, step: u32, line_index: u32) -> TLnFn {
        *self.delta[line_index]
    }
    fn get_gamma_lines(
        self: @LinesArrays<Array<TLnFn>>, step: u32, line_index: u32
    ) -> (TLnFn, TLnFn) {
        (*self.gamma[line_index], *self.gamma[line_index + 1])
    }
    fn get_delta_lines(
        self: @LinesArrays<Array<TLnFn>>, step: u32, line_index: u32
    ) -> (TLnFn, TLnFn) {
        (*self.delta[line_index], *self.delta[line_index + 1])
    }
}
