// [PASS] bn_ate::test::test_ate_miller_loop (gas: ~1) steps: 110

use super::{MillerRunnerTrait, ate_miller_loop};

#[derive(Drop)]
struct MockRunner {
    acc: felt252,
}

impl Miller_u of MillerRunnerTrait<(), MockRunner> {
    // first and second step, O and N
    fn miller_bit_1_2(ref self: (), ref runner: MockRunner, i: (u32, u32)) { //
        let (i1, i2) = i;
        self.miller_bit_o(ref runner, i1);
        self.miller_bit_n(ref runner, i2);
    }

    // 0 bit
    fn miller_bit_o(ref self: (), ref runner: MockRunner, i: u32) { //
        runner.acc = runner.acc + runner.acc;
    }

    // 1 bit
    fn miller_bit_p(ref self: (), ref runner: MockRunner, i: u32) { //
        runner.acc = runner.acc + runner.acc + 1;
    }

    // -1 bit
    fn miller_bit_n(ref self: (), ref runner: MockRunner, i: u32) { //
        runner.acc = runner.acc + runner.acc - 1;
    }

    // last step
    fn miller_last(ref self: (), ref runner: MockRunner) { //
    // do nothing
    }
}

#[test]
fn test_ate_miller_loop() {
    let mut curve = ();
    let mut acc = 1;
    let mut runner = MockRunner { acc };
    ate_miller_loop(ref curve, ref runner);
    assert(runner.acc == 0x19d797039be763ba8, 'wrong value for 6u + 2');
}
