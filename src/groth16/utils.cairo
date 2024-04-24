use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::{FieldOps, FieldShortcuts};
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};

type G1 = AffineG1;

fn process_input_constraints<T, +ICProcess<T>, +Drop<T>>(start_pt: G1, ic: T) -> G1 {
    let k = g1(0, 1);

    let ic_point = ic.process_inputs_and_ic();

    let k = k.add(ic_point);

    k.add(start_pt)
}

trait ICProcess<T> {
    fn process_inputs_and_ic(self: T) -> G1;
}

impl IC1Input of ICProcess<(G1, u256)> {
    fn process_inputs_and_ic(self: (G1, u256)) -> G1 {
        let (ic, input) = self;
        ic.multiply(input)
    }
}
