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
use bn::fields::{Fq12, fq12_, Fq12Utils};
use bn::curve::{g1, g2};
use bn::traits::ECOperations;
use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};

fn miller_loop(p: g1::AffineG1, q: g2::AffineG2) -> Fq12 {
    core::internal::revoke_ap_tracking();

    let mut r = p;
    let mut f = Fq12Utils::one();
    let mut array_items = tate_loop_bools();

    loop {
        match array_items.pop_front() {
            Option::Some(ate_bool) => { //
                // Compute the sloped line function l(R,R) for doubling R.
                // R ← [2]R
                r = r.double();
                // f ← f^2 · l(R,R)(Q)
                f = f.sqr() * tangent(r, q);
                if ate_bool { //
                    // Compute the sloped line function l(R,P) for adding R and P.
                    // R ← R + P
                    r = r.add(p);
                    // f ← f · l(R,P)(Q)
                    f = f * chord(r, p, q);
                }
            //
            },
            Option::None => { break; }
        }
    };
    f
}

/// The sloped line function for doubling a point
fn tangent(p: g1::AffineG1, q: g2::AffineG2) -> Fq12 {
    let cx = -fq(3) * p.x * p.x;
    let cy = fq(2) * p.y;
    sparse_fq12(p.y * p.y - fq(9), q.x.scale(cx), q.y.scale(cy))
}

/// The sloped line function for adding two points
fn chord(p1: g1::AffineG1, p2: g1::AffineG1, q: g2::AffineG2) -> Fq12 {
    let cx = p2.y - p1.y;
    let cy = p1.x - p2.x;
    sparse_fq12(p1.y * p2.x - p2.y * p1.x, q.x.scale(cx), q.y.scale(cy))
}

/// The tangent and cord functions output sparse Fp12 elements.
/// This map embeds the nonzero coefficients into an Fp12.
fn sparse_fq12(g000: Fq, g01: Fq2, g11: Fq2) -> Fq12 {
    let g0 = Fq6 {
        c0: Fq2 { c0: g000, c1: FieldUtils::zero(), }, c1: g01, c2: FieldUtils::zero(),
    };

    let g1 = Fq6 { c0: FieldUtils::zero(), c1: g11, c2: FieldUtils::zero(), };

    Fq12 {
        c0: Fq6 { c0: Fq2 { c0: g000, c1: FieldUtils::zero(), }, c1: g01, c2: FieldUtils::zero(), },
        c1: Fq6 { c0: FieldUtils::zero(), c1: g11, c2: FieldUtils::zero(), }
    }
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

const DBL_X_0: u256 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
const DBL_X_1: u256 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
const DBL_Y_0: u256 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
const DBL_Y_1: u256 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;

const DBL_X: u256 = 1368015179489954701390400359078579693043519447331113978918064868415326638035;
const DBL_Y: u256 = 9918110051302171585080402603319702774565515993150576347155970296011118125764;

#[test]
#[available_gas(99999999999999)]
fn run_pairing() {
    let pair12 = miller_loop(g1::one(), g2::pt(DBL_X_0, DBL_X_1, DBL_Y_0, DBL_Y_1));
    let pair21 = miller_loop(g1::pt(DBL_X, DBL_Y), g2::one());
    pair12.print();
    pair21.print();
}
