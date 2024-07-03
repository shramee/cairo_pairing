use super::{Fq2, Fq3, FieldCommonOps, FieldOps, FieldOpsUnreduced};

pub impl Fq2CommonOps<T, +FieldCommonOps<T>, +Drop<T>> of FieldCommonOps<Fq2<T>> {
    #[inline(always)]
    fn add(self: Fq2<T>, rhs: Fq2<T>) -> Fq2<T> {
        Fq2 { c0: self.c0.add(rhs.c0), c1: self.c1.add(rhs.c1), }
    }

    #[inline(always)]
    fn sub(self: Fq2<T>, rhs: Fq2<T>) -> Fq2<T> {
        Fq2 { c0: self.c0.sub(rhs.c0), c1: self.c1.sub(rhs.c1), }
    }

    #[inline(always)]
    fn neg(self: Fq2<T>) -> Fq2<T> {
        Fq2 { c0: self.c0.neg(), c1: self.c1.neg(), }
    }

    #[inline(always)]
    fn eq(self: @Fq2<T>, rhs: @Fq2<T>) -> bool {
        self.c0.eq(rhs.c0) && self.c1.eq(rhs.c1)
    }
}

pub impl Fq3CommonOps<T, +FieldCommonOps<T>, +Drop<T>> of FieldCommonOps<Fq3<T>> {
    #[inline(always)]
    fn add(self: Fq3<T>, rhs: Fq3<T>) -> Fq3<T> {
        Fq3 { c0: self.c0.add(rhs.c0), c1: self.c1.add(rhs.c1), c2: self.c2.add(rhs.c2), }
    }

    #[inline(always)]
    fn sub(self: Fq3<T>, rhs: Fq3<T>) -> Fq3<T> {
        Fq3 { c0: self.c0.sub(rhs.c0), c1: self.c1.sub(rhs.c1), c2: self.c2.sub(rhs.c2), }
    }

    #[inline(always)]
    fn neg(self: Fq3<T>) -> Fq3<T> {
        Fq3 { c0: self.c0.neg(), c1: self.c1.neg(), c2: self.c2.neg(), }
    }

    #[inline(always)]
    fn eq(self: @Fq3<T>, rhs: @Fq3<T>) -> bool {
        self.c0.eq(rhs.c0) && self.c1.eq(rhs.c1) && self.c2.eq(rhs.c2)
    }
}
