use bn::fast_mod::bn254::{add, sub, mul, div, add_inverse};
use bn::traits::FieldOperations;
use bn::fields::{Fq, Fq2, Fq6, Fq12};

// impl TFqAdd<TFq, +FieldOperations<TFq>> of Add<TFq> {
impl TFqAdd<TFq, impl TFqOps: FieldOperations<TFq>> of Add<TFq> {
    #[inline(always)]
    fn add(lhs: TFq, rhs: TFq) -> TFq {
        TFqOps::add(lhs, rhs)
    }
}
impl TFqSub<TFq, impl TFqOps: FieldOperations<TFq>> of Sub<TFq> {
    #[inline(always)]
    fn sub(lhs: TFq, rhs: TFq) -> TFq {
        TFqOps::sub(lhs, rhs)
    }
}
impl TFqMul<TFq, impl TFqOps: FieldOperations<TFq>> of Mul<TFq> {
    #[inline(always)]
    fn mul(lhs: TFq, rhs: TFq) -> TFq {
        TFqOps::mul(lhs, rhs)
    }
}
impl TFqDiv<TFq, impl TFqOps: FieldOperations<TFq>> of Div<TFq> {
    #[inline(always)]
    fn div(lhs: TFq, rhs: TFq) -> TFq {
        TFqOps::div(lhs, rhs)
    }
}
impl TFqNeg<TFq, impl TFqOps: FieldOperations<TFq>> of Neg<TFq> {
    #[inline(always)]
    fn neg(a: TFq) -> TFq {
        TFqOps::neg(a)
    }
}

impl TFqPartialEq<TFq, impl TFqOps: FieldOperations<TFq>> of PartialEq<TFq> {
    #[inline(always)]
    fn eq(lhs: @TFq, rhs: @TFq) -> bool {
        TFqOps::eq(lhs, rhs)
    }

    #[inline(always)]
    fn ne(lhs: @TFq, rhs: @TFq) -> bool {
        !TFqOps::eq(lhs, rhs)
    }
}

