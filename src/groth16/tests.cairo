// test bn::groth16::tests::groth16_verify ... ok (gas usage est.: 1802616140)
// test bn::groth16::tests::test_alphabeta_miller ... ok (gas usage est.: 404856360)

use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
use pairing::optimal_ate_utils::LineFn;
use bn::groth16::utils::{LinesArray, LinesArrayGet, LinesArraySet, ICProcess, ICArrayInput};
use bn::groth16::verifier::{verify, verify_miller};
use bn::groth16::setup::{setup_precompute, StepLinesTrait, G16CircuitSetup};
use bn::groth16::fixture;
use core::fmt::{Display, Formatter, Error};
use core::hash::HashStateTrait;
use core::poseidon::{PoseidonImpl, HashStateImpl};
impl AffineG2Display of Display<AffineG2> {
    fn fmt(self: @AffineG2, ref f: Formatter) -> Result<(), Error> {
        write!(f, "\ng2({},{},{},{})", *self.x.c0, *self.x.c1, *self.y.c0, *self.y.c1)
    }
}

impl LineFnArrDisplay of Display<Array<LineFn>> {
    fn fmt(self: @Array<LineFn>, ref f: core::fmt::Formatter) -> Result<(), Error> {
        let mut i = 0;
        loop {
            let res = write!(
                f,
                "\nline_fn_from_u256({},{},{},{}),",
                *self.at(i).slope.c0,
                *self.at(i).slope.c1,
                *self.at(i).c.c0,
                *self.at(i).c.c1
            );
            i = i + 1;
            if i == self.len() {
                break res;
            }
        }
    }
}

#[test]
#[available_gas(20000000000)]
fn groth16_verify() {
    // Verification key parameters
    // let (_, _, gamma, delta, albe_miller, mut ic) = vk();
    let circuit_setup: G16CircuitSetup<LinesArray> = fixture::circuit_setup();

    // Proof parameters
    let (pi_a, pi_b, pi_c, pub_input, _) = fixture::proof();
    let (_, residue_witness, residue_witness_inv, cubic_scl) = fixture::residue_witness();

    let verified = verify(
        pi_a,
        pi_b,
        pi_c,
        array![pub_input],
        residue_witness,
        residue_witness_inv,
        cubic_scl,
        circuit_setup
    );

    assert(verified, 'verification failed');
}

#[test]
#[available_gas(20000000000)]
fn hash() {
    // Proof parameters
    let (pi_a, pi_b, pi_c, _, _) = fixture::proof();
    let mut hasher = core::poseidon::PoseidonImpl::new();
    hasher = hasher.update(pi_a.x.c0.low.into());
    hasher = hasher.update(pi_a.x.c0.high.into());
    hasher = hasher.update(pi_a.y.c0.low.into());
    hasher = hasher.update(pi_a.y.c0.high.into());

    hasher = hasher.update(pi_b.x.c0.c0.low.into());
    hasher = hasher.update(pi_b.x.c0.c0.high.into());
    hasher = hasher.update(pi_b.x.c1.c0.low.into());
    hasher = hasher.update(pi_b.x.c1.c0.high.into());
    hasher = hasher.update(pi_b.y.c0.c0.low.into());
    hasher = hasher.update(pi_b.y.c0.c0.high.into());
    hasher = hasher.update(pi_b.y.c1.c0.low.into());
    hasher = hasher.update(pi_b.y.c1.c0.high.into());

    hasher = hasher.update(pi_c.x.c0.low.into());
    hasher = hasher.update(pi_c.x.c0.high.into());
    hasher = hasher.update(pi_c.y.c0.low.into());
    hasher = hasher.update(pi_c.y.c0.high.into());

    let hash = hasher.finalize();

    println!("hash: {hash}");

    assert(true, 'verification failed');
}

#[test]
#[available_gas(20000000000)]
fn hash_big() {
    // Proof parameters
    let (pi_a, pi_b, pi_c, _, _) = fixture::proof();
    let mut hasher = core::poseidon::PoseidonImpl::new();
    hasher = hasher.update(pi_a.x.c0.low.into());
    hasher = hasher.update(pi_a.x.c0.high.into());

    hasher = hasher.update(pi_b.x.c0.c0.low.into());
    hasher = hasher.update(pi_b.x.c0.c0.high.into());
    hasher = hasher.update(pi_b.x.c1.c0.low.into());
    hasher = hasher.update(pi_b.x.c1.c0.high.into());
    hasher = hasher.update(pi_a.x.c0.low.into());
    hasher = hasher.update(pi_a.x.c0.high.into());
    hasher = hasher.update(pi_a.y.c0.low.into());
    hasher = hasher.update(pi_a.y.c0.high.into());

    hasher = hasher.update(pi_b.x.c0.c0.low.into());
    hasher = hasher.update(pi_b.x.c0.c0.high.into());
    hasher = hasher.update(pi_b.x.c1.c0.low.into());
    hasher = hasher.update(pi_b.x.c1.c0.high.into());
    hasher = hasher.update(pi_b.y.c0.c0.low.into());
    hasher = hasher.update(pi_b.y.c0.c0.high.into());
    hasher = hasher.update(pi_b.y.c1.c0.low.into());
    hasher = hasher.update(pi_b.y.c1.c0.high.into());

    hasher = hasher.update(pi_c.x.c0.low.into());
    hasher = hasher.update(pi_c.x.c0.high.into());
    hasher = hasher.update(pi_c.y.c0.low.into());
    hasher = hasher.update(pi_c.y.c0.high.into());
    hasher = hasher.update(pi_a.x.c0.low.into());
    hasher = hasher.update(pi_a.x.c0.high.into());
    hasher = hasher.update(pi_a.y.c0.low.into());
    hasher = hasher.update(pi_a.y.c0.high.into());

    hasher = hasher.update(pi_b.x.c0.c0.low.into());
    hasher = hasher.update(pi_b.x.c0.c0.high.into());
    hasher = hasher.update(pi_b.x.c1.c0.low.into());
    hasher = hasher.update(pi_b.x.c1.c0.high.into());
    hasher = hasher.update(pi_b.y.c0.c0.low.into());
    hasher = hasher.update(pi_b.y.c0.c0.high.into());
    hasher = hasher.update(pi_b.y.c1.c0.low.into());
    hasher = hasher.update(pi_b.y.c1.c0.high.into());

    hasher = hasher.update(pi_c.x.c0.low.into());
    hasher = hasher.update(pi_c.x.c0.high.into());
    hasher = hasher.update(pi_c.y.c0.low.into());
    hasher = hasher.update(pi_c.y.c0.high.into());

    hasher = hasher.update(pi_c.x.c0.low.into());
    hasher = hasher.update(pi_c.x.c0.high.into());

    let hash = hasher.finalize();

    println!("hash: {hash}");

    assert(true, 'verification failed');
}

#[test]
#[available_gas(20000000000)]
fn groth16_miller_loop() {
    // Verification key parameters
    // let (_, _, gamma, delta, albe_miller, mut ic) = vk();
    let circuit_setup: G16CircuitSetup<LinesArray> = fixture::circuit_setup();

    // Proof parameters
    let (pi_a, pi_b, pi_c, pub_input, _) = fixture::proof();

    let _result = verify_miller(
        pi_a, pi_b, pi_c, array![pub_input], Fq12Utils::one(), Fq12Utils::one(), circuit_setup
    );
// println!("groth16_miller_result = {}", _result);
}

#[test]
#[available_gas(20000000000)]
fn groth16_final_exponentiation() {
    let (_, _, _, _, miller_result) = fixture::proof();
    let result = miller_result.final_exponentiation();
    assert(result == Fq12Utils::one(), '');
}

#[test]
#[available_gas(20000000000)]
fn test_alphabeta_precompute() {
    let (alpha, beta, _gamma, _delta, _alphabeta_miller, _ic) = fixture::vk();
    let setup = fixture::circuit_setup();
    let computed_alpha_beta = ate_miller_loop(alpha.neg(), beta);
    assert(setup.alpha_beta == computed_alpha_beta, 'incorrect miller precompute');
}

#[test]
#[available_gas(20000000000)]
fn test_ic() {
    let (ic_0, ic) = fixture::circuit_setup().ic;
    let (_, _, _, pub_input, _) = fixture::proof();
    let ic_1 = *ic[0];
    let ic_arr = (ic, array![pub_input]).process_inputs_and_ic(ic_0);
    let ic_tuple = (ic_1, pub_input).process_inputs_and_ic(ic_0);

    assert(ic_arr == ic_tuple, 'incorrect ic');
}

#[test]
#[available_gas(20000000000)]
fn test_verify_setup() {
    let G16CircuitSetup { alpha_beta, gamma, gamma_neg: _, delta, delta_neg: _, lines: _, ic, } =
        fixture::circuit_setup();
    let (pi_a, pi_b, pi_c, pub_input, _) = fixture::proof();

    let (ic_0, ic) = ic;
    let ic = (ic, array![pub_input]).process_inputs_and_ic(ic_0);

    let pi_ab = ate_miller_loop(pi_a, pi_b); // pi_a * pi_b
    let ig = ate_miller_loop(ic, gamma); // ic * gamma
    let cd = ate_miller_loop(pi_c, delta); // pi_c * delta

    let pairing = alpha_beta * pi_ab * ig * cd;

    assert(pairing.final_exponentiation() == Fq12Utils::one(), 'incorrect pairing result');
}

fn print_g2_precompute(name: ByteArray, point: AffineG2, neg: AffineG2, lines: Array<LineFn>) {
    println!("\nfn {name}_precompute() -> FixedG2Precompute {{");
    println!("\nFixedG2Precompute {{");
    println!("\npoint: {},", point);
    println!("\nneg: {},", neg);
    println!("\nlines: array![{}]", lines);
    println!("}}");
    println!("\n}}");
}

#[test]
#[available_gas(20000000000)]
fn test_setup() {
    let (alpha_vk, beta_vk, gamma_vk, delta_vk, alphabeta, ic) = fixture::vk();

    let lines = LinesArray { gamma: array![], delta: array![] };
    let setup = setup_precompute(alpha_vk, beta_vk, gamma_vk, delta_vk, ic, lines);

    let setup_fix = fixture::circuit_setup();

    // // Print FixedG2Precompute for fixtures

    // print_g2_precompute("gamma", setup.gamma, setup.gamma_neg, setup.lines.gamma);
    // print_g2_precompute("delta", setup.delta, setup.delta_neg, setup.lines.delta);

    assert(setup.gamma == gamma_vk.neg(), 'incorrect gamma');
    assert(setup.gamma_neg == gamma_vk, 'incorrect gamma_neg');
    assert(setup.delta == delta_vk.neg(), 'incorrect delta');
    assert(setup.delta_neg == delta_vk, 'incorrect delta_neg');
    assert(setup.alpha_beta == alphabeta, 'incorrect miller precompute');

    assert(setup_fix.gamma == setup.gamma, 'incorrect mock gamma');
    assert(setup_fix.gamma_neg == setup.gamma_neg, 'incorrect mock gamma_neg');
    assert(setup_fix.delta == setup.delta, 'incorrect mock delta');
    assert(setup_fix.delta_neg == setup.delta_neg, 'incorrect mock delta_neg');
}
