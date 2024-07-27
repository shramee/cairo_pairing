use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{fq2, Fq6, fq6, Fq6Ops, Fq6Short, Fq6MulShort};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl, Fq6PrintImpl};
use bn::curve::{FIELD, get_field_nz};
use debug::PrintTrait;

fn a() -> Fq6 {
    fq6(
        0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
        0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
        0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
        0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
        0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
        0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
    )
}

fn b() -> Fq6 {
    fq6(
        0x2b7c8e0abca6a7476f0936f535c5e6469ad4b94f8f24c6f437f6d6686a1b381b,
        0x29679b4f134ab2b2e02d2c82a385b12d2ee2272a7e350fba6f80588c0e0afa13,
        0x29163531c4ea85c647a9cd25e2de1433f12569f772eb83fcd8a997f3ca309cee,
        0x23bc9fb95fcf761320a0a287addd92dfaeb1ffc8bf8a943e703fc39f1e9d3085,
        0x236942b30ace732d8b186b0702ea748b375e4405799aa59cf2ae5459f99216f4,
        0x10fc55420be890b138082d746e66bf86f4efe8190cc83313a792dd156bc76e1f,
    )
}

fn axb() -> Fq6 {
    fq6(
        0xbfeb37fb64e03914633df70db09b1bd7be88240f8f4ee932d4a8d56dd961627,
        0x2b794f769a8f0d854db4cfc9f184811229f5b4e1b883d0399d3613d988e17b05,
        0x275176c1f711ba03b7389139314db48f3a0ac302ca06c16f148d56e1f2877a,
        0x840ff93ffb3898732439abc2f0181a6172e7e794850fe1266d2076aaf73bd7c,
        0x1f2f4cbca8f684335eb023833712cf1e41fa2cc42dec08ce4da35810d28549d2,
        0xcbf9f818699aaf7f31d5703c8e3468b2b49bcfc145c204223661bee56d217
    )
}

fn fq6_with_issue() -> Fq6 {
    // fq6(
    //     0xe8d05700cbaab93b441c09983f3685aef9224168ff238592f258563ac99832e,
    //     0x256e979abb0949c663912f0c94c783083b2f9aef60eed3874f0c05b509ece77e,
    //     0x136422ebea152069595d9a5c34c2555c1a73d633dec2ab3948a2d9032aa35902,
    //     0x59fa24a21586beb933cef7182d9fd408e2a6b073d2b3a864b1e22d15715d92a,
    //     0x9b3a0af3cb4d116007cd0403ff969c4394dec287e28978a789a9201f5f349d1,
    //     0x13f5161a12c927da1cd9c1e93f74f171464863e6a3c5eb97477a0d4ec77033d5
    // )
    fq6(
        0xbfacc92c92431c069df3a3b2e4bc81b7c5c48a45cf04f601d2cd65732729d51,
        0x298580f69115463837b2ef9be7f010b43853f38f6a2377498ca726d2a8525577,
        0x6c5640eaaa11a66ffd4c16d45e4b56ae7fcb32b863d844074ecae02d9c69733,
        0x11a2d812bbd400ad3785d75ca26ff0ba1f18c3d7aa2d4a47f8e640272a0a6e05,
        0x9782d0b27035aa1fb4b67c6c1ba49279aec08798044cb78748b1a7d6dfddfff,
        0x2e864adc49640c05e1940de8011858fb5fd1abf52c5b941d46ec7717a50fbd9c
    )
}

#[test]
#[available_gas(500000000)]
fn add_sub() {
    let a = fq6(34, 645, 31, 55, 140, 105);
    let b = fq6(25, 45, 11, 43, 86, 101);
    let c = fq6(9, 600, 20, 12, 54, 4);
    assert(a == b + c, 'incorrect add');
    assert(b == a - c, 'incorrect sub');
}

#[test]
#[available_gas(500000000)]
fn one() {
    let a = fq6(34, 645, 20, 55, 140, 105);
    let one = FieldUtils::one();
    assert(one * a == a, 'incorrect mul by 1');
}

#[test]
#[available_gas(500000000)]
fn sqr() {
    let a = fq6_with_issue();
    assert(a * a == a.sqr(), 'incorrect square');
}

#[test]
#[available_gas(500000000)]
fn mul() {
    let a = a();
    let b = b();
    let ab = axb();

    assert(a * b == ab, 'incorrect mul');
}

#[test]
#[available_gas(500000000)]
fn mul_assoc() {
    let a = a();
    let b = b();
    let c = fq6(9, 600, 31, 12, 54, 4);

    let ab = a * b;
    let bc = b * c;
    assert(ab * c == a * bc, 'incorrect mul');
}

#[test]
#[available_gas(500000000)]
fn div() {
    let a = fq6(34, 645, 20, 12, 54, 4);
    let b = fq6(25, 45, 11, 43, 86, 101);
    let c = a / b;
    assert(c * b == a, 'incorrect div');
}

#[test]
#[available_gas(500000000)]
fn inv() {
    core::internal::revoke_ap_tracking();
    let b_inv = b().inv(get_field_nz());
    let one = b() * b_inv;
    assert(one == FieldUtils::one(), 'incorrect inv 1');
    let aob = a() * b_inv;
    assert(aob * b() == a(), 'incorrect inv mul');
}
