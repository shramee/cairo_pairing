use bn::fields::{Fq12};

#[starknet::interface]
trait IBN_Pairing<T> {
    fn final_exponentiation(self: @T, a: Fq12) -> Fq12;
    fn final_exponentiation_bench(self: @T) -> Fq12;
}

#[starknet::contract]
mod BN_Pairing {
    use bn::fields::{Fq12, fq12, Fq12FinalExpo};
    use bn::curve::pairing::tate_bkls::{tate_pairing, tate_miller_loop};

    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(ref self: ContractState, value_: u128) {}

    #[abi(embed_v0)]
    impl BN_Pairing of super::IBN_Pairing<ContractState> {
        fn final_exponentiation(self: @ContractState, a: Fq12) -> Fq12 {
            a.final_exponentiation()
        }
        fn final_exponentiation_bench(self: @ContractState) -> Fq12 {
            fq12(
                0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
                0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
                0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
                0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
                0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
                0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
                0x2da44e38ec26bde1ad31495943114856dd885beb7889c590079bb300bb6ec023,
                0x1c40f4619c21dbd91ba610a8943188e35402e587a071361f60288e7e96fa33b,
                0x9ebfb41a99f28109afed1112aab3c8ab4ff6dd90097e880669c960f11106b52,
                0x2d0c275838257edb77665b9aafbbd40626b6a35fe12b4ccacee5613bf3408fc2,
                0x289d6d934bc5994e10f4dc4bfe3a5ac9cddfce66ee76df1e751b064bfdb5533d,
                0x1e18e64906693e6f4c9cd40273060c504a78843d903489abb13377666679d33f,
            )
                .final_exponentiation()
        }
    }
}
