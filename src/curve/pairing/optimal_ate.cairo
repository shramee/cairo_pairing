use core::debug::PrintTrait;
use bn::traits::MillerEngine as MillEng;
use bn::fields::{Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::{groups, pairing::optimal_ate_utils};
use groups::{g1, g2, ECGroup};
use groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::curve::{six_t_plus_2_naf_rev_trimmed, FIELD};
use bn::fields::{print, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};
use optimal_ate_utils::SinglePairMiller;

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
fn ate_miller_loop<
    TPair, TG2, TPreC, +MillEng<TPair, TPreC, TG2, Fq12>, +Drop<TPair>, +Drop<TG2>, +Drop<TPreC>
>(
    pairs: TPair
) -> Fq12 {
    core::internal::revoke_ap_tracking();
    let field_nz = FIELD.try_into().unwrap();

    let (pre_compute, mut q_acc) = pairs.precompute_and_acc(field_nz);
    let mut f = pairs.miller_first_second(@pre_compute, ref q_acc);
    let mut array_items = six_t_plus_2_naf_rev_trimmed();

    loop {
        match array_items.pop_front() {
            Option::Some((
                b1, b2
            )) => {
                f = f.sqr();
                if b1 {
                    if b2 {
                        pairs.miller_bit_p(@pre_compute, ref q_acc, ref f);
                    } else {
                        pairs.miller_bit_n(@pre_compute, ref q_acc, ref f);
                    }
                } else {
                    pairs.miller_bit_o(@pre_compute, ref q_acc, ref f);
                }
            //
            },
            Option::None => { break; }
        }
    };
    f
}

fn ate_pairing<
    TPair, TG2, TPreC, +MillEng<TPair, TPreC, TG2, Fq12>, +Drop<TPair>, +Drop<TG2>, +Drop<TPreC>
>(
    pairs: TPair
) -> Fq12 {
    ate_miller_loop(pairs).final_exponentiation()
}

fn single_ate_pairing(pairs: (AffineG1, AffineG2)) -> Fq12 {
    ate_miller_loop(pairs).final_exponentiation()
}
