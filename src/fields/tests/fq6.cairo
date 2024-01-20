use bn::traits::{FieldOps, FieldUtils};
use bn::fields::{fq2, Fq6, fq6, Fq6Ops};
use bn::fields::fq_generics::{TFqAdd, TFqSub, TFqMul, TFqDiv, TFqNeg, TFqPartialEq,};
use bn::fields::print::{FqPrintImpl, Fq2PrintImpl, Fq6PrintImpl, Fq12PrintImpl};
use debug::PrintTrait;

// #[test]
// #[available_gas(5000000)]
// fn fq6_add_sub() {
//     let a = fq6(34, 645, 31, 55, 140, 105);
//     let b = fq6(25, 45, 11, 43, 86, 101);
//     let c = fq6(9, 600, 20, 12, 54, 4);
//     assert(a == b + c, 'incorrect add');
//     assert(b == a - c, 'incorrect sub');
// }

#[test]
#[available_gas(5000000)]
fn fq6_mul() {
    let a = fq6(34, 645, 20, 55, 140, 105);
    let c = fq6(9, 600, 31, 12, 54, 4);
    let (ab, bc) = {
        let b = fq6(25, 45, 11, 43, 86, 101);
        (a * b, b * c,)
    };
    let abc = ab * c;
// assert(ab * c == a * bc, 'incorrect mul');
}

// // #[test]
// // #[available_gas(5000000)]
// // fn fq6_div() {
// //     let a = fq6(34, 645, 20, 12, 54, 4);
// //     let b = fq6(25, 45, 11, 43, 86, 101);
// //     let c = a / b;
// //     assert(c * b == a, 'incorrect div');
// // }

// #[test]
// #[available_gas(50000000)]
// fn fq6_inv() {
//     let a = fq6(34, 645, 20, 12, 54, 4);
//     let b = fq6(25, 45, 11, 43, 86, 101);
//     let (a_inv, c, d): (Fq6, Fq6, Fq6,) = (
//         FieldUtils::one(), FieldUtils::one(), FieldUtils::one(),
//     );
//     let a_inv = FieldOps::inv(a);
//     // let (a_inv, c, d) = {
//     //     let a_inv = FieldOps::inv(a);
//     //     let c = a * a_inv;
//     //     let d = b * a_inv;
//     //     (a_inv, c, d)
//     // };

//     assert(c == FieldUtils::one(), 'incorrect inv');
//     // d * a;
//     {
//         assert(d * a == b, 'incorrect inv');
//     }
// }
#[test]
#[available_gas(5000000)]
fn fq6_sqr() {
    let a = fq6(34, 645, 20, 55, 140, 105);
    // assert(a * a == a.sqr(), 'incorrect square');
    assert(a * a == a.sqr(), 'incorrect square');
}

