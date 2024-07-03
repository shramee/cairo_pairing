// [PASS] bn_ate::test::test_ate_miller_loop (gas: ~1) steps: 110

use super::{MillerRunner, ate_miller_loop};

#[derive(Drop)]
struct MockMillerRunner {}

type MockAccumulator = felt252;

impl Miller_u256 of MillerRunner<MockMillerRunner, MockAccumulator> {
    // Returns accumulator
    fn accumulator(self: @MockMillerRunner) -> MockAccumulator {
        1
    }

    // Square target group element
    fn sqr_target(self: @MockMillerRunner, i: u32, ref acc: MockAccumulator) { //
        acc = acc + acc;
    }

    // first and second step, O and N
    fn bit_1st_2nd(self: @MockMillerRunner, i1: u32, i2: u32, ref acc: MockAccumulator) { //
        self.sqr_target(i1, ref acc);
        self.bit_o(i1, ref acc);
        self.sqr_target(i2, ref acc);
        self.bit_n(i2, ref acc);
    }

    // 0 bit
    fn bit_o(self: @MockMillerRunner, i: u32, ref acc: MockAccumulator) { //
    // do nothing
    }

    // 1 bit
    fn bit_p(self: @MockMillerRunner, i: u32, ref acc: MockAccumulator) { //
        acc = acc + 1;
    }

    // -1 bit
    fn bit_n(self: @MockMillerRunner, i: u32, ref acc: MockAccumulator) { //
        acc = acc - 1;
    }

    // last step
    fn last(self: @MockMillerRunner, ref acc: MockAccumulator) { //
    // do nothing
    }
}

#[test]
fn test_ate_miller_loop() {
    let res: MockAccumulator = ate_miller_loop(MockMillerRunner {});
    assert(res == 0x19d797039be763ba8, 'wrong value for 6u + 2');
}