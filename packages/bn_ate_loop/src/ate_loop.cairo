pub trait MillerRunner<TCurve, TRunner> {
    // first and second step, O and N
    fn miller_bit_1_2(ref self: TCurve, ref runner: TRunner, i: (u32, u32));

    // 0 bit
    fn miller_bit_o(ref self: TCurve, ref runner: TRunner, i: u32);

    // 1 bit
    fn miller_bit_p(ref self: TCurve, ref runner: TRunner, i: u32);

    // -1 bit
    fn miller_bit_n(ref self: TCurve, ref runner: TRunner, i: u32);

    // last step
    fn miller_last(ref self: TCurve, ref runner: TRunner);
}

pub fn ate_miller_loop<
    TCurve, TRunner, +MillerRunner<TCurve, TRunner>, +Drop<TRunner>, +Drop<TCurve>
>(
    ref curve: TCurve, ref runner: TRunner
) {
    core::internal::revoke_ap_tracking();

    _loop_inner_1_of_2(ref runner, ref curve);
    _loop_inner_2_of_2(ref runner, ref curve);
}

pub fn _loop_inner_1_of_2<TCurve, TRunner, +MillerRunner<TCurve, TRunner>>(
    ref runner: TRunner, ref curve: TCurve
) {
    core::internal::revoke_ap_tracking();
    // ate_loop[64] = O and ate_loop[63] = N
    curve.miller_bit_1_2(ref runner, (64, 63));
    curve.miller_bit_o(ref runner, 62); // ate_loop[62] = O
    curve.miller_bit_p(ref runner, 61); // ate_loop[61] = P
    curve.miller_bit_o(ref runner, 60); // ate_loop[60] = O
    curve.miller_bit_o(ref runner, 59); // ate_loop[59] = O
    curve.miller_bit_o(ref runner, 58); // ate_loop[58] = O
    curve.miller_bit_n(ref runner, 57); // ate_loop[57] = N
    curve.miller_bit_o(ref runner, 56); // ate_loop[56] = O
    curve.miller_bit_n(ref runner, 55); // ate_loop[55] = N
    curve.miller_bit_o(ref runner, 54); // ate_loop[54] = O
    curve.miller_bit_o(ref runner, 53); // ate_loop[53] = O
    curve.miller_bit_o(ref runner, 52); // ate_loop[52] = O
    curve.miller_bit_n(ref runner, 51); // ate_loop[51] = N
    core::internal::revoke_ap_tracking();
    curve.miller_bit_o(ref runner, 50); // ate_loop[50] = O
    curve.miller_bit_p(ref runner, 49); // ate_loop[49] = P
    curve.miller_bit_o(ref runner, 48); // ate_loop[48] = O
    curve.miller_bit_n(ref runner, 47); // ate_loop[47] = N
    curve.miller_bit_o(ref runner, 46); // ate_loop[46] = O
    curve.miller_bit_o(ref runner, 45); // ate_loop[45] = O
    curve.miller_bit_n(ref runner, 44); // ate_loop[44] = N
    curve.miller_bit_o(ref runner, 43); // ate_loop[43] = O
    curve.miller_bit_o(ref runner, 42); // ate_loop[42] = O
    curve.miller_bit_o(ref runner, 41); // ate_loop[41] = O
    curve.miller_bit_o(ref runner, 40); // ate_loop[40] = O
    curve.miller_bit_o(ref runner, 39); // ate_loop[39] = O
    curve.miller_bit_p(ref runner, 38); // ate_loop[38] = P
    curve.miller_bit_o(ref runner, 37); // ate_loop[37] = O
    curve.miller_bit_o(ref runner, 36); // ate_loop[36] = O
    curve.miller_bit_n(ref runner, 35); // ate_loop[35] = N
    curve.miller_bit_o(ref runner, 34); // ate_loop[34] = O
    curve.miller_bit_p(ref runner, 33); // ate_loop[33] = P
    curve.miller_bit_o(ref runner, 32); // ate_loop[32] = O
    curve.miller_bit_o(ref runner, 31); // ate_loop[31] = O
}

pub fn _loop_inner_2_of_2<TCurve, TRunner, +MillerRunner<TCurve, TRunner>>(
    ref runner: TRunner, ref curve: TCurve
) {
    core::internal::revoke_ap_tracking();
    curve.miller_bit_n(ref runner, 30); // ate_loop[30] = N
    curve.miller_bit_o(ref runner, 29); // ate_loop[29] = O
    curve.miller_bit_o(ref runner, 28); // ate_loop[28] = O
    curve.miller_bit_o(ref runner, 27); // ate_loop[27] = O
    curve.miller_bit_o(ref runner, 26); // ate_loop[26] = O
    curve.miller_bit_n(ref runner, 25); // ate_loop[25] = N
    curve.miller_bit_o(ref runner, 24); // ate_loop[24] = O
    curve.miller_bit_p(ref runner, 23); // ate_loop[23] = P
    curve.miller_bit_o(ref runner, 22); // ate_loop[22] = O
    curve.miller_bit_o(ref runner, 21); // ate_loop[21] = O
    curve.miller_bit_o(ref runner, 20); // ate_loop[20] = O
    curve.miller_bit_n(ref runner, 19); // ate_loop[19] = N
    curve.miller_bit_o(ref runner, 18); // ate_loop[18] = O
    curve.miller_bit_n(ref runner, 17); // ate_loop[17] = N
    curve.miller_bit_o(ref runner, 16); // ate_loop[16] = O
    curve.miller_bit_o(ref runner, 15); // ate_loop[15] = O
    curve.miller_bit_p(ref runner, 14); // ate_loop[14] = P
    core::internal::revoke_ap_tracking();
    curve.miller_bit_o(ref runner, 13); // ate_loop[13] = O
    curve.miller_bit_o(ref runner, 12); // ate_loop[12] = O
    curve.miller_bit_o(ref runner, 11); // ate_loop[11] = O
    curve.miller_bit_n(ref runner, 10); // ate_loop[10] = N
    curve.miller_bit_o(ref runner, 9); // ate_loop[ 9] = O
    curve.miller_bit_o(ref runner, 8); // ate_loop[ 8] = O
    curve.miller_bit_n(ref runner, 7); // ate_loop[ 7] = N
    curve.miller_bit_o(ref runner, 6); // ate_loop[ 6] = O
    curve.miller_bit_p(ref runner, 5); // ate_loop[ 5] = P
    curve.miller_bit_o(ref runner, 4); // ate_loop[ 4] = O
    curve.miller_bit_p(ref runner, 3); // ate_loop[ 3] = P
    curve.miller_bit_o(ref runner, 2); // ate_loop[ 2] = O
    curve.miller_bit_o(ref runner, 1); // ate_loop[ 1] = O
    curve.miller_bit_o(ref runner, 0); // ate_loop[ 0] = O
    curve.miller_last(ref runner);
}
