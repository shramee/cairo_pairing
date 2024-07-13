// [PASS] bn_ate::test::test_ate_miller_loop (gas: ~1) steps: 110

use super::{MillerRunner, ate_miller_loop};

#[derive(Drop)]
struct MockRunner {}

type MockAccumulator = felt252;

impl Miller_u256 of MillerRunner<(), MockRunner, MockAccumulator> {
    // first and second step, O and N
    fn miller_bit_1_2(
        ref self: (), runner: @MockRunner, i: (u32, u32), ref acc: MockAccumulator
    ) { //
        let (i1, i2) = i;
        self.miller_bit_o(runner, i1, ref acc);
        self.miller_bit_n(runner, i2, ref acc);
    }

    // 0 bit
    fn miller_bit_o(ref self: (), runner: @MockRunner, i: u32, ref acc: MockAccumulator) { //
        acc = acc + acc;
    }

    // 1 bit
    fn miller_bit_p(ref self: (), runner: @MockRunner, i: u32, ref acc: MockAccumulator) { //
        acc = acc + acc + 1;
    }

    // -1 bit
    fn miller_bit_n(ref self: (), runner: @MockRunner, i: u32, ref acc: MockAccumulator) { //
        acc = acc + acc - 1;
    }

    // last step
    fn miller_last(ref self: (), runner: @MockRunner, ref acc: MockAccumulator) { //
    // do nothing
    }
}

#[test]
fn test_ate_miller_loop() {
    let mut curve = ();
    let mut acc = 1;
    let res: MockAccumulator = ate_miller_loop(ref curve, MockRunner {}, acc);
    assert(res == 0x19d797039be763ba8, 'wrong value for 6u + 2');
}
