use core::debug::PrintTrait;
use bn::traits::{MillerPrecompute, MillerSteps};
use bn::fields::{Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::{groups, pairing::optimal_ate_impls};
use groups::{g1, g2, ECGroup};
use groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::curve::{six_t_plus_2_naf_rev_trimmed, get_field_nz};
use bn::fields::{print, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};
use optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};

fn ate_miller_loop<
    TG1,
    TG2,
    TPreC,
    +MillerPrecompute<TG1, TG2, TPreC>,
    +MillerSteps<TPreC, TG2, Fq12>,
    +Drop<TG1>,
    +Drop<TG2>,
    +Drop<TPreC>,
>(
    p: TG1, q: TG2
) -> Fq12 {
    gas::withdraw_gas().unwrap();
    core::internal::revoke_ap_tracking();

    // Prepare precompute and q accumulator
    let (precompute, mut q_acc) = (p, q).precompute(get_field_nz());

    ate_miller_loop_steps(precompute, ref q_acc)
}

// Pairing Implementation Revisited - Michael Scott
//
// The implementation below is the algorithm described below in a single loop.
//
//
// Algorithm 2: Calculate and store line functions for BLS12 curve Input: Q ∈ G2, P ∈ G1, curve parameter u
// Output: An array g of ⌊log2(u)⌋ line functions ∈ Fp12
// 1: T←Q
// 2: for i ← ⌊log2(u)⌋−1 to 0 do
// 3:     g[i] ← lT,T(P), T ← 2T
// 4:     if ui =1then
// 5:         g[i] ← g[i].lT,Q(P), T ← T + Q return g
//
// Algorithm 3: Miller loop for BLS12 curve
// Input: An array g of ⌊log2(u)⌋ line functions ∈ Fp12 Output: f ∈ Fp12
// 1: f ← 1
// 2: for i ← ⌊log2(u)⌋−1 to 0 do
// 3:     f ← f^2 . g[i]
// 4: return f
//
// -------------------------------------------------------------------------
//
// The algo below is effectively this:
// 1: f ← 1
// 2: for i ← ⌊log2(u)⌋−1 to 0 do
// 3:     f ← f^2
// 4:     Compute g[i] and mul with f based on the bit value
// 5: return f
// 
fn ate_miller_loop_steps<TG2, TPreC, +MillerSteps<TPreC, TG2, Fq12>, +Drop<TG2>, +Drop<TPreC>,>(
    precompute: TPreC, ref q_acc: TG2
) -> Fq12 {
    let (precompute, mut f) = ate_miller_loop_steps_first_half(precompute, ref q_acc);
    ate_miller_loop_steps_second_half(precompute, ref q_acc, ref f);
    f
}

fn ate_miller_loop_steps_first_half<
    TG2, TPreC, +MillerSteps<TPreC, TG2, Fq12>, +Drop<TG2>, +Drop<TPreC>,
>(
    precompute: TPreC, ref q_acc: TG2
) -> (TPreC, Fq12) {
    // ate_loop[64] = O and ate_loop[63] = N
    let mut f = precompute.miller_first_second(64, 63, ref q_acc);
    precompute.sqr_target(62, ref q_acc, ref f);
    precompute.miller_bit_o(62, ref q_acc, ref f); // ate_loop[62] = O
    precompute.sqr_target(61, ref q_acc, ref f);
    precompute.miller_bit_p(61, ref q_acc, ref f); // ate_loop[61] = P
    precompute.sqr_target(60, ref q_acc, ref f);
    precompute.miller_bit_o(60, ref q_acc, ref f); // ate_loop[60] = O
    precompute.sqr_target(59, ref q_acc, ref f);
    precompute.miller_bit_o(59, ref q_acc, ref f); // ate_loop[59] = O
    precompute.sqr_target(58, ref q_acc, ref f);
    precompute.miller_bit_o(58, ref q_acc, ref f); // ate_loop[58] = O
    precompute.sqr_target(57, ref q_acc, ref f);
    precompute.miller_bit_n(57, ref q_acc, ref f); // ate_loop[57] = N
    precompute.sqr_target(56, ref q_acc, ref f);
    precompute.miller_bit_o(56, ref q_acc, ref f); // ate_loop[56] = O
    precompute.sqr_target(55, ref q_acc, ref f);
    precompute.miller_bit_n(55, ref q_acc, ref f); // ate_loop[55] = N
    precompute.sqr_target(54, ref q_acc, ref f);
    precompute.miller_bit_o(54, ref q_acc, ref f); // ate_loop[54] = O
    precompute.sqr_target(53, ref q_acc, ref f);
    precompute.miller_bit_o(53, ref q_acc, ref f); // ate_loop[53] = O
    precompute.sqr_target(52, ref q_acc, ref f);
    precompute.miller_bit_o(52, ref q_acc, ref f); // ate_loop[52] = O
    precompute.sqr_target(51, ref q_acc, ref f);
    precompute.miller_bit_n(51, ref q_acc, ref f); // ate_loop[51] = N
    precompute.sqr_target(50, ref q_acc, ref f);
    precompute.miller_bit_o(50, ref q_acc, ref f); // ate_loop[50] = O
    precompute.sqr_target(49, ref q_acc, ref f);
    precompute.miller_bit_p(49, ref q_acc, ref f); // ate_loop[49] = P
    precompute.sqr_target(48, ref q_acc, ref f);
    precompute.miller_bit_o(48, ref q_acc, ref f); // ate_loop[48] = O
    precompute.sqr_target(47, ref q_acc, ref f);
    precompute.miller_bit_n(47, ref q_acc, ref f); // ate_loop[47] = N
    precompute.sqr_target(46, ref q_acc, ref f);
    precompute.miller_bit_o(46, ref q_acc, ref f); // ate_loop[46] = O
    precompute.sqr_target(45, ref q_acc, ref f);
    precompute.miller_bit_o(45, ref q_acc, ref f); // ate_loop[45] = O
    precompute.sqr_target(44, ref q_acc, ref f);
    precompute.miller_bit_n(44, ref q_acc, ref f); // ate_loop[44] = N
    precompute.sqr_target(43, ref q_acc, ref f);
    precompute.miller_bit_o(43, ref q_acc, ref f); // ate_loop[43] = O
    precompute.sqr_target(42, ref q_acc, ref f);
    precompute.miller_bit_o(42, ref q_acc, ref f); // ate_loop[42] = O
    precompute.sqr_target(41, ref q_acc, ref f);
    precompute.miller_bit_o(41, ref q_acc, ref f); // ate_loop[41] = O
    precompute.sqr_target(40, ref q_acc, ref f);
    precompute.miller_bit_o(40, ref q_acc, ref f); // ate_loop[40] = O
    precompute.sqr_target(39, ref q_acc, ref f);
    precompute.miller_bit_o(39, ref q_acc, ref f); // ate_loop[39] = O
    precompute.sqr_target(38, ref q_acc, ref f);
    precompute.miller_bit_p(38, ref q_acc, ref f); // ate_loop[38] = P
    precompute.sqr_target(37, ref q_acc, ref f);
    precompute.miller_bit_o(37, ref q_acc, ref f); // ate_loop[37] = O
    precompute.sqr_target(36, ref q_acc, ref f);
    precompute.miller_bit_o(36, ref q_acc, ref f); // ate_loop[36] = O
    precompute.sqr_target(35, ref q_acc, ref f);
    precompute.miller_bit_n(35, ref q_acc, ref f); // ate_loop[35] = N
    precompute.sqr_target(34, ref q_acc, ref f);
    precompute.miller_bit_o(34, ref q_acc, ref f); // ate_loop[34] = O
    precompute.sqr_target(33, ref q_acc, ref f);
    precompute.miller_bit_p(33, ref q_acc, ref f); // ate_loop[33] = P
    precompute.sqr_target(32, ref q_acc, ref f);
    precompute.miller_bit_o(32, ref q_acc, ref f); // ate_loop[32] = O
    precompute.sqr_target(31, ref q_acc, ref f);
    precompute.miller_bit_o(31, ref q_acc, ref f); // ate_loop[31] = O
    (precompute, f)
}

fn ate_miller_loop_steps_second_half<
    TG2, TPreC, +MillerSteps<TPreC, TG2, Fq12>, +Drop<TG2>, +Drop<TPreC>,
>(
    precompute: TPreC, ref q_acc: TG2, ref f: Fq12
) -> TPreC {
    precompute.sqr_target(30, ref q_acc, ref f);
    precompute.miller_bit_n(30, ref q_acc, ref f); // ate_loop[30] = N
    precompute.sqr_target(29, ref q_acc, ref f);
    precompute.miller_bit_o(29, ref q_acc, ref f); // ate_loop[29] = O
    precompute.sqr_target(28, ref q_acc, ref f);
    precompute.miller_bit_o(28, ref q_acc, ref f); // ate_loop[28] = O
    precompute.sqr_target(27, ref q_acc, ref f);
    precompute.miller_bit_o(27, ref q_acc, ref f); // ate_loop[27] = O
    precompute.sqr_target(26, ref q_acc, ref f);
    precompute.miller_bit_o(26, ref q_acc, ref f); // ate_loop[26] = O
    precompute.sqr_target(25, ref q_acc, ref f);
    precompute.miller_bit_n(25, ref q_acc, ref f); // ate_loop[25] = N
    precompute.sqr_target(24, ref q_acc, ref f);
    precompute.miller_bit_o(24, ref q_acc, ref f); // ate_loop[24] = O
    precompute.sqr_target(23, ref q_acc, ref f);
    precompute.miller_bit_p(23, ref q_acc, ref f); // ate_loop[23] = P
    precompute.sqr_target(22, ref q_acc, ref f);
    precompute.miller_bit_o(22, ref q_acc, ref f); // ate_loop[22] = O
    precompute.sqr_target(21, ref q_acc, ref f);
    precompute.miller_bit_o(21, ref q_acc, ref f); // ate_loop[21] = O
    precompute.sqr_target(20, ref q_acc, ref f);
    precompute.miller_bit_o(20, ref q_acc, ref f); // ate_loop[20] = O
    precompute.sqr_target(19, ref q_acc, ref f);
    precompute.miller_bit_n(19, ref q_acc, ref f); // ate_loop[19] = N
    precompute.sqr_target(18, ref q_acc, ref f);
    precompute.miller_bit_o(18, ref q_acc, ref f); // ate_loop[18] = O
    precompute.sqr_target(17, ref q_acc, ref f);
    precompute.miller_bit_n(17, ref q_acc, ref f); // ate_loop[17] = N
    precompute.sqr_target(16, ref q_acc, ref f);
    precompute.miller_bit_o(16, ref q_acc, ref f); // ate_loop[16] = O
    precompute.sqr_target(15, ref q_acc, ref f);
    precompute.miller_bit_o(15, ref q_acc, ref f); // ate_loop[15] = O
    precompute.sqr_target(14, ref q_acc, ref f);
    precompute.miller_bit_p(14, ref q_acc, ref f); // ate_loop[14] = P
    precompute.sqr_target(13, ref q_acc, ref f);
    precompute.miller_bit_o(13, ref q_acc, ref f); // ate_loop[13] = O
    precompute.sqr_target(12, ref q_acc, ref f);
    precompute.miller_bit_o(12, ref q_acc, ref f); // ate_loop[12] = O
    precompute.sqr_target(11, ref q_acc, ref f);
    precompute.miller_bit_o(11, ref q_acc, ref f); // ate_loop[11] = O
    precompute.sqr_target(10, ref q_acc, ref f);
    precompute.miller_bit_n(10, ref q_acc, ref f); // ate_loop[10] = N
    precompute.sqr_target(9, ref q_acc, ref f);
    precompute.miller_bit_o(9, ref q_acc, ref f); // ate_loop[ 9] = O
    precompute.sqr_target(8, ref q_acc, ref f);
    precompute.miller_bit_o(8, ref q_acc, ref f); // ate_loop[ 8] = O
    precompute.sqr_target(7, ref q_acc, ref f);
    precompute.miller_bit_n(7, ref q_acc, ref f); // ate_loop[ 7] = N
    precompute.sqr_target(6, ref q_acc, ref f);
    precompute.miller_bit_o(6, ref q_acc, ref f); // ate_loop[ 6] = O
    precompute.sqr_target(5, ref q_acc, ref f);
    precompute.miller_bit_p(5, ref q_acc, ref f); // ate_loop[ 5] = P
    precompute.sqr_target(4, ref q_acc, ref f);
    precompute.miller_bit_o(4, ref q_acc, ref f); // ate_loop[ 4] = O
    precompute.sqr_target(3, ref q_acc, ref f);
    precompute.miller_bit_p(3, ref q_acc, ref f); // ate_loop[ 3] = P
    precompute.sqr_target(2, ref q_acc, ref f);
    precompute.miller_bit_o(2, ref q_acc, ref f); // ate_loop[ 2] = O
    precompute.sqr_target(1, ref q_acc, ref f);
    precompute.miller_bit_o(1, ref q_acc, ref f); // ate_loop[ 1] = O
    precompute.sqr_target(0, ref q_acc, ref f);
    precompute.miller_bit_o(0, ref q_acc, ref f); // ate_loop[ 0] = O

    precompute.miller_last(ref q_acc, ref f);
    precompute
}

fn ate_pairing<
    TG1,
    TG2,
    TPreC,
    +MillerPrecompute<TG1, TG2, TPreC>,
    +MillerSteps<TPreC, TG2, Fq12>,
    +Drop<TG1>,
    +Drop<TG2>,
    +Drop<TPreC>,
>(
    p: TG1, q: TG2
) -> Fq12 {
    ate_miller_loop(p, q).final_exponentiation()
}

fn single_ate_pairing(p: AffineG1, q: AffineG2) -> Fq12 {
    ate_miller_loop(p, q).final_exponentiation()
}
