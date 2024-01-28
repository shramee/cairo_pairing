use core::array::ArrayTrait;
use debug::PrintTrait;
use bn::fields::{fq6, Fq12Ops};
use bn::fields::{TFqMul};


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
#[available_gas(9999999999)]
fn fq6_mul() {
    fq6(
        u256 { low: 0x92ea34e7ab3c5f45e320dce4e78e31f0, high: 0x16a0f457e9e5a182967194b495072648, },
        u256 { low: 0xc1aa80e099b3f3d00d173b577872724a, high: 0x2e5f0cf064853d632a87b1f224a25630, },
        u256 { low: 0x40b9eb18b0abbe13bf6e617db931b428, high: 0x26bdc613687cfede44049719719a3f9a, },
        u256 { low: 0x44ba68cd1d1cf66fbdd131ee411c49c3, high: 0x14c371d144d0e8082ff5d04d150b59cf, },
        u256 { low: 0x7f52b2f5dbea8ed01c1b50d5128eba2a, high: 0x1822f003203e7f204750d1d947595e33, },
        u256 { low: 0x72654ff860364dbc5fb06878fd05fa8a, high: 0xed19cb6f6eb68f8a859fd9db9cb1f0b, }
    )
        * fq6(
            u256 {
                low: 0x2a17d6a81755aeefdf5be5e6ddad999b, high: 0x139e570e21ba68063554f4a5a00f3bec,
            },
            u256 { low: 0x0, high: 0x0, },
            u256 {
                low: 0x706669c3e81343b6c76fec3fc0de0c2b, high: 0x1d31db1c85bb9edb1edc748b9e336cc5,
            },
            u256 {
                low: 0x7b3bef54996aa0e8f5ee3c5a9794847b, high: 0xddc1593c07761f8825b3fc005950ab1,
            },
            u256 { low: 0x0, high: 0x0, },
            u256 { low: 0x0, high: 0x0, }
        );
}
#[test]
#[available_gas(2000000)]
fn conv2() {
    let b: u32 = 1_felt252.try_into().unwrap();
}
