use super::fixtures::{circuit_setup, residue_witness, proof, schzip};
use bn254_u256::{schzip_verify, bn254_curve, Bn254SchwartzZippelSteps,};

#[test]
#[available_gas(10000000000)]
fn verify() {
    let mut curve = bn254_curve();
    let (pi_a, pi_b, pi_c, input, _) = proof();
    let circuit = circuit_setup();
    let (_f, residue_witness, residue_witness_inv, _, cubic_scale) = residue_witness();
    let (remainders, q_rlc_sum) = schzip();

    let _verified = schzip_verify(
        ref curve,
        pi_a,
        pi_b,
        pi_c,
        array![input],
        residue_witness,
        residue_witness_inv,
        cubic_scale,
        circuit,
        remainders,
        q_rlc_sum
    );
    assert(_verified, 'verification failed');
}
