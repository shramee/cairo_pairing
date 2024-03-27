use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldMulShortcuts;
use bn::traits::FieldShortcuts;
use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{
    fq, fq2, Fq2, fq12, Fq12, Fq6, fq6, Fq2MulShort, Fq2Ops, Fq2Short, Fq12Ops, Fq12Exponentiation,
    Fq2IntoU512Tuple
};
use bn::curve::{
    FIELD, u512, Tuple2Add, Tuple2Sub, U512BnAdd, U512BnSub, u512_sub_u256, u512_add, u512_sub
};
use bn::fields::fq_12_squaring::{x2, x4, X2, mul_by_xi_nz, Krbn2345, Fq12Squaring};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{Fq12Display, Fq2Display};
use debug::PrintTrait;

fn a_cyc() -> Fq12 {
    fq12(
        0x2e3a5a8e0529c430c27e3673b9519767e265dcbcde8fea81cdd820918c4bd107,
        0xe6c5e3ec8c33c105e56e0ff3969bd92b2c4f6b05be655dcf21238f80c72030f,
        0x1b9732f816a94fa77048902ccb7ffc1ef433b2d95ebfad13030852e6e244b0b3,
        0x200ab6da30955b57dcc064deef9e4962ffa243efffd819010546fadaf591ef55,
        0x4d4df3e5d3bd9178d6a6c3a0654b542be46f209d956660c3605b9b4d5c8b8e0,
        0x4a86b2d0e408874533554f3c4071db92b6984030d5e7e4c6d6bbd3b84bd86b4,
        0x62ef6addea25e90cedd1bfab17d5dc57aed021a999e6c03eb1d83cd04246394,
        0x13dada4aebe86c7c07d4d5689172f885284aafe4e599d240735bf229fa3d823f,
        0x122268beeda258f397785a4150e7557a7621ee6162d05a27ace4f719f6b0c035,
        0x30190d0f16d7222c83db31cd4bff91a51d2b1991b7a177459a06d4e50cae2448,
        0xee6ccfeef156e1a3f34f7b5629b518389bc49197bacf5aa1c438139fd24df10,
        0x270c8d4ba7c1f3e200ab9a1123a1ecb1cd6b8cd2c8c92601210007b6759f7351,
    )
}

fn sqr() -> Fq12 {
    fq12(
        0x1e80cf27a7766c24faca9616290eb1f260fdcf44b1d055c630c6a56310e63a4,
        0x21f98fcaf9c5c17f32dc1bb82af15a2c3cbba5638e5cc7b3d2b89e02613c15fb,
        0x1e8c1d765c889729df23b4cf95b88b74e26a6460141636e15b44737d1352849f,
        0x26260b5846914e1a6007efc8e78b7490a3ca950afa802a07e233f333499f7e74,
        0x253a35790f9a2c6fb810fc23585e4430f0e093d804af07a20b6499d7044cf8be,
        0x4cf413b0ba523d85bc128d95fe733b95e071156c11b78bd8aaa08079816948e,
        0x11cb229b6b0c376e3ebb680db3a4149023a453a018a6d39fabe622825afa67c5,
        0x179e4e86ad0830c8e9fe002a80fcaec7e78de6b33a6783bfb7820049256fd95f,
        0x2db49f10340ab71da4d3cf7fb2b394c3cf0d3d3bc545cc945b44ebfd4611a5e4,
        0xad97ea64fdb30c5cd58cd0a6b043f1dcb472f60fa592a654cac235f24ddc11b,
        0x121038de7fd5634b99731a3c8e48504e2e0362c09af0cb7bc7391d6ee283d40c,
        0xf8e3c319575383456ae4417d6299dc156e9d71c91dc296d5cd724ded415d29c,
    )
}
// #[test]
// #[available_gas(20000000)]
// fn krbn_experiments() {
//     let Fq12 { c0: Fq6 { c0: _, c1: _, c2: g2 }, c1: Fq6 { c0: g3, c1: g4, c2: g5 } } =
//         a_cyc();
//     let field_nz: NonZero<u256> = get_field_nz();
//     let asq = sqr();
//     // Si,j = (gi + gj )^2 and Si = gi^2
//     // let S2: (u512, u512) = g2.u_sqr();
//     let S3: (u512, u512) = g3.u_sqr();
//     let S4: (u512, u512) = g4.u_sqr();
//     let S5: (u512, u512) = g5.u_sqr();
//     let S4_5: (u512, u512) = (g4 + g5).u_sqr();
//     // let S2_3: (u512, u512) = g2.u_add(g3).u_sqr();

//     let s4 = g4.sqr();
//     let s5 = g5.sqr();
//     let s4_5 = (g4 + g5).sqr();

//     // h₂ = 2g₂ + 3ξ((g₄+g₅)²-g₄²-g₅²)
//     // h₃ = 3(g₄² + g₅²ξ) - 2g₃
//     // h₄ = 3(g₂² + g₃²ξ) - 2g₄
//     // h₅ = 2g₅ + 3 ((g₂+g₃)²-g₂²-g₃²)

//     // h2 = 3(S4_5 − S4 − S5)ξ + 2g2;
//     // let _h2: (u512, u512) = X3(mul_by_xi_nz(S4_5 - S4 - S5, field_nz)).u512_add_fq(g2.u_add(g2));
//     // let h2: Fq2 = _h2.to_fq(field_nz);

//     // h₂ = 2g₂ + 3ξ((g₄+g₅)²-g₄²-g₅²)
//     let h2 = (s4_5 - s4 - s5).mul_by_nonresidue().scale(fq(3)) + g2.u_add(g2);
//     // let h2 = g2.u_add(g2) + x3((s4_5 - s4 - s5).mul_by_nonresidue());

//     println!("{}{}", asq.c0.c2, h2);
//     assert(asq.c0.c2 == h2.fix_mod(), 'mismatch');
// }

fn compare_fq2(a: Fq2, b: Fq2, help: ByteArray) {
    println!("\n\n{} match: {}{}{}", help, a == b, a, b);
}
fn print_fq2(a: (u512, u512), help: ByteArray) {
    let a: Fq2 = a.to_fq(get_field_nz());
    println!("\n\n{} {}", help, a);
}

#[test]
#[available_gas(200000000)]
fn krbn1235() {
    let field_nz: NonZero<u256> = get_field_nz();
    let a = a_cyc().sqr_krbn_1235(field_nz);
    let Fq12 { c0: Fq6 { c0: _g0, c1: g1, c2: g2 }, c1: Fq6 { c0: g3, c1: _g4, c2: g5 } } = a;
    let Fq12 { c0: Fq6 { c0: _s0, c1: s1, c2: s2 }, c1: Fq6 { c0: s3, c1: _s4, c2: s5 } } = sqr();
    assert(g1 == s1, 'krbn1235 wrong g1');
    assert(g2 == s2, 'krbn1235 wrong g2');
    assert(g3 == s3, 'krbn1235 wrong g3');
    assert(g5 == s5, 'krbn1235 wrong g5');
}

#[test]
#[available_gas(200000000)]
fn krbn2345() {
    let field_nz: NonZero<u256> = get_field_nz();
    let a = a_cyc().krbn_compress_2345().sqr_krbn(field_nz);
    let Krbn2345 { g2, g3, g4, g5, } = a;
    let Krbn2345 { g2: s2, g3: s3, g4: s4, g5: s5, } = sqr().krbn_compress_2345();
    assert(g2 == s2, 'krbn1235 wrong g1');
    assert(g3 == s3, 'krbn1235 wrong g2');
    assert(g4 == s4, 'krbn1235 wrong g3');
    assert(g5 == s5, 'krbn1235 wrong g5');
}

#[test]
#[available_gas(50000000)]
fn expand_2345() {
    let a = a_cyc();
    let field_nz = get_field_nz();
    let asq_decompressed = a.krbn_compress_2345().krbn_decompress(field_nz);
    assert(a == asq_decompressed, 'incorrect krbn_decompress');
}

#[test]
#[available_gas(50000000)]
fn sqr_cyc() {
    let a = a_cyc();
    let field_nz = get_field_nz();
    assert(a.cyclotomic_sqr(field_nz) == sqr(), 'incorrect square');
}

fn pair_result_12() -> Fq12 {
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
}

fn pair_result_21() -> Fq12 {
    fq12(
        0x67344e1277398709a07f22125f334c042889b9968132d91836456f02693e2aa,
        0x9eb543ae69ac30e7c5a1d8740db1a27b76ce7639c31b4c5097118031dcc9fd6,
        0x1a828818f6199acedcc7e3b04359dd558e34046b9367d4f43e90530a3241800e,
        0x50eba70419a4a7703a843ab3ba1d635378175acdf8eecbdf959bba7b7d30458,
        0x51c4fe05ca153f901a16e7aa2d17eaae8ba67e06ff0f36f6b039a1eacf2b6cf,
        0x65ff7c2e78658da7694f442878d48d346b33678a6fe2ead51b475977e2c4f7f,
        0xc13c405903b8328438e35f5eae314749ae264ffeb6c4e4429108b29338da611,
        0x9b07dee721f8a8468804de92b08bac6dae98d8246da83ff65b96a7ab3241652,
        0x19731a39f257d88617714358ee57d06ae39d2b51b07c9de926be9ae4fa4ed2cc,
        0x103dea7bed900dd8dbabac886bd24e973cee753d8c1781b71f8b40b3ecaeb04f,
        0x239d3477b8798bb2227e8e21d724419e093c5c678058049a61bb69e21e046c00,
        0x309258557eb06754d1dcfb8a6fa4a98c59538a8dc0317cbae8fd97078c36cf0,
    )
}

fn easy_result() -> Fq12 {
    fq12(
        0x2a4ca72fdd0af3ff86e646da9b96a7cc69407cc1e4f87dd12f6552d6168cc1cb,
        0x1e632505544fad7aa191c7b1c7cc7a816d43ea1e3c222a9f633f2532beba7a90,
        0x29f7ffe4990167e9c40b82e10d99104ed5d58a10505ca9df3fe6f89f6d724631,
        0x2ecce5bd65fbc42a4fbacc84ed28a52669da21815d300b2c1a85cf547f941dff,
        0x2379db1f2f5cc1fbc708decedaec77bef7d70e5b45e93e0e3f4ed386e4f98543,
        0x48bcf44109b965cfcb21c0fd27c8a6a46b85d3d6bc8eef39bf4808fd737cc9b,
        0x14d67d4a9d98bb99dca11a3dfdf7ee4655c5305123e8676abd56cef0448cf135,
        0x2f9b1014ad8e0e49630b434d1869fbf7172935beff46af19cd14415f3592b2a2,
        0x79cb3aad73095167444481a53809f754281e717954a8247baa89729918cb2ce,
        0x2a3b1205bc914c2659c0eeea8e956ca4fd0386d8e5a05ba73a44114db999f936,
        0x2ed2c21f4810cf49ad8f51cc1bd2d28972a066bb153f23f87e955496865cccb4,
        0x24c11b663b70d224c7c3f096026b6aa418a4945ffcc6d8aaa5522633b2836b49,
    )
}

fn final_result() -> Fq12 {
    fq12(
        0x1025124034fecc32ba2c3bbbcdb356c5bd84a787f0a9c5e1f9a34d5b87dae85a,
        0x1aafb1f7de052c1c1187f7d294d2204bf4e854a05965817e51014a355d917f96,
        0x26c79392cd82f5f15f1366f8c70f618837fe6ccc10c10815369bc8e1412caae,
        0x1d65be11b6b500a55c3c53ca4c033319626a9bc82fa79316bfb14bcd86f0aca5,
        0x8bd3e1971621469e271e9b18016edbc3517c94001240a1e5ef3b07c10860383,
        0xe5327ccc2114231fcd953aa29ccc1fd04ec1bced962c7f9534b9a001dd41a75,
        0x2b7c8e0abca6a7476f0936f535c5e6469ad4b94f8f24c6f437f6d6686a1b381b,
        0x29679b4f134ab2b2e02d2c82a385b12d2ee2272a7e350fba6f80588c0e0afa13,
        0x29163531c4ea85c647a9cd25e2de1433f12569f772eb83fcd8a997f3ca309cee,
        0x23bc9fb95fcf761320a0a287addd92dfaeb1ffc8bf8a943e703fc39f1e9d3085,
        0x236942b30ace732d8b186b0702ea748b375e4405799aa59cf2ae5459f99216f4,
        0x10fc55420be890b138082d746e66bf86f4efe8190cc83313a792dd156bc76e1f,
    )
}

#[test]
#[available_gas(99999999999999)]
fn exponentiation_compare() {
    let f12 = pair_result_12().final_exponentiation();
    let f21 = pair_result_21().final_exponentiation();

    assert(f12 != FieldUtils::one(), 'degenerate exponentiation');
    assert(f12 == f21, 'incorrect exponentiation');
}

#[test]
#[available_gas(100000000)]
fn pow_test() {
    let field_nz: NonZero<u256> = get_field_nz();
    let x = easy_result();
    let o = (false, false);
    let p = (true, true);
    let n = (true, false);
    let xpow = x.exp_naf(array![n, o, o, p], field_nz);
    let field_nz = get_field_nz();
    let expected = x.cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz).cyclotomic_sqr(field_nz) / x;
    assert(xpow == expected, 'incorrect pow');
}
