use super::{Fq2, Fq3, FieldOps, FieldUtils};

pub impl Fq2PartialEq<TFq, +PartialEq<TFq>> of PartialEq<Fq2<TFq>> {
    #[inline(always)]
    fn eq(lhs: @Fq2<TFq>, rhs: @Fq2<TFq>) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1
    }

    #[inline(always)]
    fn ne(lhs: @Fq2<TFq>, rhs: @Fq2<TFq>) -> bool {
        lhs.c0 != rhs.c0 && lhs.c1 != rhs.c1
    }
}

pub impl Fq3PartialEq<TFq, +PartialEq<TFq>> of PartialEq<Fq3<TFq>> {
    #[inline(always)]
    fn eq(lhs: @Fq3<TFq>, rhs: @Fq3<TFq>) -> bool {
        lhs.c0 == rhs.c0 && lhs.c1 == rhs.c1 && lhs.c2 == rhs.c2
    }

    #[inline(always)]
    fn ne(lhs: @Fq3<TFq>, rhs: @Fq3<TFq>) -> bool {
        lhs.c0 != rhs.c0 && lhs.c1 != rhs.c1 && lhs.c2 != rhs.c2
    }
}

pub impl Fq2Ops<
    TCurve,
    TFq,
    impl FqUtils: FieldUtils<TCurve, TFq>,
    impl FqOps: FieldOps<TCurve, TFq>,
    +Drop<TFq>,
    +Copy<TFq>
> of FieldOps<TCurve, Fq2<TFq>> {
    #[inline(always)]
    fn add(ref self: TCurve, lhs: Fq2<TFq>, rhs: Fq2<TFq>) -> Fq2<TFq> {
        lhs.c0;
        Fq2 { c0: FqOps::add(ref self, lhs.c0, rhs.c0), c1: FqOps::add(ref self, lhs.c1, rhs.c1), }
    }

    #[inline(always)]
    fn sub(ref self: TCurve, lhs: Fq2<TFq>, rhs: Fq2<TFq>) -> Fq2<TFq> {
        Fq2 { c0: FqOps::sub(ref self, lhs.c0, rhs.c0), c1: FqOps::sub(ref self, lhs.c1, rhs.c1), }
    }

    #[inline(always)]
    fn neg(ref self: TCurve, lhs: Fq2<TFq>) -> Fq2<TFq> {
        Fq2 { c0: FqOps::neg(ref self, lhs.c0,), c1: FqOps::neg(ref self, lhs.c1,), }
    }

    #[inline(always)]
    fn eq(self: @TCurve, lhs: @Fq2<TFq>, rhs: @Fq2<TFq>) -> bool {
        self.eq(lhs.c0, rhs.c0) && self.eq(lhs.c1, rhs.c1)
    }

    fn mul(ref self: TCurve, lhs: Fq2<TFq>, rhs: Fq2<TFq>) -> Fq2<TFq> {
        // Karatsuba multiplication
        let Fq2 { c0: a0, c1: a1 } = lhs;
        let Fq2 { c0: b0, c1: b1 } = rhs;
        let v0 = self.mul(a0, b0);
        let v1 = self.mul(a1, b1);
        // v0 + βv1
        let c0 = self.add(v0, self.mul_by_nonresidue(v1));
        // (a0 + a1) * (b0 + b1) - v0 - v1
        let t0 = self.add(a0, a1); // a0 + a1
        let t1 = self.add(b0, b1); // b0 + b1
        let t2 = self.mul(t0, t1); // (a0 + a1) * (b0 + b1)
        let t3 = self.sub(t2, v0); // (a0 + a1) * (b0 + b1) - v0
        let c1 = self.sub(t3, v1); // (a0 + a1) * (b0 + b1) - v0 - v1
        Fq2 { c0, c1 }
    }

    fn div(ref self: TCurve, lhs: Fq2<TFq>, rhs: Fq2<TFq>) -> Fq2<TFq> {
        self.mul(lhs, self.inv(rhs))
    }

    fn sqr(ref self: TCurve, lhs: Fq2<TFq>) -> Fq2<TFq> {
        // Complex squaring
        let Fq2 { c0: a0, c1: a1 } = lhs;
        // v = a0 * a1;
        let v = FqOps::mul(ref self, a0, a1); // a0 * a1

        // (a0 + a1) * (a0 + βa1) - v - βv
        let t0 = FqOps::add(ref self, a0, a1); // a0 + a1
        let a1_nr = self.mul_by_nonresidue(a1); // βa1
        let t1 = FqOps::add(ref self, a0, a1_nr); // a0 + βa1
        let t2 = FqOps::mul(ref self, t0, t1); // (a0 + a1) * (a0 + βa1)
        let v_nr = self.mul_by_nonresidue(v); // βv
        let c0 = FqOps::sub(ref self, t2, v_nr); // (a0 + a1) * (a0 + βa1) - v - βv
        // c1 = v + v;
        let c1 = FqOps::add(ref self, v, v); // 2v
        Fq2 { c0, c1 }
    }

    fn inv(ref self: TCurve, lhs: Fq2<TFq>) -> Fq2<TFq> {
        let Fq2 { c0, c1 } = lhs;
        // let t = (c0.sqr() - (c1.sqr().mul_by_nonresidue())).inv();
        let t0 = self.sqr(c0); // c0.sqr()
        let t1 = self.sqr(c1); // c1.sqr()
        let t2 = self.mul_by_nonresidue(t1); // c1.sqr().mul_by_nonresidue()
        let t3 = self.sub(t0, t2); // c0.sqr() - c1.sqr().mul_by_nonresidue()
        let t = self.inv(t3); // (c0.sqr() - c1.sqr().mul_by_nonresidue()).inv()

        let new_c0 = self.mul(c0, t); // c0 * t
        let neg_t = self.neg(t); // -t
        let new_c1 = self.mul(c1, neg_t); // c1 * -t
        Fq2 { c0: new_c0, c1: new_c1 }
    }
}

pub impl Fq3Ops<
    TCurve,
    TFq,
    impl FqUtils: FieldUtils<TCurve, TFq>,
    impl FqOps: FieldOps<TCurve, TFq>,
    +Drop<TFq>,
    +Copy<TFq>
> of FieldOps<TCurve, Fq3<TFq>> {
    #[inline(always)]
    fn add(ref self: TCurve, lhs: Fq3<TFq>, rhs: Fq3<TFq>) -> Fq3<TFq> {
        Fq3 {
            c0: FqOps::add(ref self, lhs.c0, rhs.c0),
            c1: FqOps::add(ref self, lhs.c1, rhs.c1),
            c2: FqOps::add(ref self, lhs.c2, rhs.c2),
        }
    }

    #[inline(always)]
    fn sub(ref self: TCurve, lhs: Fq3<TFq>, rhs: Fq3<TFq>) -> Fq3<TFq> {
        Fq3 {
            c0: FqOps::sub(ref self, lhs.c0, rhs.c0),
            c1: FqOps::sub(ref self, lhs.c1, rhs.c1),
            c2: FqOps::sub(ref self, lhs.c2, rhs.c2),
        }
    }

    #[inline(always)]
    fn neg(ref self: TCurve, lhs: Fq3<TFq>) -> Fq3<TFq> {
        Fq3 {
            c0: FqOps::neg(ref self, lhs.c0,),
            c1: FqOps::neg(ref self, lhs.c1,),
            c2: FqOps::neg(ref self, lhs.c2,),
        }
    }

    #[inline(always)]
    fn eq(self: @TCurve, lhs: @Fq3<TFq>, rhs: @Fq3<TFq>) -> bool {
        FqOps::eq(self, lhs.c0, rhs.c0)
            && FqOps::eq(self, lhs.c1, rhs.c1)
            && FqOps::eq(self, lhs.c2, rhs.c2)
    }

    fn mul(ref self: TCurve, lhs: Fq3<TFq>, rhs: Fq3<TFq>) -> Fq3<TFq> { //
        let Fq3 { c0: a0, c1: a1, c2: a2 } = lhs;
        let Fq3 { c0: b0, c1: b1, c2: b2 } = rhs;

        let v0 = FqOps::mul(ref self, a0, b0); // a0 * b0
        let v1 = FqOps::mul(ref self, a1, b1); // a1 * b1
        let v2 = FqOps::mul(ref self, a2, b2); // a2 * b2

        let t0 = FqOps::add(ref self, a1, a2); // a1 + a2
        let t1 = FqOps::add(ref self, b1, b2); // b1 + b2
        let t2 = FqOps::mul(ref self, t0, t1); // (a1 + a2) * (b1 + b2)
        let t3 = FqOps::sub(ref self, t2, v1); // (a1 + a2) * (b1 + b2) - v1
        let t4 = FqOps::sub(ref self, t3, v2); // (a1 + a2) * (b1 + b2) - v1 - v2
        let t5 = FqUtils::mul_by_nonresidue(ref self, t4); // ξ((a1 + a2) * (b1 + b2) - v1 - v2)
        let c0 = FqOps::add(ref self, v0, t5); // v0 + ξ((a1 + a2) * (b1 + b2) - v1 - v2)

        let t6 = FqOps::add(ref self, a0, a1); // a0 + a1
        let t7 = FqOps::add(ref self, b0, b1); // b0 + b1
        let t8 = FqOps::mul(ref self, t6, t7); // (a0 + a1) * (b0 + b1)
        let t9 = FqOps::sub(ref self, t8, v0); // (a0 + a1) * (b0 + b1) - v0
        let t10 = FqOps::sub(ref self, t9, v1); // (a0 + a1) * (b0 + b1) - v0 - v1
        let t11 = FqUtils::mul_by_nonresidue(ref self, v2); // ξv2
        let c1 = FqOps::add(ref self, t10, t11); // (a0 + a1) * (b0 + b1) - v0 - v1 + ξv2

        let t12 = FqOps::add(ref self, a0, a2); // a0 + a2
        let t13 = FqOps::add(ref self, b0, b2); // b0 + b2
        let t14 = FqOps::mul(ref self, t12, t13); // (a0 + a2) * (b0 + b2)
        let t15 = FqOps::sub(ref self, t14, v0); // (a0 + a2) * (b0 + b2) - v0
        let t16 = FqOps::add(ref self, t15, v1); // (a0 + a2) * (b0 + b2) - v0 + v1
        let c2 = FqOps::sub(ref self, t16, v2); // (a0 + a2) * (b0 + b2) - v0 + v1 - v2

        Fq3 { c0, c1, c2 }
    }

    fn div(ref self: TCurve, lhs: Fq3<TFq>, rhs: Fq3<TFq>) -> Fq3<TFq> { //
        self.mul(lhs, self.inv(rhs))
    }

    fn sqr(ref self: TCurve, lhs: Fq3<TFq>) -> Fq3<TFq> { //
        let Fq3 { c0, c1, c2 } = lhs;

        let s0 = FqOps::sqr(ref self, c0); // c0.sqr()
        let ab = FqOps::mul(ref self, c0, c1); // c0 * c1
        let s1 = FqOps::add(ref self, ab, ab); // ab + ab

        let t0 = FqOps::add(ref self, c0, c2); // c0 + c2
        let t1 = FqOps::sub(ref self, t0, c1); // c0 + c2 - c1
        let s2 = FqOps::sqr(ref self, t1); // (c0 + c2 - c1).sqr()

        let bc = FqOps::mul(ref self, c1, c2); // c1 * c2

        let s3 = FqOps::add(ref self, bc, bc); // bc + bc

        let s4 = FqOps::sqr(ref self, c2); // c2.sqr()

        let s3_nonresidue = FqUtils::mul_by_nonresidue(ref self, s3); // s3ξ
        let new_c0 = FqOps::add(ref self, s0, s3_nonresidue); // s0 + s3ξ

        let s4_nonresidue = FqUtils::mul_by_nonresidue(ref self, s4); // s4ξ
        let new_c1 = FqOps::add(ref self, s1, s4_nonresidue); // s1 + s4ξ

        let t2 = FqOps::add(ref self, s1, s2); // s1 + s2
        let t3 = FqOps::add(ref self, t2, s3); // s1 + s2 + s3
        let t4 = FqOps::sub(ref self, t3, s0); // s1 + s2 + s3 - s0
        let new_c2 = FqOps::sub(ref self, t4, s4); // s1 + s2 + s3 - s0 - s4

        Fq3 { c0: new_c0, c1: new_c1, c2: new_c2 }
    }

    fn inv(ref self: TCurve, lhs: Fq3<TFq>) -> Fq3<TFq> { //
        let Fq3 { c0, c1, c2 } = lhs;

        let c0_sq = FqOps::sqr(ref self, c0); // c0.sqr()
        let c2_nr = FqUtils::mul_by_nonresidue(ref self, c2); // c2ξ
        let c1_c2_nr = FqOps::mul(ref self, c1, c2_nr); // c1 * c2ξ
        let v0 = FqOps::sub(ref self, c0_sq, c1_c2_nr); // c0.sqr() - c1 * c2ξ

        let c2_sq = FqOps::sqr(ref self, c2); // c2.sqr()
        let c0_c1 = FqOps::mul(ref self, c0, c1); // c0 * c1
        let c2_sq_nr = FqUtils::mul_by_nonresidue(ref self, c2_sq);
        let v1 = FqOps::sub(ref self, c2_sq_nr, c0_c1); // c2.sqr()ξ - c0 * c1

        let c1_sq = FqOps::sqr(ref self, c1); // c1.sqr()
        let c0_c2 = FqOps::mul(ref self, c0, c2); // c0 * c2
        let v2 = FqOps::sub(ref self, c1_sq, c0_c2); // c1.sqr() - c0 * c2

        let t0 = FqOps::mul(ref self, c2, v1); // c2 * v1
        let t1 = FqOps::mul(ref self, c1, v2); // c1 * v2
        let t2 = FqOps::add(ref self, t0, t1); // c2 * v1 + c1 * v2
        let t3 = FqUtils::mul_by_nonresidue(ref self, t2); // (c2 * v1 + c1 * v2)ξ
        let t4 = FqOps::mul(ref self, c0, v0); // c0 * v0
        let t5 = FqOps::add(ref self, t3, t4); // (c2 * v1 + c1 * v2)ξ + c0 * v0
        let t = FqOps::inv(ref self, t5); // ((c2 * v1 + c1 * v2)ξ + c0 * v0).inv()

        let new_c0 = FqOps::mul(ref self, t, v0); // t * v0
        let new_c1 = FqOps::mul(ref self, t, v1); // t * v1
        let new_c2 = FqOps::mul(ref self, t, v2); // t * v2

        Fq3 { c0: new_c0, c1: new_c1, c2: new_c2 }
    }
}
