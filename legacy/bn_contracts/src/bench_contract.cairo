use bn::fields::{Fq12};
use bn::curve::groups::{AffineG1, AffineG2};

#[starknet::interface]
trait IBN_Pairing<T> {
    // fn final_exponentiation(self: @T, a: Fq12) -> Fq12;
    // fn final_exponentiation_bench(self: @T) -> Fq12;
    // fn pairing_bench(self: @T) -> Fq12;
    // fn miller_bench(self: @T) -> Fq12;
    fn groth16_setup(
        ref self: T,
        alpha: AffineG1,
        beta: AffineG2,
        gamma: AffineG2,
        delta: AffineG2,
        ic: Array<AffineG1>,
        pi_a: AffineG1,
        pi_b: AffineG2,
        pi_c: AffineG1,
        inputs: Array<u256>,
    );
}

#[starknet::contract]
mod BN_Pairing {
    use bn::fields::{Fq12, fq12, Fq12Exponentiation};
    use bn::curve::groups::{AffineG1, AffineG2};
    use bn::groth16::{verify, setup_precompute, utils::LinesArray};
    use bn::curve::groups::{g1, g2};
    use bn::curve::pairing::tate_bkls::{tate_pairing, tate_miller_loop};

    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[abi(embed_v0)]
    impl BN_Pairing of super::IBN_Pairing<ContractState> {
        // fn final_exponentiation(self: @ContractState, a: Fq12) -> Fq12 {
        //     a.final_exponentiation()
        // }

        // fn miller_bench(self: @ContractState) -> Fq12 {
        //     let p1 = g1(
        //         0x17c139df0efee0f766bc0204762b774362e4ded88953a39ce849a8a7fa163fa9,
        //         0x1e0559bacb160664764a357af8a9fe70baa9258e0b959273ffc5718c6d4cc7c
        //     );
        //     let p2 = g2(
        //         0x6064e784db10e9051e52826e192715e8d7e478cb09a5e0012defa0694fbc7f5,
        //         0x1014772f57bb9742735191cd5dcfe4ebbc04156b6878a0a7c9824f32ffb66e85,
        //         0x58e1d5681b5b9e0074b0f9c8d2c68a069b920d74521e79765036d57666c5597,
        //         0x21e2335f3354bb7922ffcc2f38d3323dd9453ac49b55441452aeaca147711b2,
        //     );
        //     tate_miller_loop(p1, p2)
        // }

        // fn final_exponentiation_bench(self: @ContractState) -> Fq12 {
        //     fq12(
        //         0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
        //         0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
        //         0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
        //         0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
        //         0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
        //         0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
        //         0x2da44e38ec26bde1ad31495943114856dd885beb7889c590079bb300bb6ec023,
        //         0x1c40f4619c21dbd91ba610a8943188e35402e587a071361f60288e7e96fa33b,
        //         0x9ebfb41a99f28109afed1112aab3c8ab4ff6dd90097e880669c960f11106b52,
        //         0x2d0c275838257edb77665b9aafbbd40626b6a35fe12b4ccacee5613bf3408fc2,
        //         0x289d6d934bc5994e10f4dc4bfe3a5ac9cddfce66ee76df1e751b064bfdb5533d,
        //         0x1e18e64906693e6f4c9cd40273060c504a78843d903489abb13377666679d33f,
        //     )
        //         .final_exponentiation()
        // }

        // fn pairing_bench(self: @ContractState) -> Fq12 {
        //     BN_Pairing::miller_bench(self).final_exponentiation()
        // }

        fn groth16_setup(
            ref self: ContractState,
            alpha: AffineG1,
            beta: AffineG2,
            gamma: AffineG2,
            delta: AffineG2,
            mut ic: Array<AffineG1>,
            pi_a: AffineG1,
            pi_b: AffineG2,
            pi_c: AffineG1,
            inputs: Array<u256>,
        ) {
            let lines = LinesArray { gamma: array![], delta: array![] };
            let _circuit_setup = setup_precompute(alpha, beta, gamma, delta, ic, lines);

            // let verified = verify(pi_a, pi_b, pi_c, inputs, circuit_setup);
            let verified = false;

            assert(verified, 'verification failed');
        }
    }
}
