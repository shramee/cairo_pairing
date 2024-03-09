// use bn::traits::FieldUtils;
// use super::{u512_one, m, PrintTrait, FieldOps, FieldShortcuts, FieldMulShortcuts};
// use integer::u512;
// use bn::curve::{U512BnAdd, U512BnSub, FIELD, groups};
// use bn::curve::pairing::optimal_ate_utils::{
//     step_double_and_add, step_double, PreCompute, LineEvalPrecompute
// };
// use groups::{g2, g1, AffineG2, AffineOps, ECGroup};
// use bn::fields::{fq, Fq, FqMulShort};

// fn pt2() -> AffineG2 {
//     g2(
//         18029695676650738226693292988307914797657423701064905010927197838374790804409,
//         14583779054894525174450323658765874724019480979794335525732096752006891875705,
//         2140229616977736810657479771656733941598412651537078903776637920509952744750,
//         11474861747383700316476719153975578001603231366361248090558603872215261634898,
//     )
// }

// fn mock_pre_compute() -> PreCompute {
//     PreCompute { p: LineEvalPrecompute { x_over_y: fq(5), y_inv: fq(1) }, neg_q: pt2() }
// }

// #[test]
// #[available_gas(100000000)]
// fn stp2x_a() {
//     let mut acc = pt2();
//     step_double_and_add(ref acc, @mock_pre_compute(), ECGroup::one(), ECGroup::one());
// }

// #[test]
// #[available_gas(100000000)]
// fn stp2x() {
//     let mut acc = pt2();
//     step_double(ref acc, @mock_pre_compute(), ECGroup::one());
// }

// #[test]
// #[available_gas(100000000)]
// fn g2_dbl() -> AffineG2 {
//     ECGroup::one().double()
// }

// #[test]
// #[available_gas(100000000)]
// fn g2_add() -> AffineG2 {
//     ECGroup::one().add(pt2())
// }

