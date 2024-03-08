use bn::traits::FieldMulShortcuts;
use bn::fields::fq_sparse::FqSparseTrait;
use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{fq, fq2, Fq2, fq12, Fq12, Fq6, fq6, Fq12Ops, Fq12Exponentiation,};
use bn::curve::{FIELD, u512,};
use bn::fields::{FqSparse, Fq6Sparse01, Fq12Sparse034, Fq12Sparse01234, sparse_fq6};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{Fq12Display, Fq2Display};
use debug::PrintTrait;


const N0: u256 = 0x2e3a5a8e0529c430c27e3673b9519767e265dcbcde8fea81cdd820918c4bd107;
const N1: u256 = 0xe6c5e3ec8c33c105e56e0ff3969bd92b2c4f6b05be655dcf21238f80c72030f;
const N2: u256 = 0x1b9732f816a94fa77048902ccb7ffc1ef433b2d95ebfad13030852e6e244b0b3;
const N3: u256 = 0x200ab6da30955b57dcc064deef9e4962ffa243efffd819010546fadaf591ef55;
const N4: u256 = 0x4d4df3e5d3bd9178d6a6c3a0654b542be46f209d956660c3605b9b4d5c8b8e0;
const N5: u256 = 0x4a86b2d0e408874533554f3c4071db92b6984030d5e7e4c6d6bbd3b84bd86b4;
const N6: u256 = 0x62ef6addea25e90cedd1bfab17d5dc57aed021a999e6c03eb1d83cd04246394;
const N7: u256 = 0x13dada4aebe86c7c07d4d5689172f885284aafe4e599d240735bf229fa3d823f;
const N8: u256 = 0x122268beeda258f397785a4150e7557a7621ee6162d05a27ace4f719f6b0c035;
const N9: u256 = 0x30190d0f16d7222c83db31cd4bff91a51d2b1991b7a177459a06d4e50cae2448;
const N10: u256 = 0xee6ccfeef156e1a3f34f7b5629b518389bc49197bacf5aa1c438139fd24df10;
const N11: u256 = 0x270c8d4ba7c1f3e200ab9a1123a1ecb1cd6b8cd2c8c92601210007b6759f7351;

fn a_12() -> Fq12 {
    fq12(
        //30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
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

// Sparse 034 element contains only c3 and c4 Fq2s (c0 is 1)
// Equivalent to,
// Fq12{
//   c0: Fq6{c0: 1, c1: 0, c2: 0},
//   c1: Fq6{c0: c3, c1: c4, c2: 0},
// }
fn set_a() -> (Fq12, Fq12Sparse034) {
    (
        fq12(1, 0, 0, 0, 0, 0, N0, N1, N2, N3, 0, 0),
        Fq12Sparse034 { c3: fq2(N0, N1), c4: fq2(N2, N3), }
    )
}

fn set_b() -> (Fq12, Fq12Sparse034) {
    (
        fq12(1, 0, 0, 0, 0, 0, N4, N5, N6, N7, 0, 0),
        Fq12Sparse034 { c3: fq2(N4, N5), c4: fq2(N6, N7), }
    )
}

#[test]
#[available_gas(200000000)]
fn s01_mul_01() {
    let field_nz = FIELD.try_into().unwrap();
    let (Fq12 { c0: _, c1: a }, a_s) = set_a();
    let a_s = sparse_fq6(a_s.c3, a_s.c4);
    let (Fq12 { c0: _, c1: b }, b_s) = set_b();
    let _b_s = sparse_fq6(b_s.c3, b_s.c4);
    let c = a * b;
    let c_s: Fq6 = b.u_mul_01(a_s, field_nz).to_fq(field_nz);
    assert(c == c_s, 'mul0101 incorrect failed');
}

#[test]
#[available_gas(200000000)]
fn fq6_mul_01() {
    let field_nz = FIELD.try_into().unwrap();
    let (Fq12 { c0: _, c1: a }, a_s) = set_a();
    let a_s = sparse_fq6(a_s.c3, a_s.c4);
    let Fq12 { c0: b, c1: _ } = a_12();
    let c = a * b;
    let c_s: Fq6 = b.u_mul_01(a_s, field_nz).to_fq(field_nz);
    // for c0 to c4
    // println!("{}", c);
    // println!("{}{}{}{}{}", c_s.c0, c_s.c1, c_s.c2, c_s.c3, c_s.c4);
    assert(c.c0 == c_s.c0, 'mul034034 c0 failed');
    assert(c.c1 == c_s.c1, 'mul034034 c1 failed');
    assert(c.c2 == c_s.c2, 'mul034034 c2 failed');
}

#[test]
#[available_gas(200000000)]
fn s034_mul_034() {
    let field_nz = FIELD.try_into().unwrap();
    let (a, a_s) = set_a();
    let (b, b_s) = set_b();
    let c = a * b;
    let c_s = a_s.mul_034_by_034(b_s, field_nz);
    // for c0 to c4
    // println!("{}", c);
    // println!("{}{}{}{}{}", c_s.c0, c_s.c1, c_s.c2, c_s.c3, c_s.c4);
    assert(c.c0.c0 == c_s.c0, 'mul034034 c0 failed');
    assert(c.c0.c1 == c_s.c1, 'mul034034 c1 failed');
    assert(c.c0.c2 == c_s.c2, 'mul034034 c2 failed');
    assert(c.c1.c0 == c_s.c3, 'mul034034 c3 failed');
    assert(c.c1.c1 == c_s.c4, 'mul034034 c4 failed');
}

#[test]
#[available_gas(200000000)]
fn fq12_mul_034() {
    let field_nz = FIELD.try_into().unwrap();
    let a = a_12();
    let (b, b_s) = set_b();
    let c = a * b;
    let c_s = a.mul_034(b_s, field_nz);
    // for c0 to c4
    // println!("{}", c);
    assert(c.c0.c0 == c_s.c0.c0, 'mul034034 c0.c0 failed');
    assert(c.c0.c1 == c_s.c0.c1, 'mul034034 c0.c1 failed');
    assert(c.c0.c2 == c_s.c0.c2, 'mul034034 c0.c2 failed');
    assert(c.c1.c0 == c_s.c1.c0, 'mul034034 c1.c0 failed');
    assert(c.c1.c1 == c_s.c1.c1, 'mul034034 c1.c1 failed');
    assert(c.c1.c2 == c_s.c1.c2, 'mul034034 c1.c2 failed');
}
