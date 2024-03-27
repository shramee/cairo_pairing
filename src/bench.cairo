// test bn::bench::fq01::add ... ok (gas usage est.: 9060)
// test bn::bench::fq01::inv ... ok (gas usage est.: 28870)
// test bn::bench::fq01::mul ... ok (gas usage est.: 41330)
// test bn::bench::fq01::mulu ... ok (gas usage est.: 20130)
// test bn::bench::fq01::rdc ... ok (gas usage est.: 20890)
// test bn::bench::fq01::scale ... ok (gas usage est.: 28430)
// test bn::bench::fq01::sqr ... ok (gas usage est.: 38100)
// test bn::bench::fq01::sqru ... ok (gas usage est.: 16900)
// test bn::bench::fq01::sub ... ok (gas usage est.: 5240)
// test bn::bench::fq02::add ... ok (gas usage est.: 17820)
// test bn::bench::fq02::inv ... ok (gas usage est.: 175250)
// test bn::bench::fq02::mul ... ok (gas usage est.: 133070)
// test bn::bench::fq02::mulu ... ok (gas usage est.: 92290)
// test bn::bench::fq02::mxi ... ok (gas usage est.: 70070)
// test bn::bench::fq02::rdc ... ok (gas usage est.: 41680)
// test bn::bench::fq02::sqr ... ok (gas usage est.: 91130)
// test bn::bench::fq02::sqru ... ok (gas usage est.: 50350)
// test bn::bench::fq02::sub ... ok (gas usage est.: 10490)
// test bn::bench::fq06::add ... ok (gas usage est.: 52860)
// test bn::bench::fq06::inv ... ok (gas usage est.: 1793670)
// test bn::bench::fq06::mul ... ok (gas usage est.: 1084520)
// test bn::bench::fq06::mulu ... ok (gas usage est.: 963680)
// test bn::bench::fq06::sqr ... ok (gas usage est.: 830030)
// test bn::bench::fq06::sqru ... ok (gas usage est.: 709190)
// test bn::bench::fq06::sub ... ok (gas usage est.: 31490)
// test bn::bench::fq12::add ... ok (gas usage est.: 105420)
// test bn::bench::fq12::inv ... ok (gas usage est.: 5672250)
// test bn::bench::fq12::kdcmp ... ok (gas usage est.: 1054600)
// test bn::bench::fq12::ksqr ... ok (gas usage est.: 1101820)
// test bn::bench::fq12::mul ... ok (gas usage est.: 3542660)
// test bn::bench::fq12::sqr ... ok (gas usage est.: 2647540)
// test bn::bench::fq12::sqrc ... ok (gas usage est.: 1928850)
// test bn::bench::fq12::sub ... ok (gas usage est.: 62990)
// test bn::bench::fq12::xp_t ... ok (gas usage est.: 141137180)
// test bn::bench::fq12::z_esy ... ok (gas usage est.: 13714740)
// test bn::bench::fq12::z_hrd ... ok (gas usage est.: 467526370)
// test bn::bench::sprs::l1f_l2f ... ok (gas usage est.: 3740860)
// test bn::bench::sprs::l1l2_f ... ok (gas usage est.: 3801510)
// test bn::bench::sprs::s01_01 ... ok (gas usage est.: 336870)
// test bn::bench::sprs::s01_fq6 ... ok (gas usage est.: 679210)
// test bn::bench::sprs::s034_034 ... ok (gas usage est.: 559540)
// test bn::bench::sprs::s034_fq12 ... ok (gas usage est.: 1872430)
// test bn::bench::sprs::s01234_fq12 ... ok (gas usage est.: 3239770)
// test bn::bench::u512::add ... ok (gas usage est.: 7080)
// test bn::bench::u512::add_bn ... ok (gas usage est.: 13190)
// test bn::bench::u512::fq_add ... ok (gas usage est.: 5660)
// test bn::bench::u512::fq_n2 ... ok (gas usage est.: 400)
// test bn::bench::u512::fq_sub ... ok (gas usage est.: 5660)
// test bn::bench::u512::mxi ... ok (gas usage est.: 77800)
// test bn::bench::u512::sub ... ok (gas usage est.: 7080)
// test bn::bench::u512::sub_bn ... ok (gas usage est.: 13190)

use bn::traits::{FieldOps, FieldShortcuts, FieldMulShortcuts};
use bn::math::fast_mod as m;
use bn::curve::{U512BnAdd, U512BnSub};
use debug::PrintTrait;

#[inline(always)]
fn u512_one() -> integer::u512 {
    integer::u512 { limb0: 1, limb1: 0, limb2: 0, limb3: 0 }
}

// mod curve;

mod fq01;

mod fq02;

mod fq06;

mod fq12;

mod sprs;

mod u512;

