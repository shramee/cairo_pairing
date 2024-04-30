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
use bn::traits::{MillerPrecompute, MillerSteps, FieldUtils};
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_utils::{p_precompute, step_double, step_dbl_add, correction_step};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps, PPrecompute};
use bn::groth16::utils::{ICProcess, process_input_constraints};

#[derive(Copy, Drop, Serde)]
type Line = (Fq2, Fq2,);

// The points to generate lines precompute for
#[derive(Copy, Drop, Serde)]
struct G16SetupG2 {
    delta: AffineG2,
    gamma: AffineG2,
}

#[derive(Drop, Serde)]
struct G16SetupPreComp {
    delta_lines: Array<Line>,
    gamma_lines: Array<Line>,
    q: G16SetupG2,
    ppc: PPrecompute, // We use dummy p (1,1)
    neg_q: G16SetupG2,
    field_nz: NonZero<u256>,
}

impl G16SetupSteps of MillerSteps<G16SetupPreComp, G16SetupG2> {
    fn miller_first_second(self: @G16SetupPreComp, i1: u32, i2: u32, ref acc: G16SetupG2) -> Fq12 {
        FieldUtils::one()
    }

    // 0 bit
    fn miller_bit_o(self: @G16SetupPreComp, i: u32, ref acc: G16SetupG2, ref f: Fq12) {}

    // 1 bit
    fn miller_bit_p(self: @G16SetupPreComp, i: u32, ref acc: G16SetupG2, ref f: Fq12) {}

    // -1 bit
    fn miller_bit_n(self: @G16SetupPreComp, i: u32, ref acc: G16SetupG2, ref f: Fq12) {}

    // last step
    fn miller_last(self: @G16SetupPreComp, ref acc: G16SetupG2, ref f: Fq12) {}
}

#[derive(Drop, Serde)]
struct G16CircuitSetup {
    alpha_beta: Fq12,
// gamma: FixedG2Precompute,
// delta: FixedG2Precompute,
}

#[derive(Drop, Serde)]
struct FixedG2Precompute {
    lines: Array<Line>,
    point: AffineG2,
    neg: AffineG2,
}

fn setup_precompute(
    alpha: AffineG1, beta: AffineG2, gamma: AffineG2, delta: AffineG2,
) -> G16CircuitSetup { //
    // negate alpha, gamma and delta
    // e(alpha, beta)
    // line functions for gamma
    // line functions for delta
    G16CircuitSetup { alpha_beta: Fq12Utils::one(), }
}
