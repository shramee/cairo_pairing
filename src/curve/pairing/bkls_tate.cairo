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
use bn::curve::pairing::final_exponentiation::final_exponentiation;
use bn::curve::pairing::miller_utils::{chord, tangent};

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

#[cfg(test)]
mod test {
    use core::debug::PrintTrait;
    use bn::fields::{Fq12, fq12_, Fq12Utils};
    use bn::curve::{g1, g2};
    use bn::traits::ECOperations;
    use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};
    // use bn::curve::final_exponentiation::final_exponentiation;
    use super::{miller_loop};

    fn dbl_g2() -> g2::AffineG2 {
        g2::pt(
            18029695676650738226693292988307914797657423701064905010927197838374790804409,
            14583779054894525174450323658765874724019480979794335525732096752006891875705,
            2140229616977736810657479771656733941598412651537078903776637920509952744750,
            11474861747383700316476719153975578001603231366361248090558603872215261634898,
        )
    }
    fn dbl_g1() -> g1::AffineG1 {
        g1::pt(
            1368015179489954701390400359078579693043519447331113978918064868415326638035,
            9918110051302171585080402603319702774565515993150576347155970296011118125764,
        )
    }

    #[test]
    #[available_gas(99999999999999)]
    fn run_pairing() {
        let pair12 = miller_loop(g1::one(), dbl_g2());
        ('------------').print();
        pair12.print();

        // let pair12 = final_exponentiation(pair12);

        ('------------').print();
    // pair12.print();
    // let pair21 = miller_loop(g1::pt(DBL_X, DBL_Y), g2::one());
    // pair21.print();
    // let pair21 = final_exponentiation(pair21);
    // (pair12 == pair21).print();
    // pair21.print();
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
