use ec_groups::ECOperations;
use bn_ate_loop::{PPrecompute};
use bn254_u256::{Fq, Fq2, Bn254FqOps, PtG1, PtG2, AffineOpsBn};
use bn254_u256::Bn254U256Curve;

// Generic Input constraints processing
trait ICProcess<TCurve, TIC, TInputs, TG1> {
    fn process_inputs_and_ic(ref self: TIC, inputs: TInputs, ref curve: TCurve) -> TG1;
}

// Input constraints processing for array of IC paramters
impl ICArrayInput of ICProcess<Bn254U256Curve, Array<PtG1>, Array<u256>, PtG1> {
    fn process_inputs_and_ic(
        ref self: Array<PtG1>, mut inputs: Array<u256>, ref curve: Bn254U256Curve
    ) -> PtG1 {
        // First element is the initial point
        let mut ic_point = self.pop_front().unwrap();

        assert(inputs.len() == self.len(), 'incorrect input length');

        if inputs.len() == 0 {
            return ic_point;
        }

        loop {
            match self.pop_front() {
                Option::Some(point) => { //
                    match inputs.pop_front() {
                        Option::Some(in) => {
                            ic_point = curve.pt_add(ic_point, curve.pt_mul(point, in));
                        },
                        Option::None => {} // This wouldn't happen
                    }
                },
                Option::None => { break ic_point; }
            }
        }
    }
}
