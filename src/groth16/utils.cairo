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
struct G16CircuitSetup {
    alpha_beta: Fq12,
    gamma: FixedG2Precompute,
    delta: FixedG2Precompute,
}

#[derive(Drop, Serde)]
struct FixedG2Precompute {
    lines: Array<LineFn>,
    point: AffineG2,
    neg: AffineG2,
}

fn process_input_constraints<T, +ICProcess<T>, +Drop<T>>(start_pt: G1, ic: T) -> G1 {
    // println!("\nstart_pt = g1({},{})", start_pt.x, start_pt.y);
    start_pt.add(ic.process_inputs_and_ic())
}

trait ICProcess<T> {
    fn process_inputs_and_ic(self: T) -> G1;
}

impl IC1Input of ICProcess<(G1, u256)> {
    #[inline(always)]
    fn process_inputs_and_ic(self: (G1, u256)) -> G1 {
        let (ic, input) = self;
        ic.multiply(input)
    }
}

impl IC2Inputs of ICProcess<((G1, G1), (u256, u256))> {
    #[inline(always)]
    fn process_inputs_and_ic(self: ((G1, G1), (u256, u256))) -> G1 {
        let ((ic0, ic1), (in0, in1)) = self;
        ic0.multiply(in0) //
        .add(ic1.multiply(in1))
    }
}

impl IC3Inputs of ICProcess<((G1, G1, G1), (u256, u256, u256))> {
    #[inline(always)]
    fn process_inputs_and_ic(self: ((G1, G1, G1), (u256, u256, u256))) -> G1 {
        let ((ic0, ic1, ic2), (in0, in1, in2)) = self;

        ic0.multiply(in0) //
        .add(ic1.multiply(in1)) //
        .add(ic2.multiply(in2))
    }
}

impl IC4Inputs of ICProcess<((G1, G1, G1, G1), (u256, u256, u256, u256))> {
    #[inline(always)]
    fn process_inputs_and_ic(self: ((G1, G1, G1, G1), (u256, u256, u256, u256))) -> G1 {
        let ((ic0, ic1, ic2, ic3), (in0, in1, in2, in3)) = self;

        ic0
            .multiply(in0) //
            .add(ic1.multiply(in1)) //
            .add(ic2.multiply(in2)) //
            .add(ic3.multiply(in3))
    }
}

impl ICArrayInputs of ICProcess<(Array<G1>, Array<u256>)> {
    fn process_inputs_and_ic(self: (Array<G1>, Array<u256>)) -> G1 {
        let (ic_arr, in_arr) = self;
        let len = ic_arr.len();
        assert(len == in_arr.len(), '');

        let mut k = ic_arr[0].multiply(*in_arr[0]);
        let mut i = 1;

        // Computes and returns k
        loop {
            k = k.add(ic_arr[i].multiply(*in_arr[i]));
            i += 1;
            if i == len {
                break k;
            }
        }
    }
}
