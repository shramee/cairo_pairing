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
use bn::groth16::verifier::{verify};
use bn::groth16::setup::{setup_precompute, StepLinesTrait, G16CircuitSetup};
use bn::groth16::mock;
use core::fmt::{Display, Formatter, Error};

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

fn proof() -> (AffineG1, AffineG2, AffineG1, u256) {
    let pi_a = g1(
        21869318927288279352976009554602485400194222893443965440964860860113038611333,
        18311135712289946861315992474690361768373551919702286485795766144098633284656,
    );
    let pi_b = g2(
        10022883437199133497429724894217743345007175536382603527810937928471784278544,
        17847188618426698749899308504244999133998140738319907268599259829537979435105,
        7206719342459067270750328127893044383768922785737900891173474267747233610797,
        10190861912483383555079439540237798028694495449372197543107740729805978332256,
    );
    let pi_c = g1(
        9705330802798333149196349399272648034569447771243096213977283095662805051802,
        5611531129077709352565605843416215629032027923761887684873913606256162034924,
    );
    let pub_input = 16941831391195391826097405368824996545623792600381113317588874714920518273658;
    (pi_a, pi_b, pi_c, pub_input,)
}

#[test]
#[available_gas(20000000000)]
fn groth16_verify() {
    // Verification key parameters
    // let (_, _, gamma, delta, albe_miller, mut ic) = vk();
    let circuit_setup: G16CircuitSetup<LinesArray> = mock::circuit_setup();

    // Proof parameters
    let (pi_a, pi_b, pi_c, pub_input,) = proof();

    let verified = verify(pi_a, pi_b, pi_c, array![pub_input], circuit_setup);

    assert(verified, 'verification failed');
}

#[test]
#[available_gas(20000000000)]
fn test_alphabeta_precompute() {
    let (alpha, beta, _gamma, _delta, _alphabeta_miller, _ic) = mock::vk();
    let setup = mock::circuit_setup();
    let computed_alpha_beta = ate_miller_loop(alpha.neg(), beta);
    assert(setup.alpha_beta == computed_alpha_beta, 'incorrect miller precompute');
}

fn print_g2_precompute(point: AffineG2, neg: AffineG2, lines: Array<LineFn>) {
    println!("\nFixedG2Precompute {{");
    println!("\npoint: {},", point);
    println!("\nneg: {},", neg);
    // println!("\nlines: array![{}]", lines);
    println!("}}");
}

#[test]
#[available_gas(20000000000)]
fn test_ic() {
    let (ic_0, ic) = mock::circuit_setup().ic;
    let (_, _, _, pub_input,) = proof();
    let ic_1 = *ic[0];
    let ic_arr = (ic, array![pub_input]).process_inputs_and_ic(ic_0);
    let ic_tuple = (ic_1, pub_input).process_inputs_and_ic(ic_0);

    assert(ic_arr == ic_tuple, 'incorrect ic');
}

#[test]
#[available_gas(20000000000)]
fn test_setup_verification() {
    let G16CircuitSetup { alpha_beta, gamma, gamma_neg: _, delta, delta_neg: _, lines: _, ic, } =
        mock::circuit_setup();
    let (pi_a, pi_b, pi_c, pub_input,) = proof();

    let (ic_0, ic) = ic;
    let ic = (ic, array![pub_input]).process_inputs_and_ic(ic_0);

    let pi_ab = ate_miller_loop(pi_a, pi_b); // pi_a * pi_b
    let ig = ate_miller_loop(ic, gamma); // ic * gamma
    let cd = ate_miller_loop(pi_c, delta); // pi_c * delta

    let pairing = alpha_beta * pi_ab * ig * cd;

    assert(pairing.final_exponentiation() == Fq12Utils::one(), 'incorrect pairing result');
}

#[test]
#[available_gas(20000000000)]
fn test_setup() {
    let (alpha_vk, beta_vk, gamma_vk, delta_vk, alphabeta, ic) = mock::vk();

    let lines = LinesArray { gamma: array![], delta: array![] };
    let setup = setup_precompute(alpha_vk, beta_vk, gamma_vk, delta_vk, ic, lines);

    let setup_mock = mock::circuit_setup();

    // // Print FixedG2Precompute for mocks

    // println!("\nfn gamma_precompute() -> FixedG2Precompute {{");
    // print_g2_precompute(gamma, gamma_neg, _lines.gamma);
    // println!("\n}}");

    // println!("\nfn delta_precompute() -> FixedG2Precompute {{");
    // print_g2_precompute(delta, delta_neg, _lines.delta);
    // println!("\n}}");

    assert(setup.gamma == gamma_vk.neg(), 'incorrect gamma');
    assert(setup.gamma_neg == gamma_vk, 'incorrect gamma_neg');
    assert(setup.delta == delta_vk.neg(), 'incorrect delta');
    assert(setup.delta_neg == delta_vk, 'incorrect delta_neg');
    assert(setup.alpha_beta == alphabeta, 'incorrect miller precompute');

    assert(setup_mock.gamma == setup.gamma, 'incorrect mock gamma');
    assert(setup_mock.gamma_neg == setup.gamma_neg, 'incorrect mock gamma_neg');
    assert(setup_mock.delta == setup.delta, 'incorrect mock delta');
    assert(setup_mock.delta_neg == setup.delta_neg, 'incorrect mock delta_neg');
}
