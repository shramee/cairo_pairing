use ec_groups::ECOperations;
use pairing::{LineFn, LinesArrays, LinesArrayGet};
use pairing::{PPrecompute, Groth16PreCompute, Groth16MillerG1, Groth16MillerG2};
use bn254_u256::{Fq, Fq2, Fq12, FqD12, Bn254FqOps, PtG1, PtG2, AffineOpsBn};
use bn254_u256::{Bn254U256Curve};

#[derive(Drop, Serde)]
pub struct SZCommitment {
    pub remainders: Array<FqD12>,
    pub qrlc: Array<Fq>,
    pub rlc_fiat_shamir: Array<Fq>,
    pub fiat_shamir_powers: Array<Fq>,
    pub p12_x: Fq,
}

#[derive(Drop)]
pub struct SZMillerRunner<TLines, TCommitment> {
    pub g16: @Groth16PreCompute<
        Groth16MillerG1<PtG1>,
        Groth16MillerG1<PPrecompute<Fq>>,
        Groth16MillerG2<PtG2>,
        TLines,
        FqD12
    >,
    pub schzip: @TCommitment,
    pub acc: SZAccumulator,
}

#[derive(Drop, Serde)]
pub struct SZCommitmentAccumulator {
    // index of equation (remainder) being processed, used for rlc
    pub index: u32,
    // accumulation of rhs and lhs to compare against qrlc
    pub rhs_lhs: Fq,
    // remainder cache for next equation
    pub rem_cache: Fq,
}

#[derive(Drop)]
pub struct SZAccumulator {
    pub f: FqD12,
    pub g2: Groth16MillerG2<PtG2>,
    pub line_index: u32,
    pub schzip: SZCommitmentAccumulator,
}

pub type LnFn = LineFn<Fq2>;
pub type LnArrays = LinesArrays<Array<LnFn>>;

// Generic Input constraints processing
pub trait ICProcess<TCurve, TIC, TInputs, TG1> {
    fn process_inputs_and_ic(ref self: TCurve, points: TIC, inputs: TInputs) -> TG1;
}

// Input constraints processing for array of IC paramters
pub impl ICArrayInput of ICProcess<Bn254U256Curve, Array<PtG1>, Array<u256>, PtG1> {
    fn process_inputs_and_ic(
        ref self: Bn254U256Curve, mut points: Array<PtG1>, mut inputs: Array<u256>
    ) -> PtG1 {
        // First element is the initial point
        let mut ic_point = points.pop_front().unwrap();

        assert(inputs.len() == points.len(), 'incorrect input length');

        if inputs.len() == 0 {
            return ic_point;
        }
        loop {
            match points.pop_front() {
                Option::Some(point) => { //
                    match inputs.pop_front() {
                        Option::Some(in) => {
                            ic_point = self.pt_add(ic_point, self.pt_mul(point, in));
                        },
                        Option::None => {} // This wouldn't happen
                    }
                },
                Option::None => { break ic_point; }
            }
        }
    }
}
