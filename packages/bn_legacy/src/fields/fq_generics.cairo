use bn::curve::{add, sub, mul, div, neg};
use bn::traits::FieldOps;
use bn::fields::{Fq, Fq2, Fq6, Fq12};

// impl TFqAdd<TFq, +FieldOps<TFq>> of Add<TFq> {

impl TFqAdd<TFq, +FieldOps<TFq>> of Add<TFq> {
    #[inline(always)]
    fn add(lhs: TFq, rhs: TFq) -> TFq {
        FieldOps::add(lhs, rhs)
    }
}
impl TFqSub<TFq, +FieldOps<TFq>> of Sub<TFq> {
    #[inline(always)]
    fn sub(lhs: TFq, rhs: TFq) -> TFq {
        FieldOps::sub(lhs, rhs)
    }
}
impl TFqMul<TFq, +FieldOps<TFq>> of Mul<TFq> {
    #[inline(always)]
    fn mul(lhs: TFq, rhs: TFq) -> TFq {
        FieldOps::mul(lhs, rhs)
    }
}
impl TFqDiv<TFq, +FieldOps<TFq>> of Div<TFq> {
    #[inline(always)]
    fn div(lhs: TFq, rhs: TFq) -> TFq {
        FieldOps::div(lhs, rhs)
    }
}
impl TFqNeg<TFq, +FieldOps<TFq>> of Neg<TFq> {
    #[inline(always)]
    fn neg(a: TFq) -> TFq {
        FieldOps::neg(a)
    }
}

impl TFqPartialEq<TFq, +FieldOps<TFq>> of PartialEq<TFq> {
    #[inline(always)]
    fn eq(lhs: @TFq, rhs: @TFq) -> bool {
        FieldOps::eq(lhs, rhs)
    }

    #[inline(always)]
    fn ne(lhs: @TFq, rhs: @TFq) -> bool {
        !FieldOps::eq(lhs, rhs)
    }
}

