// [PASS] bn_ate::test::test_ate_miller_loop (gas: ~1) steps: 110

use super::{MillerRunner, ate_miller_loop};

#[derive(Drop)]
struct MockMillerRunner {}

type MockAccumulator = felt252;

impl Miller_u256 of MillerRunner<(), MockMillerRunner, MockAccumulator> {
    // first and second step, O and N
    fn bit_1st_2nd(
        self: @MockMillerRunner, ref curve: (), i1: u32, i2: u32, ref acc: MockAccumulator
    ) { //
        self.bit_o(ref curve, i1, ref acc);
        self.bit_n(ref curve, i2, ref acc);
    }

    // 0 bit
    fn bit_o(self: @MockMillerRunner, ref curve: (), i: u32, ref acc: MockAccumulator) { //
        acc = acc + acc;
    }

    // 1 bit
    fn bit_p(self: @MockMillerRunner, ref curve: (), i: u32, ref acc: MockAccumulator) { //
        acc = acc + acc;
        acc = acc + 1;
    }

    // -1 bit
    fn bit_n(self: @MockMillerRunner, ref curve: (), i: u32, ref acc: MockAccumulator) { //
        acc = acc + acc;
        acc = acc - 1;
    }

    // last step
    fn last(self: @MockMillerRunner, ref curve: (), ref acc: MockAccumulator) { //
    // do nothing
    }
}

#[test]
fn test_ate_miller_loop() {
    let mut curve = ();
    let mut acc = 1;
    let res: MockAccumulator = ate_miller_loop(ref curve, MockMillerRunner {}, ref acc);
    assert(res == 0x19d797039be763ba8, 'wrong value for 6u + 2');
}
