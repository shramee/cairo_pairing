//
// This file is for circuit setup for Groth16
//
// * Receives alpha, beta, gamma, delta
// * Computes Fixed pairing of alpha and negative beta
// * Computes negative gamma, negative delta
// * Computes line functions for gamma, delta miller steps
//
// Returns
// * e(neg alpha, beta)
// * negative gamma, (negative negative) gamma
// * line functions array for gamma
// * negative delta, (negative negative) delta
// * line functions array for delta
//
// Then verification can be done as,
// e(a, b) * e_neg_alpha_beta * e(k, neg gamma) * e(c, neg delta) == 1
//

use bn::fields::fq_sparse::FqSparseTrait;
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use bn::traits::{MillerPrecompute, MillerSteps};
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_utils::{p_precompute, step_double, step_dbl_add, correction_step};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{ICProcess, process_input_constraints};

#[derive(Copy, Drop, Serde)]
type Line = (Fq2, Fq2,);

// The points to generate lines precompute for
#[derive(Copy, Drop)]
struct G16LinesG2 {
    delta: AffineG2,
    gamma: AffineG2,
}

#[derive(Drop)]
struct G16LinesLoopPreComp {
    delta_lines: Array<Line>,
    gamma_lines: Array<Line>,
    q: G16LinesG2,
    ppc: PPrecompute, // We use dummy p (1,1)
    neg_q: G16LinesG2,
    field_nz: NonZero<u256>,
}

