use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation, Fq12Frobenius};
use bn::curve::{pairing, get_field_nz};
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
use pairing::optimal_ate_utils::LineFn;
use bn::groth16::utils::{G16CircuitSetup, LinesArray};
use bn::groth16::fixture;
use bn::groth16::schzip::schzip_verify_with_commitments;
use bn::groth16::schzip::{schzip_base_verify, SchZipMock};
use core::poseidon::PoseidonImpl;
use core::hash::HashStateTrait;

#[test]
#[available_gas(20000000000)]
fn verify_print() {
    // Verification key parameters
    // let (_, _, gamma, delta, albe_miller, mut ic) = vk();
    let circuit_setup: G16CircuitSetup<LinesArray> = fixture::circuit_setup();

    // Proof parameters
    let (pi_a, pi_b, pi_c, pub_input, _) = fixture::proof();
    let (_, residue_witness, residue_witness_inv, _cubic_scl, cubic_pow) =
        fixture::residue_witness();

    let verified = schzip_base_verify(
        pi_a,
        pi_b,
        pi_c,
        array![pub_input],
        residue_witness,
        residue_witness_inv,
        cubic_pow,
        circuit_setup,
        SchZipMock { print: true, f01234: false },
        get_field_nz()
    );

    assert(verified, 'verification failed');
}

#[test]
#[available_gas(20000000000)]
fn verify_with_commitment() {
    // Verification key parameters
    // let (_, _, gamma, delta, albe_miller, mut ic) = vk();
    let circuit_setup: G16CircuitSetup<LinesArray> = fixture::circuit_setup();

    // Proof parameters
    let (pi_a, pi_b, pi_c, pub_input, _) = fixture::proof();
    let (_, residue_witness, residue_witness_inv, _cubic_scl, cubic_pow) =
        fixture::residue_witness();

    let _verified = schzip_verify_with_commitments(
        pi_a,
        pi_b,
        pi_c,
        array![pub_input],
        residue_witness,
        residue_witness_inv,
        cubic_pow,
        circuit_setup,
        fixture::schzip()
    );

    assert(_verified, 'verification failed');
}

#[test]
#[available_gas(20000000000)]
fn fiat_shamir() {
    // Proof parameters
    let mut coeffs = bn::groth16::fixture::schzip();
    let mut hasher = core::poseidon::PoseidonImpl::new();
    loop {
        match coeffs.pop_front() {
            Option::Some(coeff) => {
                hasher = hasher.update(coeff.low.into());
                hasher = hasher.update(coeff.high.into());
            },
            Option::None => { break; },
        };
    };
    let _hash = hasher.finalize();

    // println!("hash: {hash}");
    assert(true, '');
}

