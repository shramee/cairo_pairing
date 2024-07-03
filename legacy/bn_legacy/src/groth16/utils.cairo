use core::array::ArrayTrait;
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::{FieldOps, FieldShortcuts};
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, fq2, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use pairing::optimal_ate_utils::{LineFn};
use bn::groth16::utils_line::{
    StepLinesTrait, Groth16PrecomputedStep, line_fn_from_u256, fq12_034_034_034
};
use bn::groth16::utils_line::{LinesArray, StepLinesGet, StepLinesSet, LinesArrayGet, LinesArraySet};

type G1 = AffineG1;
type PPrecomputeX3 = (PPrecompute, PPrecompute, PPrecompute);

type F034 = Fq12Sparse034;
type F01234 = Fq12Sparse01234;
type LineResult = (F034, F034);

#[derive(Copy, Drop)]
struct Groth16MillerG1 { // Points in G1
    pi_a: AffineG1,
    pi_c: AffineG1,
    k: AffineG1,
}

#[derive(Copy, Drop)]
struct Groth16MillerG2 { // Points in G2
    pi_b: AffineG2,
    delta: AffineG2,
    gamma: AffineG2,
    line_count: u32, // Holds index of accessed line lambda and y intercept
}

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

