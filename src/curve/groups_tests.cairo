use bn::curve::groups::ECOperations;
// test bn::curve::groups_tests::g1_add ... ok (gas usage est.: 211230)
// test bn::curve::groups_tests::g1_dbl ... ok (gas usage est.: 250460)
// test bn::curve::groups_tests::g1_mul ... ok (gas usage est.: 938890)
// test bn::curve::groups_tests::g2_add ... ok (gas usage est.: 706220)
// test bn::curve::groups_tests::g2_dbl ... ok (gas usage est.: 799410)
// test bn::curve::groups_tests::g2_mul ... ok (gas usage est.: 2999470)

use bn::fields::fq;
use bn::curve::groups::{Affine, AffineOps, AffineG1, AffineG1Impl, g1, AffineG2, AffineG2Impl, g2};
use debug::PrintTrait;

const DBL_X: u256 = 1368015179489954701390400359078579693043519447331113978918064868415326638035;
const DBL_Y: u256 = 9918110051302171585080402603319702774565515993150576347155970296011118125764;

const TPL_X: u256 = 3353031288059533942658390886683067124040920775575537747144343083137631628272;
const TPL_Y: u256 = 19321533766552368860946552437480515441416830039777911637913418824951667761761;

#[test]
#[available_gas(100000000)]
fn g1_dbl() {
    let doubled = AffineG1Impl::one().double();
    assert(doubled.x.c0 == DBL_X, 'wrong double x');
    assert(doubled.y.c0 == DBL_Y, 'wrong double y');
}

#[test]
#[available_gas(100000000)]
fn g1_add() {
    let g_3x = AffineG1Impl::one().add(g1(DBL_X, DBL_Y));

    assert(g_3x.x.c0 == TPL_X, 'wrong add x');
    assert(g_3x.y.c0 == TPL_Y, 'wrong add y');
}

#[test]
#[available_gas(1000000000)]
fn g1_mul() {
    let pt = g1(
        0x17c139df0efee0f766bc0204762b774362e4ded88953a39ce849a8a7fa163fa9,
        0x1e0559bacb160664764a357af8a9fe70baa9258e0b959273ffc5718c6d4cc7c
    );
    let ptx125 = pt.multiply(0x1e424966e10667c3d185512e7409ca7a);
    println!("\nptx125 = g1({},\n{})", ptx125.x.c0, ptx125.y.c0);

    let ptx250 = pt.multiply(0x2150ec3e42dd5b118e4bd9c40a05b7adf1fa64af817e7c3d185512e7409ca7a);
    println!("\nptx250 = g1({},\n{})", ptx250.x.c0, ptx250.y.c0);

    assert(
        ptx125 == g1(
            7752846241341734434024187269145433576429990719025134712626574884614125378714,
            19213841682166110169098922493057250403196082236710892128510232260429666209717
        ),
        'wrong mul 125 bit'
    );
    assert(
        ptx250 == g1(
            8453943020253287278117062548565477428817612735773430345154413404924876875605,
            16097656260318801850592723545014363253891988068036964887917237907198917754434
        ),
        'wrong mul 250 bit'
    );
}
const DBL_X_0: u256 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
const DBL_X_1: u256 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
const DBL_Y_0: u256 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
const DBL_Y_1: u256 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;

const TPL_X_0: u256 = 2725019753478801796453339367788033689375851816420509565303521482350756874229;
const TPL_X_1: u256 = 7273165102799931111715871471550377909735733521218303035754523677688038059653;
const TPL_Y_0: u256 = 2512659008974376214222774206987427162027254181373325676825515531566330959255;
const TPL_Y_1: u256 = 957874124722006818841961785324909313781880061366718538693995380805373202866;

fn assert_g2_match(self: AffineG2, x0: u256, x1: u256, y0: u256, y1: u256, msg: felt252) {
    assert((self.x.c0.c0, self.x.c1.c0, self.y.c0.c0, self.y.c1.c0,) == (x0, x1, y0, y1,), msg);
}

#[test]
#[available_gas(100000000)]
fn g2_dbl() {
    let doubled = AffineG2Impl::one().double();
    assert_g2_match(doubled, DBL_X_0, DBL_X_1, DBL_Y_0, DBL_Y_1, 'wrong double');
}

#[test]
#[available_gas(100000000)]
fn g2_add() {
    let g_3x = AffineG2Impl::one().add(g2(DBL_X_0, DBL_X_1, DBL_Y_0, DBL_Y_1,));
    assert_g2_match(g_3x, TPL_X_0, TPL_X_1, TPL_Y_0, TPL_Y_1, 'wrong add operation');
}

#[test]
#[available_gas(100000000)]
fn g2_mul() {
    let g_3x = AffineG2Impl::one().multiply(3);
    assert_g2_match(g_3x, TPL_X_0, TPL_X_1, TPL_Y_0, TPL_Y_1, 'wrong multiply');
}
