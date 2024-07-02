#[cfg(test)]
mod test;

pub trait MillerRunner<TRunner, TAccumulator> {
    // Returns accumulator
    fn accumulator(self: @TRunner) -> TAccumulator;

    // Square target group element
    fn sqr_target(self: @TRunner, i: u32, ref acc: TAccumulator);

    // first and second step, O and N
    fn bit_1st_2nd(self: @TRunner, i1: u32, i2: u32, ref acc: TAccumulator);

    // 0 bit
    fn bit_o(self: @TRunner, i: u32, ref acc: TAccumulator);

    // 1 bit
    fn bit_p(self: @TRunner, i: u32, ref acc: TAccumulator);

    // -1 bit
    fn bit_n(self: @TRunner, i: u32, ref acc: TAccumulator);

    // last step
    fn last(self: @TRunner, ref acc: TAccumulator);
}

fn ate_miller_loop<TRunner, TAccumulator, +MillerRunner<TRunner, TAccumulator>, +Drop<TRunner>>(
    runner: TRunner
) -> TAccumulator {
    core::gas::withdraw_gas().unwrap();
    core::internal::revoke_ap_tracking();

    // Get accumulator from runner
    let mut q_acc: TAccumulator = runner.accumulator();

    ate_miller_loop_steps_first_half(@runner, ref q_acc);
    ate_miller_loop_steps_second_half(@runner, ref q_acc);
    q_acc
}

fn ate_miller_loop_steps_first_half<TRunner, TAccumulator, +MillerRunner<TRunner, TAccumulator>>(
    runner: @TRunner, ref q_acc: TAccumulator
) {
    // ate_loop[64] = O and ate_loop[63] = N
    runner.bit_1st_2nd(64, 63, ref q_acc);
    runner.sqr_target(62, ref q_acc);
    runner.bit_o(62, ref q_acc); // ate_loop[62] = O
    runner.sqr_target(61, ref q_acc);
    runner.bit_p(61, ref q_acc); // ate_loop[61] = P
    runner.sqr_target(60, ref q_acc);
    runner.bit_o(60, ref q_acc); // ate_loop[60] = O
    runner.sqr_target(59, ref q_acc);
    runner.bit_o(59, ref q_acc); // ate_loop[59] = O
    runner.sqr_target(58, ref q_acc);
    runner.bit_o(58, ref q_acc); // ate_loop[58] = O
    runner.sqr_target(57, ref q_acc);
    runner.bit_n(57, ref q_acc); // ate_loop[57] = N
    runner.sqr_target(56, ref q_acc);
    runner.bit_o(56, ref q_acc); // ate_loop[56] = O
    runner.sqr_target(55, ref q_acc);
    runner.bit_n(55, ref q_acc); // ate_loop[55] = N
    runner.sqr_target(54, ref q_acc);
    runner.bit_o(54, ref q_acc); // ate_loop[54] = O
    runner.sqr_target(53, ref q_acc);
    runner.bit_o(53, ref q_acc); // ate_loop[53] = O
    runner.sqr_target(52, ref q_acc);
    runner.bit_o(52, ref q_acc); // ate_loop[52] = O
    runner.sqr_target(51, ref q_acc);
    runner.bit_n(51, ref q_acc); // ate_loop[51] = N
    runner.sqr_target(50, ref q_acc);
    runner.bit_o(50, ref q_acc); // ate_loop[50] = O
    runner.sqr_target(49, ref q_acc);
    runner.bit_p(49, ref q_acc); // ate_loop[49] = P
    runner.sqr_target(48, ref q_acc);
    runner.bit_o(48, ref q_acc); // ate_loop[48] = O
    runner.sqr_target(47, ref q_acc);
    runner.bit_n(47, ref q_acc); // ate_loop[47] = N
    runner.sqr_target(46, ref q_acc);
    runner.bit_o(46, ref q_acc); // ate_loop[46] = O
    runner.sqr_target(45, ref q_acc);
    runner.bit_o(45, ref q_acc); // ate_loop[45] = O
    runner.sqr_target(44, ref q_acc);
    runner.bit_n(44, ref q_acc); // ate_loop[44] = N
    runner.sqr_target(43, ref q_acc);
    runner.bit_o(43, ref q_acc); // ate_loop[43] = O
    runner.sqr_target(42, ref q_acc);
    runner.bit_o(42, ref q_acc); // ate_loop[42] = O
    runner.sqr_target(41, ref q_acc);
    runner.bit_o(41, ref q_acc); // ate_loop[41] = O
    runner.sqr_target(40, ref q_acc);
    runner.bit_o(40, ref q_acc); // ate_loop[40] = O
    runner.sqr_target(39, ref q_acc);
    runner.bit_o(39, ref q_acc); // ate_loop[39] = O
    runner.sqr_target(38, ref q_acc);
    runner.bit_p(38, ref q_acc); // ate_loop[38] = P
    runner.sqr_target(37, ref q_acc);
    runner.bit_o(37, ref q_acc); // ate_loop[37] = O
    runner.sqr_target(36, ref q_acc);
    runner.bit_o(36, ref q_acc); // ate_loop[36] = O
    runner.sqr_target(35, ref q_acc);
    runner.bit_n(35, ref q_acc); // ate_loop[35] = N
    runner.sqr_target(34, ref q_acc);
    runner.bit_o(34, ref q_acc); // ate_loop[34] = O
    runner.sqr_target(33, ref q_acc);
    runner.bit_p(33, ref q_acc); // ate_loop[33] = P
    runner.sqr_target(32, ref q_acc);
    runner.bit_o(32, ref q_acc); // ate_loop[32] = O
    runner.sqr_target(31, ref q_acc);
    runner.bit_o(31, ref q_acc); // ate_loop[31] = O
}

fn ate_miller_loop_steps_second_half<TRunner, TAccumulator, +MillerRunner<TRunner, TAccumulator>>(
    runner: @TRunner, ref q_acc: TAccumulator
) {
    runner.sqr_target(30, ref q_acc);
    runner.bit_n(30, ref q_acc); // ate_loop[30] = N
    runner.sqr_target(29, ref q_acc);
    runner.bit_o(29, ref q_acc); // ate_loop[29] = O
    runner.sqr_target(28, ref q_acc);
    runner.bit_o(28, ref q_acc); // ate_loop[28] = O
    runner.sqr_target(27, ref q_acc);
    runner.bit_o(27, ref q_acc); // ate_loop[27] = O
    runner.sqr_target(26, ref q_acc);
    runner.bit_o(26, ref q_acc); // ate_loop[26] = O
    runner.sqr_target(25, ref q_acc);
    runner.bit_n(25, ref q_acc); // ate_loop[25] = N
    runner.sqr_target(24, ref q_acc);
    runner.bit_o(24, ref q_acc); // ate_loop[24] = O
    runner.sqr_target(23, ref q_acc);
    runner.bit_p(23, ref q_acc); // ate_loop[23] = P
    runner.sqr_target(22, ref q_acc);
    runner.bit_o(22, ref q_acc); // ate_loop[22] = O
    runner.sqr_target(21, ref q_acc);
    runner.bit_o(21, ref q_acc); // ate_loop[21] = O
    runner.sqr_target(20, ref q_acc);
    runner.bit_o(20, ref q_acc); // ate_loop[20] = O
    runner.sqr_target(19, ref q_acc);
    runner.bit_n(19, ref q_acc); // ate_loop[19] = N
    runner.sqr_target(18, ref q_acc);
    runner.bit_o(18, ref q_acc); // ate_loop[18] = O
    runner.sqr_target(17, ref q_acc);
    runner.bit_n(17, ref q_acc); // ate_loop[17] = N
    runner.sqr_target(16, ref q_acc);
    runner.bit_o(16, ref q_acc); // ate_loop[16] = O
    runner.sqr_target(15, ref q_acc);
    runner.bit_o(15, ref q_acc); // ate_loop[15] = O
    runner.sqr_target(14, ref q_acc);
    runner.bit_p(14, ref q_acc); // ate_loop[14] = P
    runner.sqr_target(13, ref q_acc);
    runner.bit_o(13, ref q_acc); // ate_loop[13] = O
    runner.sqr_target(12, ref q_acc);
    runner.bit_o(12, ref q_acc); // ate_loop[12] = O
    runner.sqr_target(11, ref q_acc);
    runner.bit_o(11, ref q_acc); // ate_loop[11] = O
    runner.sqr_target(10, ref q_acc);
    runner.bit_n(10, ref q_acc); // ate_loop[10] = N
    runner.sqr_target(9, ref q_acc);
    runner.bit_o(9, ref q_acc); // ate_loop[ 9] = O
    runner.sqr_target(8, ref q_acc);
    runner.bit_o(8, ref q_acc); // ate_loop[ 8] = O
    runner.sqr_target(7, ref q_acc);
    runner.bit_n(7, ref q_acc); // ate_loop[ 7] = N
    runner.sqr_target(6, ref q_acc);
    runner.bit_o(6, ref q_acc); // ate_loop[ 6] = O
    runner.sqr_target(5, ref q_acc);
    runner.bit_p(5, ref q_acc); // ate_loop[ 5] = P
    runner.sqr_target(4, ref q_acc);
    runner.bit_o(4, ref q_acc); // ate_loop[ 4] = O
    runner.sqr_target(3, ref q_acc);
    runner.bit_p(3, ref q_acc); // ate_loop[ 3] = P
    runner.sqr_target(2, ref q_acc);
    runner.bit_o(2, ref q_acc); // ate_loop[ 2] = O
    runner.sqr_target(1, ref q_acc);
    runner.bit_o(1, ref q_acc); // ate_loop[ 1] = O
    runner.sqr_target(0, ref q_acc);
    runner.bit_o(0, ref q_acc); // ate_loop[ 0] = O
    runner.last(ref q_acc);
}
