use core::debug::PrintTrait;
use bn::traits::MillerEngine;
use bn::fields::{Fq12, Fq12Utils, Fq12FinalExpo};
use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::curve::six_t_plus_2_naf_rev_except_first;
use bn::fields::{print, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};
use print::{FqPrintImpl, Fq2PrintImpl, Fq12PrintImpl};
use bn::curve::pairing::miller_utils::{LineEvaluationsTrait};

fn ate_miller_loop<
    TPairs, TTempR, +MillerEngine<TPairs, TTempR, Fq12>, +Drop<TPairs>, +Drop<TTempR>
>(
    pairs: TPairs
) -> Fq12 {
    core::internal::revoke_ap_tracking();

    // 1: d ← l(Q,Q)(P), T ← 2Q, e ← 1
    // let d = Fq12Utils::one();
    // let e = Fq12Utils::one();

    // 2: if r⌊log2(r)⌋ − 1 = 1 then e ← l(T,Q)(P), T ← T + Q
    // 3: f ← d · e
    // 4: for i = ⌊log2(r)⌋ − 2 downto 0 do
    // 5: f ← f2 · l(T,T)(P), T ←2T
    // 6: if ri = 1 then f ← f · l(T,Q)(P), T ← T + Q
    // 7: end for

    // 8: Q1 ← πp( Q ), Q2 ← πp2( Q )
    // 9: if u < 0 then T ← −T, f ← fp6
    // 10: d ← l(T, Q1)(P), T ← T + Q1, e ← l(T,−Q2)(P), T ← T − Q2,f ← f · (d · e)
    // 11: f ← f(p6−1)(p2+1)(p4−p2+1)/n
    // 12: return f

    let mut r = pairs.get_temp_r();
    let mut f = Fq12Utils::one();
    let mut array_items = six_t_plus_2_naf_rev_except_first();

    loop {
        match array_items.pop_front() {
            Option::Some((
                b1, b2
            )) => { //
                if b1 == false {
                    let (_r, _f) = pairs.bit_o(r, f);
                    r = _r;
                    f = _f;
                } else {
                    if b2 == false {
                        let (_r, _f) = pairs.bit_p(r, f);
                        r = _r;
                        f = _f;
                    } else {
                        let (_r, _f) = pairs.bit_n(r, f);
                        r = _r;
                        f = _f;
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
