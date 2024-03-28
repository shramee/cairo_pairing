use core::array::ArrayTrait;
use core::clone::Clone;
use core::traits::TryInto;
use bn::curve::{FIELD, get_field_nz};
use bn::fast_mod as f;
use f::u512;

use bn::curve::{U512BnAdd, Tuple2Add, U512BnSub, Tuple2Sub, mul_by_xi};
use bn::traits::{FieldOps, FieldUtils, FieldMulShortcuts};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::{Fq2, fq2, Fq2Ops, Fq2MulShort};
use debug::PrintTrait;

fn fq2_arr() -> Array<Fq2> {
    array![
        fq2(
            0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
            0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f
        ),
        fq2(
            0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
            0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb
        ),
        fq2(
            0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
            0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d
        ),
        fq2(
            0x2b7c8e0abca6a7476f0936f535c5e6469ad4b94f8f24c6f437f6d6686a1b381b,
            0x29679b4f134ab2b2e02d2c82a385b12d2ee2272a7e350fba6f80588c0e0afa13
        ),
        fq2(
            0x29163531c4ea85c647a9cd25e2de1433f12569f772eb83fcd8a997f3ca309cee,
            0x23bc9fb95fcf761320a0a287addd92dfaeb1ffc8bf8a943e703fc39f1e9d3085
        ),
        fq2(
            0x236942b30ace732d8b186b0702ea748b375e4405799aa59cf2ae5459f99216f4,
            0x10fc55420be890b138082d746e66bf86f4efe8190cc83313a792dd156bc76e1f
        ),
    ]
}

fn a() -> Fq2 {
    fq2(
        0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
        0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f
    )
}

fn b() -> Fq2 {
    fq2(
        0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
        0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb
    )
}

fn axb() -> Fq2 {
    fq2(
        0x23cc62ad7646c4f41c9ff2a7326bddac3e33094c2686b0eb7d508fe5729b060f,
        0x17b94d77eb36c29eefb15c11ecfc6c52878ff53fa7d83dbedc15ba4865ed0c5c
    )
}
#[test]
#[available_gas(2000000)]
fn add_sub() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    assert(a == b + c, 'incorrect add');
    assert(b == a - c, 'incorrect sub');
}

#[test]
#[available_gas(200000000)]
fn mul() {
    let a = a();
    let b = b();
    let ab = axb();
    assert(ab == a * b, 'incorrect mul');
}

#[test]
#[available_gas(200000000)]
fn mul_aggregate() {
    let arr = fq2_arr().span();

    let a = *arr.at(0);
    let b = *arr.at(1);
    let mut acc_sum = a * b;
    let mut acc_sum_u = a.u_mul(b);
    let mut acc_sub = a * b;
    let mut acc_sub_u = a.u_mul(b);
    let mut i = 0;
    loop {
        if i == 6 {
            break;
        }
        let mut j = i + 1;
        let a = *arr.at(i);

        loop {
            if j == 6 {
                break;
            }
            let b = *arr.at(j);
            let mu = a * b;
            acc_sum = acc_sum + mu;
            acc_sub = acc_sub - mu;
            let muu = a.u_mul(b);
            acc_sum_u = acc_sum_u + muu;
            acc_sub_u = acc_sub_u - muu;
            j += 1;
        };
        i += 1;
    };

    let field_nz = get_field_nz();
    assert(acc_sum_u.to_fq(field_nz) == acc_sum, 'incorrect mul');
    assert(acc_sub_u.to_fq(field_nz) == acc_sub, 'incorrect mul');
}

#[test]
#[available_gas(200000000)]
fn mul_assoc() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = fq2(9, 600);
    let ab = a * b;
    let C: (u512, u512) = a.u_mul(b);

    let field_nz = get_field_nz();
    assert(ab * c == a * (b * c), 'incorrect mul');
    assert(ab == C.to_fq(field_nz), 'incorrect u512 mul');
}

#[test]
#[available_gas(2000000)]
fn div() {
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let c = a / b;
    assert(c * b == a, 'incorrect div');
}

#[test]
#[available_gas(2000000)]
fn inv() {
    let field_nz = get_field_nz();
    let a = fq2(34, 645);
    let b = fq2(25, 45);
    let a_inv = FieldOps::inv(a, field_nz);
    let one = a * a_inv;
    let boa = b * a_inv;
    assert(one == FieldUtils::one(), 'incorrect inv');
    assert(boa * a == b, 'incorrect inv');

    let b_inv = FieldOps::inv(b, field_nz);
    let one = b * b_inv;
    let aob = a * b_inv;
    assert(one == FieldUtils::one(), 'incorrect inv');
    assert(aob * b == a, 'incorrect inv');
}

#[test]
#[available_gas(0xf0000)]
fn inv_one() {
    let one: Fq2 = FieldUtils::one();
    let one_inv = one.inv(get_field_nz());
    assert(one_inv == one, 'incorrect inverse of one');
}

#[test]
#[available_gas(5000000)]
fn sqr() {
    assert(a() * a() == a().sqr(), 'incorrect mul');
    assert(b() * b() == b().sqr(), 'incorrect mul');
}

#[test]
#[available_gas(5000000)]
fn non_residue() {
    let a_nr = a().mul_by_nonresidue();
    assert(a_nr == a() * fq2(9, 1), 'incorrect non_residue mul')
}

#[test]
#[available_gas(5000000)]
fn non_residue_u512() {
    let field_nz = get_field_nz();
    let AB = a().u_mul(b());
    let ab_xi = mul_by_xi(AB);
    let ab = a() * b();
    let ab_nr = ab.mul_by_nonresidue();
    assert(ab_nr == ab_xi.to_fq(field_nz), 'incorrect non_residue mul')
}
