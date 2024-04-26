trait FieldUtils<TFq, TFqChildren> {
    fn one() -> TFq;
    fn zero() -> TFq;
    fn conjugate(self: TFq) -> TFq;
    fn scale(self: TFq, by: TFqChildren) -> TFq;
    fn mul_by_nonresidue(self: TFq,) -> TFq;
    fn frobenius_map(self: TFq, power: usize) -> TFq;
}

trait FieldShortcuts<TFq> {
    fn u_add(self: TFq, rhs: TFq) -> TFq;
    fn u_sub(self: TFq, rhs: TFq) -> TFq;
    fn fix_mod(self: TFq) -> TFq;
}

trait FieldMulShortcuts<TFq, TFqU512> {
    fn u512_add_fq(self: TFqU512, rhs: TFq) -> TFqU512;
    fn u512_sub_fq(self: TFqU512, rhs: TFq) -> TFqU512;
    fn u_mul(self: TFq, rhs: TFq) -> TFqU512;
    fn u_sqr(self: TFq) -> TFqU512;
    fn to_fq(self: TFqU512, field_nz: NonZero<u256>) -> TFq;
}

trait FieldOps<TFq> {
    fn add(self: TFq, rhs: TFq) -> TFq;
    fn sub(self: TFq, rhs: TFq) -> TFq;
    fn mul(self: TFq, rhs: TFq) -> TFq;
    fn div(self: TFq, rhs: TFq) -> TFq;
    fn sqr(self: TFq) -> TFq;
    fn neg(self: TFq) -> TFq;
    fn eq(lhs: @TFq, rhs: @TFq) -> bool;
    fn inv(self: TFq, field_nz: NonZero<u256>) -> TFq;
}

use bn::fields::Fq12;

trait MillerPrecompute<TG1, TG2, TPreComp> {
    fn precompute(self: (TG1, TG2), field_nz: NonZero<u256>) -> (TPreComp, TG2);
}

trait MillerSteps<TPreComp, TG2> {
    // first and second step
    fn miller_first_second(self: @TPreComp, i1: u32, i2: u32, ref acc: TG2) -> Fq12;

    // 0 bit
    fn miller_bit_o(self: @TPreComp, i: u32, ref acc: TG2, ref f: Fq12);

    // 1 bit
    fn miller_bit_p(self: @TPreComp, i: u32, ref acc: TG2, ref f: Fq12);

    // -1 bit
    fn miller_bit_n(self: @TPreComp, i: u32, ref acc: TG2, ref f: Fq12);

    // last step
    fn miller_last(self: @TPreComp, ref acc: TG2, ref f: Fq12);
}
