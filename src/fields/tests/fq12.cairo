use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{fq12, Fq12, Fq6, fq6, Fq12Ops};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl, Fq6PrintImpl, Fq12PrintImpl};
use debug::PrintTrait;

fn a() -> Fq12 {
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

fn b() -> Fq12 {
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

fn axb() -> Fq12 {
    fq12(
        0x280d0beb03619826096b4b048e2abb1af592d3d56efa2dc7fd9ce4b9a5b0c1b7,
        0x116f1c822ef34231f506b9afd9edb357ce0adb6320f5f929e477df81198b309d,
        0x2a42bcd10a9b003bf1f8afd65cf2831d708322383d498a4a1bb3ae5c20a243eb,
        0x2a0819f95ecf7e8a4405e1e706726a638550b3b20eebb66b97804be88854e679,
        0x2b2cc91cb1e19ce8b66da51c7b08643286216118bb8e062e3827b8c1f6d74e7,
        0x214dcdee43ebc72e673cc19f993703e1ad1db17113f7ae41cbddd709380d184d,
        0x18aa857acdd6783733aae6be98bf7fa14ac053fbf6f042b35bedf374eb124084,
        0x16db5d26558eb13f21bb538eafdef3d71c7738a901361fe37b2b1632c0beca,
        0x1a79cd9802cd1685c7c387362a3f2cb31c96b59d100cb38c724ad70077dd940,
        0x19e48782b668248e46f48104f64925e8a67006556a09df165e2a0ad5c0bf1cb2,
        0x2b9d548b03eb32bac1bb1dd98188668cc01dc7afcf0de68b9f5a35c2ca16813b,
        0x18ff99c25f448b082571917c3f5d9b8c6b2ec2956103c0027dbedd72ecd16c6e,
    )
}

#[test]
#[available_gas(50000000)]
fn add_sub() {
    let a = fq12(34, 645, 31, 55, 140, 105, 2, 2, 2, 2, 2, 2);
    let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
    let c = fq12(9, 600, 20, 12, 54, 4, 1, 1, 1, 1, 1, 1);
    assert(a == b + c, 'incorrect add');
    assert(b == a - c, 'incorrect sub');
}

#[test]
#[available_gas(50000000)]
fn one() {
    let a = fq12(34, 645, 31, 55, 140, 105, 1, 1, 1, 1, 1, 1);
    let one = FieldUtils::one();
    assert(one * a == a, 'incorrect mul by 1');
}

#[test]
#[available_gas(50000000)]
fn sqr() {
    assert(a().sqr() == a() * a(), 'incorrect square');
}

#[test]
#[available_gas(50000000)]
fn mul() {
    assert(a() * b() == axb(), 'incorrect mul');
}

#[test]
#[available_gas(50000000)]
fn mul_assoc() {
    let a = a();
    let b = b();
    let c = axb();

    let ab = a * b;
    let bc = b * c;
    assert(ab * c == a * bc, 'incorrect mul');
}

#[test]
#[available_gas(50000000)]
fn div() {
    let a = fq12(34, 645, 31, 55, 140, 105, 1, 1, 1, 1, 1, 1);
    let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
    let c = a / b;
    assert(c * b == a, 'incorrect div');
}

#[test]
#[available_gas(50000000)]
fn inv() {
    let a = fq12(34, 645, 31, 55, 140, 105, 1, 1, 1, 1, 1, 1);
    let b = fq12(25, 45, 11, 43, 86, 101, 1, 1, 1, 1, 1, 1);
    let a_inv = FieldOps::inv(a);
    let c = a * a_inv;
    let d = b * a_inv;

    assert(c == FieldUtils::one(), 'incorrect inv');
    assert(d * a == b, 'incorrect inv');
}

