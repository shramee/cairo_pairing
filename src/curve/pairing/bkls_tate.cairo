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
use bn::curve::groups::{Affine, AffineG1, AffineG2, AffineOps};
use bn::fields::{print, FieldUtils, FieldOps, fq, Fq, Fq2, Fq6};
use print::{FqPrintImpl, Fq2PrintImpl, Fq12PrintImpl};
use bn::curve::pairing::miller_utils::{LineEvaluationsTrait};

fn miller_loop(p: AffineG1, q: AffineG2) -> Fq12 {
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

#[cfg(test)]
mod test {
    use core::debug::PrintTrait;
    use bn::fields::{Fq12, fq12_, Fq12Utils};
    use bn::curve::groups::{AffineG1, AffineG2, AffineG1Impl, AffineG2Impl, g1, g2};
    use bn::fields::{print::Fq12PrintImpl, FieldUtils, FieldOps, fq12, Fq, Fq6};
    use bn::curve::pairing::final_exponentiation::final_exponentiation;
    use super::{miller_loop};

    fn dbl_g2() -> AffineG2 {
        g2(
            18029695676650738226693292988307914797657423701064905010927197838374790804409,
            14583779054894525174450323658765874724019480979794335525732096752006891875705,
            2140229616977736810657479771656733941598412651537078903776637920509952744750,
            11474861747383700316476719153975578001603231366361248090558603872215261634898,
        )
    }
    fn dbl_g1() -> AffineG1 {
        g1(
            1368015179489954701390400359078579693043519447331113978918064868415326638035,
            9918110051302171585080402603319702774565515993150576347155970296011118125764,
        )
    }

    fn pair_result() -> Fq12 {
        fq12(
            0x1da92e958487e1515456e89aa06f4b08040231ec5492a3873c0e5a51743b93ae,
            0x13b8616ce25df6105d793af41913a57b0ab221b193d48107e89204e19568411f,
            0x1c8ab87de856aafdfb56d051cd79517ae10b4490cc01bd75b347a669d58698da,
            0x2e7918e3f3702ec1f031bcd571b3c23730ab030a0e7a875c6f99f4536ab3f0bb,
            0x21f3d1e320a26684b45a7f73a82bbcdabcee7b6b7f1b1073985de6d4f3867bcd,
            0x2cbf9b28de156b9f479d3a97a216b566d98f9b976f25a5ca31fbab41d9de224d,
            0x2da44e38ec26bde1ad31495943114856dd885beb7889c590079bb300bb6ec023,
            0x1c40f4619c21dbd91ba610a8943188e35402e587a071361f60288e7e96fa33b,
            0x9ebfb41a99f28109afed1112aab3c8ab4ff6dd90097e880669c960f11106b52,
            0x2d0c275838257edb77665b9aafbbd40626b6a35fe12b4ccacee5613bf3408fc2,
            0x289d6d934bc5994e10f4dc4bfe3a5ac9cddfce66ee76df1e751b064bfdb5533d,
            0x1e18e64906693e6f4c9cd40273060c504a78843d903489abb13377666679d33f,
        )
    }

    #[test]
    #[available_gas(99999999999999)]
    fn bkls_tate_miller() {
        let pair12 = miller_loop(AffineG1Impl::one(), dbl_g2());
        assert(pair12 == pair_result(), 'incorrect pairing');
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
