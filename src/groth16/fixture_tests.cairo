use bn::curve::{pairing, groups::ECOperations};
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
use bn::groth16::fixture;
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Frobenius, print::Fq12Display};
use bn::groth16::setup::{G16CircuitSetup, ICProcess,};
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
