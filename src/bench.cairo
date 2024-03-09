// test bn::bench::fq01::add ... ok (gas usage est.: 10160)
// test bn::bench::fq01::inv ... ok (gas usage est.: 36270)
// test bn::bench::fq01::mul ... ok (gas usage est.: 49130)
// test bn::bench::fq01::mulu ... ok (gas usage est.: 23540)
// test bn::bench::fq01::rdc ... ok (gas usage est.: 25490)
// test bn::bench::fq01::scale ... ok (gas usage est.: 35730)
// test bn::bench::fq01::sqr ... ok (gas usage est.: 45100)
// test bn::bench::fq01::sqru ... ok (gas usage est.: 19510)
// test bn::bench::fq01::sub ... ok (gas usage est.: 5250)
// test bn::bench::fq02::add ... ok (gas usage est.: 20020)
// test bn::bench::fq02::inv ... ok (gas usage est.: 218250)
// test bn::bench::fq02::mul ... ok (gas usage est.: 151970)
// test bn::bench::fq02::mulu ... ok (gas usage est.: 103490)
// test bn::bench::fq02::mxi ... ok (gas usage est.: 85870)
// test bn::bench::fq02::rdc ... ok (gas usage est.: 49680)
// test bn::bench::fq02::sqr ... ok (gas usage est.: 105230)
// test bn::bench::fq02::sqru ... ok (gas usage est.: 56750)
// test bn::bench::fq02::sub ... ok (gas usage est.: 10500)
// test bn::bench::fq06::add ... ok (gas usage est.: 59460)
// test bn::bench::fq06::inv ... ok (gas usage est.: 2081670)
// test bn::bench::fq06::mul ... ok (gas usage est.: 1249220)
// test bn::bench::fq06::mulu ... ok (gas usage est.: 1105280)
// test bn::bench::fq06::sqr ... ok (gas usage est.: 963530)
// test bn::bench::fq06::sqru ... ok (gas usage est.: 819590)
// test bn::bench::fq06::sub ... ok (gas usage est.: 31500)
// test bn::bench::fq12::add ... ok (gas usage est.: 128220)
// test bn::bench::fq12::inv ... ok (gas usage est.: 6584690)
// test bn::bench::fq12::kdcmp ... ok (gas usage est.: 1230780)
// test bn::bench::fq12::ksqr ... ok (gas usage est.: 1276420)
// test bn::bench::fq12::mul ... ok (gas usage est.: 4087960)
// test bn::bench::fq12::sqr ... ok (gas usage est.: 3066340)
// test bn::bench::fq12::sqrc ... ok (gas usage est.: 2247250)
// test bn::bench::fq12::sub ... ok (gas usage est.: 74900)
// test bn::bench::fq12::xp_t ... ok (gas usage est.: 163091970)
// test bn::bench::fq12::z_esy ... ok (gas usage est.: 15862820)
// test bn::bench::fq12::z_hrd ... ok (gas usage est.: 540241830)
// test bn::bench::sprs::l1f_l2f ... ok (gas usage est.: 4282180)
// test bn::bench::sprs::l1l2_f ... ok (gas usage est.: 4364580)
// test bn::bench::sprs::s01_01 ... ok (gas usage est.: 382270)
// test bn::bench::sprs::s01_fq6 ... ok (gas usage est.: 777610)
// test bn::bench::sprs::s034_034 ... ok (gas usage est.: 626410)
// test bn::bench::sprs::s034_fq12 ... ok (gas usage est.: 2142140)
// test bn::bench::sprs::s01234_fq12 ... ok (gas usage est.: 3742970)
// test bn::bench::u512::add ... ok (gas usage est.: 7490)
// test bn::bench::u512::add_bn ... ok (gas usage est.: 15390)
// test bn::bench::u512::fq_add ... ok (gas usage est.: 5480)
// test bn::bench::u512::fq_n2 ... ok (gas usage est.: 400)
// test bn::bench::u512::fq_sub ... ok (gas usage est.: 5480)
// test bn::bench::u512::mxi ... ok (gas usage est.: 95100)
// test bn::bench::u512::sub ... ok (gas usage est.: 7490)
// test bn::bench::u512::sub_bn ... ok (gas usage est.: 15390)

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

