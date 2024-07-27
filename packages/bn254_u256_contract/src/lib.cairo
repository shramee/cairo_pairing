pub use bn254_u256::{
    schzip_verify, PtG1, PtG2, Fq, FqD12, CubicScale, Groth16Circuit, Bn254U256Curve, bn254_curve,
    LnArrays, InputConstraintPoints
};

#[starknet::interface]
trait IBN_Pairing<T> {
    // fn final_exponentiation(self: @T, a: FqD12) -> FqD12;
    // fn final_exponentiation_bench(self: @T) -> FqD12;
    // fn pairing_bench(self: @T) -> FqD12;
    // fn miller_bench(self: @T) -> FqD12;
    fn verify(
        ref self: T,
        pi_a: PtG1,
        pi_b: PtG2,
        pi_c: PtG1,
        inputs: Array<u256>,
        residue_witness: FqD12,
        residue_witness_inv: FqD12,
        cubic_scale: CubicScale,
        setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, FqD12>,
        schzip_remainders: Array<FqD12>,
        schzip_qrlc: Array<Fq>,
    );
    fn groth16_verification(ref self: T);
}

#[starknet::contract]
mod BN_Pairing {
    use super::{
        schzip_verify, bn254_curve,
        {
            PtG1, PtG2, Fq, FqD12, CubicScale, Groth16Circuit, Bn254U256Curve, LnArrays,
            InputConstraintPoints
        }
    };
    use bn254_u256::fixtures::{circuit_setup, residue_witness, proof, schzip};

    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[abi(embed_v0)]
    impl BN_Pairing of super::IBN_Pairing<ContractState> {
        fn verify(
            ref self: ContractState,
            pi_a: PtG1,
            pi_b: PtG2,
            pi_c: PtG1,
            inputs: Array<u256>,
            residue_witness: FqD12,
            residue_witness_inv: FqD12,
            cubic_scale: CubicScale,
            setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, FqD12>,
            schzip_remainders: Array<FqD12>,
            schzip_qrlc: Array<Fq>,
        ) {
            let mut curve = bn254_curve();
            assert(
                schzip_verify(
                    ref curve,
                    pi_a,
                    pi_b,
                    pi_c,
                    inputs,
                    residue_witness,
                    residue_witness_inv,
                    cubic_scale,
                    setup,
                    schzip_remainders,
                    schzip_qrlc,
                ),
                'verification failed'
            );
        }

        fn groth16_verification(ref self: ContractState,) {
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
    }
}
