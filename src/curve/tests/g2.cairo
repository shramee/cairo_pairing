// test bn::curve::tests::g2::dbl ... ok (gas usage est.: 1665910)
// test bn::curve::tests::g2::add ... ok (gas usage est.: 1441630)
// test bn::curve::tests::g2::mul ... ok (gas usage est.: 6217190)

use bn::curve::g2::AffineG2Trait;
use bn::traits::ECOperations;
use bn::fields::fq;
use bn::{g2};
use debug::PrintTrait;

const DBL_X_0: u256 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
const DBL_X_1: u256 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
const DBL_Y_0: u256 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
const DBL_Y_1: u256 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;

const TPL_X_0: u256 = 2725019753478801796453339367788033689375851816420509565303521482350756874229;
const TPL_X_1: u256 = 7273165102799931111715871471550377909735733521218303035754523677688038059653;
const TPL_Y_0: u256 = 2512659008974376214222774206987427162027254181373325676825515531566330959255;
const TPL_Y_1: u256 = 957874124722006818841961785324909313781880061366718538693995380805373202866;

#[test]
#[available_gas(100000000)]
fn dbl() {
    let doubled = g2::one().double();
    assert(doubled.to_tuple() == (DBL_X_0, DBL_X_1, DBL_Y_0, DBL_Y_1,), 'wrong double');
}

#[test]
#[available_gas(100000000)]
fn add() {
    let g_3x = g2::one().add(g2::pt(DBL_X_0, DBL_X_1, DBL_Y_0, DBL_Y_1,));
    assert(g_3x.to_tuple() == (TPL_X_0, TPL_X_1, TPL_Y_0, TPL_Y_1,), 'wrong add operation');
}

#[test]
#[available_gas(100000000)]
fn mul() {
    let g_3x = g2::one().multiply(3);
    assert(g_3x.to_tuple() == (TPL_X_0, TPL_X_1, TPL_Y_0, TPL_Y_1,), 'wrong multiply');
}
