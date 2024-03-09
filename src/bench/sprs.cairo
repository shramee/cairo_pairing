use bn::fields::fq_sparse::FqSparseTrait;
use bn::fields::{fq, fq2, Fq2, fq12, Fq12, Fq6, fq6, Fq12Ops, Fq12Exponentiation,};
use bn::curve::{FIELD, u512,};
use bn::fields::{sparse_fq6, FqSparse, Fq6Sparse01, Fq12Sparse034, Fq12Sparse01234};

fn a_6() -> Fq6 {
    fq6(
        0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
        0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
        0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
        0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
        0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
        0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
    )
}

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

fn a_sparse_01234() -> Fq12Sparse01234 {
    let Fq6 { c0, c1, c2 } = a_6();
    let Fq12Sparse034 { c3, c4 } = a();
    Fq12Sparse01234 { c0, c1, c2, c3, c4 }
}

fn a() -> Fq12Sparse034 {
    Fq12Sparse034 {
        c3: fq2(
            0x2e3a5a8e0529c430c27e3673b9519767e265dcbcde8fea81cdd820918c4bd107,
            0xe6c5e3ec8c33c105e56e0ff3969bd92b2c4f6b05be655dcf21238f80c72030f
        ),
        c4: fq2(
            0x1b9732f816a94fa77048902ccb7ffc1ef433b2d95ebfad13030852e6e244b0b3,
            0x200ab6da30955b57dcc064deef9e4962ffa243efffd819010546fadaf591ef55
        ),
    }
}

fn b() -> Fq12Sparse034 {
    Fq12Sparse034 {
        c3: fq2(
            0x4d4df3e5d3bd9178d6a6c3a0654b542be46f209d956660c3605b9b4d5c8b8e0,
            0x4a86b2d0e408874533554f3c4071db92b6984030d5e7e4c6d6bbd3b84bd86b4
        ),
        c4: fq2(
            0x62ef6addea25e90cedd1bfab17d5dc57aed021a999e6c03eb1d83cd04246394,
            0x13dada4aebe86c7c07d4d5689172f885284aafe4e599d240735bf229fa3d823f
        ),
    }
}

#[test]
#[available_gas(20000000)]
fn s01_01() {
    let field_nz = FIELD.try_into().unwrap();
    let a = a();
    let a = sparse_fq6(a.c3, a.c4);
    let b = b();
    let b = sparse_fq6(b.c3, b.c4);
    b.mul_01_by_01(a, field_nz);
}

#[test]
#[available_gas(20000000)]
fn s01_fq6() {
    let field_nz = FIELD.try_into().unwrap();
    let a = a();
    let a = sparse_fq6(a.c3, a.c4);
    let b = a_6();
    b.u_mul_01(a, field_nz);
}

#[test]
#[available_gas(20000000)]
fn s034_034() {
    let field_nz = FIELD.try_into().unwrap();
    a().mul_034_by_034(b(), field_nz);
}

#[test]
#[available_gas(20000000)]
fn s034_fq12() {
    let field_nz = FIELD.try_into().unwrap();
    let a = a_12();
    a.mul_034(b(), field_nz);
}

#[test]
#[available_gas(200000000)]
fn s01234_fq12() {
    let field_nz = FIELD.try_into().unwrap();
    a_12().mul_01234(a_sparse_01234(), field_nz);
}

#[test]
#[available_gas(200000000)]
fn l1l2_f() {
    let field_nz = FIELD.try_into().unwrap();
    let f = a_12();
    let l1 = a();
    let l2 = b();
    f.mul_01234(l1.mul_034_by_034(l2, field_nz), field_nz);
}

#[test]
#[available_gas(200000000)]
fn l1f_l2f() {
    let field_nz = FIELD.try_into().unwrap();
    let f = a_12();
    let l1 = a();
    let l2 = b();
    f.mul_034(l1, field_nz).mul_034(l2, field_nz);
}
