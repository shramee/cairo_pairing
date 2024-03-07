// Standard code for miller loop, can be found on page 99 at this url:
// <https://static1.squarespace.com/static/5fdbb09f31d71c1227082339/t/5ff394720493bd28278889c6/1609798774687/PairingsForBeginners.pdf#page=107>
//
// Input: P ∈ G1, Q ∈ G2 (Type 3 pairing) and r = (rn-1 ... r1r0)2 with rn-1 = 1.
// Output: f_r_P(Q)^(qk-1)/r ← f.
// 1 | R ← P, f ← 1.
// 2 | for i = n - 2 down to 0 do
// 3 |     // Compute the sloped line function l(R,R) for doubling R.
// 4 |     R ← [2]R.
// 5 |     f ← f^2 · l(R,R)(Q).
// 6 |     if ri = 1 then
// 7 |         // Compute the sloped line function l(R,P) for adding R and P.
// 8 |         R ← R + P.
// 9 |         f ← f · l(R,P)(Q).
// 10|     end if
// 11|  end for
// 12|  return f ← f^((q^k-1)/r)
// 
// This can probably use a lot of optimisation from NAF/short miller loop implementations

use core::debug::PrintTrait;
use bn::fields::{Fq12, Fq12Utils, Fq12Expo};
use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::fields::{print, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};
use print::{FqPrintImpl, Fq2PrintImpl, Fq12PrintImpl};
use bn::curve::pairing::miller_utils::{LineEvaluationsTrait};

fn tate_miller_loop(p: AffineG1, q: AffineG2) -> Fq12 {
    core::internal::revoke_ap_tracking();

    let mut r = p;
    let mut f = Fq12Utils::one();
    let mut array_items = tate_loop_bools();

    loop {
        match array_items.pop_front() {
            Option::Some(ate_bool) => { //
                // Compute the sloped line function l(R,R) for doubling R.
                // f ← f^2 · l(R,R)(Q)
                f = f.sqr() * q.at_tangent(r);

                // R ← [2]R
                r = r.double();

                if ate_bool { //
                    // Compute the sloped line function l(R,P) for adding R and P.
                    // f ← f · l(R,P)(Q)
                    f = f * q.at_chord(r, p);
                    // R ← R + P
                    r = r.add(p);
                }
            //
            },
            Option::None => { break; }
        }
    };
    f
}

#[inline(always)]
fn tate_pairing(p: AffineG1, q: AffineG2) -> Fq12 {
    tate_miller_loop(p, q).final_exponentiation()
}

fn tate_loop_bools() -> Array<bool> {
    array![
        true,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        false,
        false,
        true,
        false,
        false,
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        false,
        false,
        true,
        true,
        true,
        false,
        false,
        true,
        false,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        true,
        true,
        false,
        false,
        false,
        true,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        true,
        false,
        false,
        true,
        true,
        false,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        false,
        true,
        false,
        true,
        true,
        false,
        true,
        true,
        false,
        true,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        true,
        false,
        true,
        true,
        false,
        false,
        false,
        false,
        true,
        false,
        true,
        true,
        true,
        false,
        true,
        false,
        false,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        true,
        false,
        false,
        false,
        false,
        true,
        true,
        true,
        true,
        false,
        false,
        true,
        true,
        false,
        true,
        true,
        true,
        false,
        false,
        true,
        false,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        true,
        false,
        false,
        false,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        false,
        true,
        true,
        false,
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
    ]
}
