use bn::fields::fq_12_expo::FinalExponentiationTrait;
use bn::traits::FieldMulShortcuts;
use bn::traits::FieldShortcuts;
use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{
    fq, fq2, Fq2, fq12, Fq12, Fq6, fq6, Fq2MulShort, Fq2Ops, Fq2Short, Fq12Ops, Fq12FinalExpo,
    Fq2IntoU512Tuple
};
use bn::curve::{
    FIELD, u512, Tuple2Add, Tuple2Sub, U512BnAdd, U512BnSub, u512_sub_u256, u512_add, u512_sub
};
use bn::fields::fq_12_expo::{x2, x3, x4, X2, X3, X4, mul_by_xi,};
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
//     let _field_nz: NonZero<u256> = FIELD.try_into().unwrap();
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
//     // let _h2: (u512, u512) = X3(mul_by_xi(S4_5 - S4 - S5)).u512_add_fq(g2.u_add(g2));
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
    let a: Fq2 = a.to_fq(FIELD.try_into().unwrap());
    println!("\n\n{} {}", help, a);
}

#[test]
#[available_gas(200000000)]
fn krbn1235() {
    let field_nz: NonZero<u256> = FIELD.try_into().unwrap();
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
    let field_nz: NonZero<u256> = FIELD.try_into().unwrap();
    let a = a_cyc().krbn_compress_2345().sqr_krbn(field_nz);
    let (g2, g3, g4, g5,) = a;
    let (s2, s3, s4, s5,) = sqr().krbn_compress_2345();
    assert(g2 == s2, 'krbn1235 wrong g1');
    assert(g3 == s3, 'krbn1235 wrong g2');
    assert(g4 == s4, 'krbn1235 wrong g3');
    assert(g5 == s5, 'krbn1235 wrong g5');
}

#[test]
#[available_gas(200000000)]
fn krbn_experiments() {
    let field_nz: NonZero<u256> = FIELD.try_into().unwrap();

    // https://github.com/mratsim/constantine/blob/master/constantine/math/pairings/cyclotomic_subgroups.nim#L639
    // Karabina uses the cubic over quadratic representation
    // But we use the quadratic over cubic for Fq12 -> Fq6 -> Fq2
    // canonical <=> cubic over quadratic <=> quadratic over cubic
    //    c0     <=>        g0            <=>            b0
    //    c1     <=>        g2            <=>            b3
    //    c2     <=>        g4            <=>            b1
    //    c3     <=>        g1            <=>            b4
    //    c4     <=>        g3            <=>            b2
    //    c5     <=>        g5            <=>            b5
    let Fq12 { c0: Fq6 { c0: g0, c1: g4, c2: g3 }, c1: Fq6 { c0: g2, c1: g1, c2: g5 } } = a_cyc();
    let Fq12 { c0: Fq6 { c0: _s0, c1: _s4, c2: _s3 }, c1: Fq6 { c0: s2, c1: _s1, c2: _s5 } } =
        sqr();

    // // h1 = 3 * g3² + 3 * nr * g2² - 2 * g1
    // let h1 = g3.sqr().scale(fq(3)) + fq2(9, 1).scale(fq(3)) * g2.sqr() - g1 - g1;
    // assert(h1 == s1, 'base calc wrong');

    let _S0: (u512, u512) = g0.u_sqr();
    let _S1: (u512, u512) = g1.u_sqr();
    let _S2: (u512, u512) = g2.u_sqr();
    let _S3: (u512, u512) = g3.u_sqr();
    let S4: (u512, u512) = g4.u_sqr();
    let S5: (u512, u512) = g5.u_sqr();
    // let S4_5: (u512, u512) = g4.u_add(g5).u_sqr();
    let S4_5: (u512, u512) = (g4 + g5).u_sqr();

    // // 0235 h2
    // // h2 = 3 * nr * g5² + 3 * g1² - 2*g2
    // let h2 = X3(mul_by_xi(S5) + S1).u512_sub_fq(x2(g2));
    // let h2 = h2.to_fq(field_nz);
    // compare_fq2(s2, h2, "h2");
    // assert(h2 == s2, 'h2 0235 calc wrong');
    // // THIS WORKS

    // // h1 = 3 * g3² + 3 * nr * g2² - 2 * g1
    // let h1 = X3(S3 + mul_by_xi(S2)).u512_sub_fq(x2(g1));
    // assert(h1.to_fq(field_nz) == s1, 'h1 optim calc wrong');

    // h2 = 3 * nr * g5² + 3 * g1² - 2*g2
    // Potential bug with u512_sub_u256
    // let h2 = X3(mul_by_xi(S5) + S1).u512_sub_fq(x2(g2));

    // print_fq2(S4_5, "S4_5");

    // h2 = 3(S4_5 - S4 - S5)ξ + 2g2;
    let h2 = X3(mul_by_xi(S4_5 - S4 - S5)) + x2(g2).into();
    let h2 = h2.to_fq(field_nz);
    assert(h2 == s2, 'h2 2345 calc wrong');
}
// #[test]
// #[available_gas(50000000)]
// fn sqr_2345() {
//     let a = a_cyc();
//     let field_nz: NonZero<u256> = FIELD.try_into().unwrap();
//     let Fq12 { c0: Fq6 { c0: g0, c1: g1, c2: g2 }, c1: Fq6 { c0: g3, c1: g4, c2: g5 } } = a_cyc();
//     let Fq12 { c0: Fq6 { c0: s0, c1: s1, c2: s2 }, c1: Fq6 { c0: s3, c1: s4, c2: s5 } } = sqr();

//     let (a2, a3, a4, a5,) = a.krbn_compress_2345().sqr_krbn(field_nz);

//     println!("\n\nMatching a2? {} {} {}", s2 == a2, s2, a2);
//     println!("\n\nMatching a3? {} {} {}", s3 == a3, s3, a3);
//     println!("\n\nMatching a4? {} {} {}", s4 == a4, s4, a4);
//     println!("\n\nMatching a5? {} {} {}", s5 == a5, s5, a5);

//     assert(g4 == a4, 'incorrect k_sqr a4');
//     assert(g2 == a2, 'incorrect k_sqr a2');
//     assert(g3 == a3, 'incorrect k_sqr a3');
//     assert(g5 == a5, 'incorrect k_sqr a5');
// }
// #[test]
// #[available_gas(50000000)]
// fn expand_2345() {
//     let a = a_cyc();
//     let field_nz = FIELD.try_into().unwrap();
//     let asq = a.sqr();

//     let asq_decompressed = asq.krbn_compress_2345().krbn_decompress(field_nz);
//     assert(asq == asq_decompressed, 'incorrect krbn_decompress');
// }

// #[test]
// #[available_gas(50000000)]
// fn sqr_cyc() {
//     let a = a_cyc();
//     let field_nz = FIELD.try_into().unwrap();
//     assert(a.cyclotomic_sqr(field_nz) == sqr(), 'incorrect square');
// }

// h2 = 3(S4_5 − S4 − S5)ξ + 2a2;

// S4 ← a4 ×2 a4
// S5 ← a5 ×2 a5
// t0 ← a4 ⊕2 a5

// S4_5 ← t0 ×2 t0
// T3 ← S4 +2 S5
// T3 ← S4_5 ⊖2 T3 // S4_5 − S4 − S5

// t0 ← T3 mod2 p // reduced(S4_5 − S4 − S5)

// t1 ← ξ·t0 // (S4_5 − S4 − S5)ξ

// t0 ← t1 ⊕2 a2 // (S4_5 − S4 − S5)ξ + a2
// t0 ← t0 ⊕2 t0 // 2((S4_5 − S4 − S5)ξ + a2)

// c2 ← t0 ⊕2 t1 // 2((S4_5 − S4 − S5)ξ + a2) + (S4_5 − S4 − S5)ξ

// t1 ← a2 ⊕2 a3
// S2_3 ← t1 ×2 t1
// S2 ← a2 ×2 a2

// Input: a = (a2 +a3s)t+(a4 +a5s)t2 ∈ Gφ6(Fp2) Output: c = a2 = (c2 +c3s)t+(c4 +c5s)t2 ∈ Gφ6 (Fp2 ).

// T0 ← a4 ×2 a4
// T1 ← a5 ×2 a5
// t0 ← a4 ⊕2 a5

// T2 ← t0 ×2 t0
// T3 ← T0 +2 T1
// T3 ← T2 ⊖2 T3

// t0 ← T3 mod2 p
// t1 ← a2 ⊕2 a3
// T3 ← t1 ×2 t1
// T2 ← a2 ×2 a2

// t1← ξ·t0

// t0 ← t1 ⊕2 a2
// t0 ← t0 ⊕2 t0

// c2 ← t0 ⊕2 t1


