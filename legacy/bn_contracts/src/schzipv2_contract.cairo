use bn::g::{AffineG1, AffineG2,};
use bn::groth16::utils::{ICProcess, G16CircuitSetup, LinesArray};
use fields::{Fq12};
use bn::curve::residue_witness::{CubicScale};

#[starknet::interface]
trait SchZipGro16<TConSta> {
    fn verify(
        ref self: TConSta,
        pi_a: AffineG1,
        pi_b: AffineG2,
        pi_c: AffineG1,
        inputs: Array<u256>,
        residue_witness: Fq12,
        residue_witness_inv: Fq12,
        cubic_scale: CubicScale,
        setup: G16CircuitSetup<LinesArray>,
        coefficients: Array<u256>,
    );
// fn verify_preset(
//     ref self: TConSta,
//     pi_a: AffineG1,
//     pi_b: AffineG2,
//     pi_c: AffineG1,
//     inputs: Array<u256>,
//     residue_witness: Fq12,
//     residue_witness_inv: Fq12,
//     cubic_scale: CubicScale,
//     coefficients: Array<u256>,
// );
}

#[starknet::contract]
mod schzipgro16_contract {
    use bn::g::{AffineG1, AffineG2,};
    use bn::groth16::utils::{ICProcess, G16CircuitSetup, LinesArray};
    use fields::{Fq12};
    use bn::curve::residue_witness::{CubicScale};
    use bn::groth16::schzip::schzip_verify_with_commitments;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl SchZipGro16Impl of super::SchZipGro16<ContractState> {
        fn verify(
            ref self: ContractState,
            pi_a: AffineG1,
            pi_b: AffineG2,
            pi_c: AffineG1,
            inputs: Array<u256>,
            residue_witness: Fq12,
            residue_witness_inv: Fq12,
            cubic_scale: CubicScale,
            setup: G16CircuitSetup<LinesArray>,
            coefficients: Array<u256>,
        ) {
            schzip_verify_with_commitments(
                pi_a,
                pi_b,
                pi_c,
                inputs,
                residue_witness,
                residue_witness_inv,
                cubic_scale,
                setup,
                coefficients
            );
        }
    // fn verify_preset(
    //     ref self: ContractState,
    //     pi_a: AffineG1,
    //     pi_b: AffineG2,
    //     pi_c: AffineG1,
    //     inputs: Array<u256>,
    //     residue_witness: Fq12,
    //     residue_witness_inv: Fq12,
    //     cubic_scale: CubicScale,
    //     coefficients: Array<u256>,
    // ) {
    //     schzip_verify_with_commitments(
    //         pi_a,
    //         pi_b,
    //         pi_c,
    //         inputs,
    //         residue_witness,
    //         residue_witness_inv,
    //         cubic_scale,
    //         fixture::circuit_setup(),
    //         coefficients
    //     );
    // }
    }
}

#[starknet::interface]
trait SchZipGro16Bench<TConSta> {
    fn verify(ref self: TConSta) -> bool;
}

#[starknet::contract]
mod schzipgro16_bench_contract {
    use bn::g::{AffineG1, AffineG2,};
    use bn::groth16::utils::{ICProcess, G16CircuitSetup, LinesArray};
    use fields::{Fq12};
    use bn::curve::residue_witness::{CubicScale};
    use bn::groth16::schzip::schzip_verify_with_commitments;
    use bn::groth16::fixture;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl SchZipGro16Impl of super::SchZipGro16Bench<ContractState> {
        fn verify(ref self: ContractState) -> bool {
            let (pi_a, pi_b, pi_c, pub_input, _) = fixture::proof();
            let (_, residue_witness, residue_witness_inv, _, cubic_scl) =
                fixture::residue_witness();

            schzip_verify_with_commitments(
                pi_a,
                pi_b,
                pi_c,
                array![pub_input],
                residue_witness,
                residue_witness_inv,
                cubic_scl,
                fixture::circuit_setup(),
                fixture::schzip()
            )
        }
    // fn verify_preset(
    //     ref self: ContractState,
    //     pi_a: AffineG1,
    //     pi_b: AffineG2,
    //     pi_c: AffineG1,
    //     inputs: Array<u256>,
    //     residue_witness: Fq12,
    //     residue_witness_inv: Fq12,
    //     cubic_scale: CubicScale,
    //     coefficients: Array<u256>,
    // ) {
    //     schzip_verify_with_commitments(
    //         pi_a,
    //         pi_b,
    //         pi_c,
    //         inputs,
    //         residue_witness,
    //         residue_witness_inv,
    //         cubic_scale,
    //         fixture::circuit_setup(),
    //         coefficients
    //     );
    // }
    }
}
