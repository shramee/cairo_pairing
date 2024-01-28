use core::array::ArrayTrait;
use debug::PrintTrait;

fn op<T, +Add<T>, +Sub<T>, +PartialEq<T>, +Drop<T>, impl ZeroImpl: core::num::traits::Zero<T>>(
    a: T, b: T
) {
    a + b;
}

#[test]
#[available_gas(2000000)]
fn high_u256_add() {
    let a = u256 {
        low: 0x14161690bda5dfade4724179b3f96e46, high: 0x8b363168a6ff4b516803a64b9b4e33f0,
    };
    let b = u256 {
        low: 0xe60c320b913d310bbebcc863312e0041, high: 0x842730e6172ac4dd02d437ff780e8a0b,
    };
    (a + b).print();
// assert(, '');
}

#[test]
#[available_gas(2000000)]
fn op_felt() {
    op(5, 2);
}

#[test]
#[available_gas(2000000)]
fn op_u8() {
    op(5_u8, 2_u8);
}

#[test]
#[available_gas(2000000)]
fn op_u128() {
    op(5_u128, 2_u128);
}

#[test]
#[available_gas(2000000)]
fn op_u256() {
    op(5_u256, 2_u256);
}

#[test]
#[available_gas(2000000)]
fn arr_play() {
    let mut arr: Array<u8> = array![1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

    arr.pop_front();

    (*arr[0]).print();
}

#[test]
#[available_gas(2000000)]
fn conv() {
    let a: felt252 = 1_u32.into();
}

#[test]
#[available_gas(2000000)]
fn conv2() {
    let b: u32 = 1_felt252.try_into().unwrap();
}
