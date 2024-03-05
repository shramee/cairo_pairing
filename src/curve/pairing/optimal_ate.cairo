use core::debug::PrintTrait;
use bn::traits::MillerEngine;
use bn::fields::{Fq12, Fq12Utils, Fq12FinalExpo};
use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::curve::six_t_plus_2_naf_rev_trimmed;
use bn::fields::{print, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};
use print::{FqPrintImpl, Fq2PrintImpl, Fq12PrintImpl};
use bn::curve::pairing::miller_utils::{LineEvaluationsTrait};

fn ate_miller_loop<
    TPairs, TTempR, +MillerEngine<TPairs, TTempR, Fq12>, +Drop<TPairs>, +Drop<TTempR>
>(
    pairs: TPairs
) -> Fq12 {
    core::internal::revoke_ap_tracking();
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
    // 4:     Generate g[i] and mul with f based on the bit value
    // 5: return f
    // 

    let mut r = pairs.get_temp_r();
    let mut f = Fq12Utils::one();
    let mut array_items = six_t_plus_2_naf_rev_trimmed();

    loop {
        match array_items.pop_front() {
            Option::Some((
                b1, b2
            )) => {
                f = f.sqr();
                if b1 == false {
                    pairs.miller_bit_o(ref r, ref f);
                } else {
                    if b2 == false {
                        pairs.miller_bit_p(ref r, ref f);
                    } else {
                        pairs.miller_bit_n(ref r, ref f);
                    }
                }
            //
            },
            Option::None => { break; }
        }
    };
    f
}

// fn multi_miller_loop(pairs: Array<(AffineG1, AffineG2)>) -> Fq12 {}

fn pairing<TPairs, TTempR, +MillerEngine<TPairs, TTempR, Fq12>, +Drop<TPairs>, +Drop<TTempR>>(
    pairs: TPairs
) -> Fq12 {
    ate_miller_loop(pairs).final_exponentiation()
}
