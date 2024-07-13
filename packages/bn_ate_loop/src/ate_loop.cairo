pub trait MillerRunner<TCurve, TRunner, TAccumulator> {
    // first and second step, O and N
    fn miller_bit_1_2(ref self: TCurve, runner: @TRunner, i: (u32, u32), ref acc: TAccumulator);

    // 0 bit
    fn miller_bit_o(ref self: TCurve, runner: @TRunner, i: u32, ref acc: TAccumulator);

    // 1 bit
    fn miller_bit_p(ref self: TCurve, runner: @TRunner, i: u32, ref acc: TAccumulator);

    // -1 bit
    fn miller_bit_n(ref self: TCurve, runner: @TRunner, i: u32, ref acc: TAccumulator);

    // last step
    fn miller_last(ref self: TCurve, runner: @TRunner, ref acc: TAccumulator);
}

pub fn ate_miller_loop<
    TCurve,
    TRunner,
    TAccumulator,
    +MillerRunner<TCurve, TRunner, TAccumulator>,
    +Drop<TRunner>,
    +Drop<TCurve>
>(
    ref curve: TCurve, runner: TRunner, mut q_acc: TAccumulator
) -> TAccumulator {
    core::internal::revoke_ap_tracking();

    _loop_inner_1_of_2(@runner, ref curve, ref q_acc);
    _loop_inner_2_of_2(@runner, ref curve, ref q_acc);
    q_acc
}

pub fn _loop_inner_1_of_2<
    TCurve, TRunner, TAccumulator, +MillerRunner<TCurve, TRunner, TAccumulator>
>(
    runner: @TRunner, ref curve: TCurve, ref q_acc: TAccumulator
) {
    // ate_loop[64] = O and ate_loop[63] = N
    curve.miller_bit_1_2(runner, (64, 63), ref q_acc);
    curve.miller_bit_o(runner, 62, ref q_acc); // ate_loop[62] = O
    curve.miller_bit_p(runner, 61, ref q_acc); // ate_loop[61] = P
    curve.miller_bit_o(runner, 60, ref q_acc); // ate_loop[60] = O
    curve.miller_bit_o(runner, 59, ref q_acc); // ate_loop[59] = O
    curve.miller_bit_o(runner, 58, ref q_acc); // ate_loop[58] = O
    curve.miller_bit_n(runner, 57, ref q_acc); // ate_loop[57] = N
    curve.miller_bit_o(runner, 56, ref q_acc); // ate_loop[56] = O
    curve.miller_bit_n(runner, 55, ref q_acc); // ate_loop[55] = N
    curve.miller_bit_o(runner, 54, ref q_acc); // ate_loop[54] = O
    curve.miller_bit_o(runner, 53, ref q_acc); // ate_loop[53] = O
    curve.miller_bit_o(runner, 52, ref q_acc); // ate_loop[52] = O
    curve.miller_bit_n(runner, 51, ref q_acc); // ate_loop[51] = N
    curve.miller_bit_o(runner, 50, ref q_acc); // ate_loop[50] = O
    curve.miller_bit_p(runner, 49, ref q_acc); // ate_loop[49] = P
    curve.miller_bit_o(runner, 48, ref q_acc); // ate_loop[48] = O
    curve.miller_bit_n(runner, 47, ref q_acc); // ate_loop[47] = N
    curve.miller_bit_o(runner, 46, ref q_acc); // ate_loop[46] = O
    curve.miller_bit_o(runner, 45, ref q_acc); // ate_loop[45] = O
    curve.miller_bit_n(runner, 44, ref q_acc); // ate_loop[44] = N
    curve.miller_bit_o(runner, 43, ref q_acc); // ate_loop[43] = O
    curve.miller_bit_o(runner, 42, ref q_acc); // ate_loop[42] = O
    curve.miller_bit_o(runner, 41, ref q_acc); // ate_loop[41] = O
    curve.miller_bit_o(runner, 40, ref q_acc); // ate_loop[40] = O
    curve.miller_bit_o(runner, 39, ref q_acc); // ate_loop[39] = O
    curve.miller_bit_p(runner, 38, ref q_acc); // ate_loop[38] = P
    curve.miller_bit_o(runner, 37, ref q_acc); // ate_loop[37] = O
    curve.miller_bit_o(runner, 36, ref q_acc); // ate_loop[36] = O
    curve.miller_bit_n(runner, 35, ref q_acc); // ate_loop[35] = N
    curve.miller_bit_o(runner, 34, ref q_acc); // ate_loop[34] = O
    curve.miller_bit_p(runner, 33, ref q_acc); // ate_loop[33] = P
    curve.miller_bit_o(runner, 32, ref q_acc); // ate_loop[32] = O
    curve.miller_bit_o(runner, 31, ref q_acc); // ate_loop[31] = O
}

pub fn _loop_inner_2_of_2<
    TCurve, TRunner, TAccumulator, +MillerRunner<TCurve, TRunner, TAccumulator>
>(
    runner: @TRunner, ref curve: TCurve, ref q_acc: TAccumulator
) {
    curve.miller_bit_n(runner, 30, ref q_acc); // ate_loop[30] = N
    curve.miller_bit_o(runner, 29, ref q_acc); // ate_loop[29] = O
    curve.miller_bit_o(runner, 28, ref q_acc); // ate_loop[28] = O
    curve.miller_bit_o(runner, 27, ref q_acc); // ate_loop[27] = O
    curve.miller_bit_o(runner, 26, ref q_acc); // ate_loop[26] = O
    curve.miller_bit_n(runner, 25, ref q_acc); // ate_loop[25] = N
    curve.miller_bit_o(runner, 24, ref q_acc); // ate_loop[24] = O
    curve.miller_bit_p(runner, 23, ref q_acc); // ate_loop[23] = P
    curve.miller_bit_o(runner, 22, ref q_acc); // ate_loop[22] = O
    curve.miller_bit_o(runner, 21, ref q_acc); // ate_loop[21] = O
    curve.miller_bit_o(runner, 20, ref q_acc); // ate_loop[20] = O
    curve.miller_bit_n(runner, 19, ref q_acc); // ate_loop[19] = N
    curve.miller_bit_o(runner, 18, ref q_acc); // ate_loop[18] = O
    curve.miller_bit_n(runner, 17, ref q_acc); // ate_loop[17] = N
    curve.miller_bit_o(runner, 16, ref q_acc); // ate_loop[16] = O
    curve.miller_bit_o(runner, 15, ref q_acc); // ate_loop[15] = O
    curve.miller_bit_p(runner, 14, ref q_acc); // ate_loop[14] = P
    curve.miller_bit_o(runner, 13, ref q_acc); // ate_loop[13] = O
    curve.miller_bit_o(runner, 12, ref q_acc); // ate_loop[12] = O
    curve.miller_bit_o(runner, 11, ref q_acc); // ate_loop[11] = O
    curve.miller_bit_n(runner, 10, ref q_acc); // ate_loop[10] = N
    curve.miller_bit_o(runner, 9, ref q_acc); // ate_loop[ 9] = O
    curve.miller_bit_o(runner, 8, ref q_acc); // ate_loop[ 8] = O
    curve.miller_bit_n(runner, 7, ref q_acc); // ate_loop[ 7] = N
    curve.miller_bit_o(runner, 6, ref q_acc); // ate_loop[ 6] = O
    curve.miller_bit_p(runner, 5, ref q_acc); // ate_loop[ 5] = P
    curve.miller_bit_o(runner, 4, ref q_acc); // ate_loop[ 4] = O
    curve.miller_bit_p(runner, 3, ref q_acc); // ate_loop[ 3] = P
    curve.miller_bit_o(runner, 2, ref q_acc); // ate_loop[ 2] = O
    curve.miller_bit_o(runner, 1, ref q_acc); // ate_loop[ 1] = O
    curve.miller_bit_o(runner, 0, ref q_acc); // ate_loop[ 0] = O
    curve.miller_last(runner, ref q_acc);
}
