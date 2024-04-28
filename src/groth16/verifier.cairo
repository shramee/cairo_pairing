use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{process_input_constraints};

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
}

#[derive(Copy, Drop)]
struct Groth16PreCompute {
    p: Groth16MillerG1,
    q: Groth16MillerG2,
    ppc: (PPrecompute, PPrecompute, PPrecompute),
    neg_q: Groth16MillerG2,
    field_nz: NonZero<u256>,
}

// Does verification
fn verify() { //
// Compute k from ic and public_inputs
// Compute optimise triple miller loop for the points
// multiply precomputed alphabeta_miller with the pairings
// final exponentiation
// return result == 1
}
