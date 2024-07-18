pub use bn254_u256::{
    schzip_verify, PtG1, PtG2, Fq, Fq12, CubicScale, Groth16Circuit, Bn254U256Curve, bn254_curve,
    LnArrays, InputConstraintPoints
};

#[starknet::interface]
trait IBN_Pairing<T> {
    // fn final_exponentiation(self: @T, a: Fq12) -> Fq12;
    // fn final_exponentiation_bench(self: @T) -> Fq12;
    // fn pairing_bench(self: @T) -> Fq12;
    // fn miller_bench(self: @T) -> Fq12;
    fn verify(
        ref self: T,
        pi_a: PtG1,
        pi_b: PtG2,
        pi_c: PtG1,
        inputs: Array<u256>,
        residue_witness: Fq12,
        residue_witness_inv: Fq12,
        cubic_scale: CubicScale,
        setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, Fq12>,
        schzip_remainders: Array<Fq12>,
        schzip_qrlc: Array<Fq>,
    );
}

#[starknet::contract]
mod BN_Pairing {
    use super::{
        schzip_verify, bn254_curve,
        {
            PtG1, PtG2, Fq, Fq12, CubicScale, Groth16Circuit, Bn254U256Curve, LnArrays,
            InputConstraintPoints
        }
    };

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
            residue_witness: Fq12,
            residue_witness_inv: Fq12,
            cubic_scale: CubicScale,
            setup: Groth16Circuit<PtG1, PtG2, LnArrays, InputConstraintPoints, Fq12>,
            schzip_remainders: Array<Fq12>,
            schzip_qrlc: Array<Fq>,
        ) {
            let mut curve = bn254_curve();
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
            )
        }
    }
}
