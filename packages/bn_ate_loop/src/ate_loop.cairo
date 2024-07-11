pub trait MillerRunner<TCurve, TRunner, TAccumulator> {
    // first and second step, O and N
    fn bit_1st_2nd(self: @TRunner, ref curve: TCurve, i1: u32, i2: u32, ref acc: TAccumulator);

    // 0 bit
    fn bit_o(self: @TRunner, ref curve: TCurve, i: u32, ref acc: TAccumulator);

    // 1 bit
    fn bit_p(self: @TRunner, ref curve: TCurve, i: u32, ref acc: TAccumulator);

    // -1 bit
    fn bit_n(self: @TRunner, ref curve: TCurve, i: u32, ref acc: TAccumulator);

    // last step
    fn last(self: @TRunner, ref curve: TCurve, ref acc: TAccumulator);
}

pub fn ate_miller_loop<
    TCurve,
    TRunner,
    TAccumulator,
    +MillerRunner<TCurve, TRunner, TAccumulator>,
    +Drop<TRunner>,
    +Drop<TCurve>
>(
    ref curve: TCurve, runner: TRunner, ref q_acc: TAccumulator
) -> TAccumulator {
    core::gas::withdraw_gas().unwrap();
    core::internal::revoke_ap_tracking();

    _loop_inner_1_of_2(@runner, ref curve, ref q_acc);
    _loop_inner_2_of_2(@runner, ref curve, ref q_acc);
}

pub fn _loop_inner_1_of_2<
    TCurve, TRunner, TAccumulator, +MillerRunner<TCurve, TRunner, TAccumulator>
>(
    runner: @TRunner, ref curve: TCurve, ref q_acc: TAccumulator
) {
    // ate_loop[64] = O and ate_loop[63] = N
    runner.bit_1st_2nd(ref curve, 64, 63, ref q_acc);
    runner.bit_o(ref curve, 62, ref q_acc); // ate_loop[62] = O
    runner.bit_p(ref curve, 61, ref q_acc); // ate_loop[61] = P
    runner.bit_o(ref curve, 60, ref q_acc); // ate_loop[60] = O
    runner.bit_o(ref curve, 59, ref q_acc); // ate_loop[59] = O
    runner.bit_o(ref curve, 58, ref q_acc); // ate_loop[58] = O
    runner.bit_n(ref curve, 57, ref q_acc); // ate_loop[57] = N
    runner.bit_o(ref curve, 56, ref q_acc); // ate_loop[56] = O
    runner.bit_n(ref curve, 55, ref q_acc); // ate_loop[55] = N
    runner.bit_o(ref curve, 54, ref q_acc); // ate_loop[54] = O
    runner.bit_o(ref curve, 53, ref q_acc); // ate_loop[53] = O
    runner.bit_o(ref curve, 52, ref q_acc); // ate_loop[52] = O
    runner.bit_n(ref curve, 51, ref q_acc); // ate_loop[51] = N
    runner.bit_o(ref curve, 50, ref q_acc); // ate_loop[50] = O
    runner.bit_p(ref curve, 49, ref q_acc); // ate_loop[49] = P
    runner.bit_o(ref curve, 48, ref q_acc); // ate_loop[48] = O
    runner.bit_n(ref curve, 47, ref q_acc); // ate_loop[47] = N
    runner.bit_o(ref curve, 46, ref q_acc); // ate_loop[46] = O
    runner.bit_o(ref curve, 45, ref q_acc); // ate_loop[45] = O
    runner.bit_n(ref curve, 44, ref q_acc); // ate_loop[44] = N
    runner.bit_o(ref curve, 43, ref q_acc); // ate_loop[43] = O
    runner.bit_o(ref curve, 42, ref q_acc); // ate_loop[42] = O
    runner.bit_o(ref curve, 41, ref q_acc); // ate_loop[41] = O
    runner.bit_o(ref curve, 40, ref q_acc); // ate_loop[40] = O
    runner.bit_o(ref curve, 39, ref q_acc); // ate_loop[39] = O
    runner.bit_p(ref curve, 38, ref q_acc); // ate_loop[38] = P
    runner.bit_o(ref curve, 37, ref q_acc); // ate_loop[37] = O
    runner.bit_o(ref curve, 36, ref q_acc); // ate_loop[36] = O
    runner.bit_n(ref curve, 35, ref q_acc); // ate_loop[35] = N
    runner.bit_o(ref curve, 34, ref q_acc); // ate_loop[34] = O
    runner.bit_p(ref curve, 33, ref q_acc); // ate_loop[33] = P
    runner.bit_o(ref curve, 32, ref q_acc); // ate_loop[32] = O
    runner.bit_o(ref curve, 31, ref q_acc); // ate_loop[31] = O
}

pub fn _loop_inner_2_of_2<
    TCurve, TRunner, TAccumulator, +MillerRunner<TCurve, TRunner, TAccumulator>
>(
    runner: @TRunner, ref curve: TCurve, ref q_acc: TAccumulator
) {
    runner.bit_n(ref curve, 30, ref q_acc); // ate_loop[30] = N
    runner.bit_o(ref curve, 29, ref q_acc); // ate_loop[29] = O
    runner.bit_o(ref curve, 28, ref q_acc); // ate_loop[28] = O
    runner.bit_o(ref curve, 27, ref q_acc); // ate_loop[27] = O
    runner.bit_o(ref curve, 26, ref q_acc); // ate_loop[26] = O
    runner.bit_n(ref curve, 25, ref q_acc); // ate_loop[25] = N
    runner.bit_o(ref curve, 24, ref q_acc); // ate_loop[24] = O
    runner.bit_p(ref curve, 23, ref q_acc); // ate_loop[23] = P
    runner.bit_o(ref curve, 22, ref q_acc); // ate_loop[22] = O
    runner.bit_o(ref curve, 21, ref q_acc); // ate_loop[21] = O
    runner.bit_o(ref curve, 20, ref q_acc); // ate_loop[20] = O
    runner.bit_n(ref curve, 19, ref q_acc); // ate_loop[19] = N
    runner.bit_o(ref curve, 18, ref q_acc); // ate_loop[18] = O
    runner.bit_n(ref curve, 17, ref q_acc); // ate_loop[17] = N
    runner.bit_o(ref curve, 16, ref q_acc); // ate_loop[16] = O
    runner.bit_o(ref curve, 15, ref q_acc); // ate_loop[15] = O
    runner.bit_p(ref curve, 14, ref q_acc); // ate_loop[14] = P
    runner.bit_o(ref curve, 13, ref q_acc); // ate_loop[13] = O
    runner.bit_o(ref curve, 12, ref q_acc); // ate_loop[12] = O
    runner.bit_o(ref curve, 11, ref q_acc); // ate_loop[11] = O
    runner.bit_n(ref curve, 10, ref q_acc); // ate_loop[10] = N
    runner.bit_o(ref curve, 9, ref q_acc); // ate_loop[ 9] = O
    runner.bit_o(ref curve, 8, ref q_acc); // ate_loop[ 8] = O
    runner.bit_n(ref curve, 7, ref q_acc); // ate_loop[ 7] = N
    runner.bit_o(ref curve, 6, ref q_acc); // ate_loop[ 6] = O
    runner.bit_p(ref curve, 5, ref q_acc); // ate_loop[ 5] = P
    runner.bit_o(ref curve, 4, ref q_acc); // ate_loop[ 4] = O
    runner.bit_p(ref curve, 3, ref q_acc); // ate_loop[ 3] = P
    runner.bit_o(ref curve, 2, ref q_acc); // ate_loop[ 2] = O
    runner.bit_o(ref curve, 1, ref q_acc); // ate_loop[ 1] = O
    runner.bit_o(ref curve, 0, ref q_acc); // ate_loop[ 0] = O
    runner.last(ref curve, ref q_acc);
}
