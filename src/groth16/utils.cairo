use core::array::ArrayTrait;
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::{FieldOps, FieldShortcuts};
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
use pairing::optimal_ate_utils::{LineFn};

type G1 = AffineG1;

#[derive(Drop, Serde)]
struct G16CircuitSetup<T> {
    alpha_beta: Fq12,
    gamma: AffineG2,
    gamma_neg: AffineG2,
    delta: AffineG2,
    delta_neg: AffineG2,
    lines: T,
    ic: (AffineG1, Array<AffineG1>),
}

#[derive(Drop, Serde)]
struct LinesArray {
    gamma: Array<LineFn>,
    delta: Array<LineFn>,
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

trait ICProcess<T> {
    fn process_inputs_and_ic(self: T, start_pt: G1) -> G1;
}

impl ICArrayInput of ICProcess<(Array<G1>, Array<u256>)> {
    fn process_inputs_and_ic(self: (Array<G1>, Array<u256>), mut start_pt: G1) -> G1 {
        let (mut ic_arr, mut in_arr) = self;

        assert(in_arr.len() == ic_arr.len(), 'incorrect input length');
        if in_arr.len() == 0 {
            return start_pt;
        }
        // let ic = ic0.multiply(in0);
        loop {
            match ic_arr.pop_front() {
                Option::Some(point) => { //
                    match in_arr.pop_front() {
                        Option::Some(in) => { start_pt = start_pt.add(point.multiply(in)); },
                        Option::None => {} // This wouldn't happen
                    }
                },
                Option::None => { break; }
            }
        };
        start_pt // mutable start_pt has all the ICs added
    }
}

impl IC1Input of ICProcess<(G1, u256)> {
    #[inline(always)]
    fn process_inputs_and_ic(self: (G1, u256), start_pt: G1) -> G1 {
        let (ic, input) = self;
        start_pt.add(ic.multiply(input))
    }
}

impl IC2Inputs of ICProcess<((G1, G1), (u256, u256))> {
    #[inline(always)]
    fn process_inputs_and_ic(self: ((G1, G1), (u256, u256)), start_pt: G1) -> G1 {
        let ((ic0, ic1), (in0, in1)) = self;
        start_pt //
        .add(ic0.multiply(in0)) //
        .add(ic1.multiply(in1))
    }
}

impl IC3Inputs of ICProcess<((G1, G1, G1), (u256, u256, u256))> {
    #[inline(always)]
    fn process_inputs_and_ic(self: ((G1, G1, G1), (u256, u256, u256)), start_pt: G1) -> G1 {
        let ((ic0, ic1, ic2), (in0, in1, in2)) = self;

        start_pt //
        .add(ic0.multiply(in0)) //
        .add(ic1.multiply(in1)) //
        .add(ic2.multiply(in2))
    }
}

impl IC4Inputs of ICProcess<((G1, G1, G1, G1), (u256, u256, u256, u256))> {
    #[inline(always)]
    fn process_inputs_and_ic(
        self: ((G1, G1, G1, G1), (u256, u256, u256, u256)), start_pt: G1
    ) -> G1 {
        let ((ic0, ic1, ic2, ic3), (in0, in1, in2, in3)) = self;

        start_pt //
            .add(ic0.multiply(in0)) //
            .add(ic1.multiply(in1)) //
            .add(ic2.multiply(in2)) //
            .add(ic3.multiply(in3))
    }
}

