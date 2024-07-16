pub use fq_types::{FieldOps, FieldOpsExtended, FieldUtils};
pub use fast_mod::{add, sub, mul_nz, sqr_nz, div_nz, inv, neg, scl_nz};
pub use bn254_u256::Bn254U256Curve;

#[derive(Copy, Drop, Serde, Debug)]
pub struct Fq {
    pub c0: u256,
}

pub impl U256IntoFq of Into<u256, Fq> {
    #[inline(always)]
    fn into(self: u256) -> Fq {
        Fq { c0: self }
    }
}

#[inline(always)]
pub fn scale_9(ref self: Bn254U256Curve, a: Fq) -> Fq {
    let a2 = self.add(a, a); // 2a
    let a4 = self.add(a2, a2); // 4a
    self.add(self.add(a4, a4), a) // 8a + a
}

pub impl Bn254FqOps of FieldOps<Bn254U256Curve, Fq> {
    fn add(ref self: Bn254U256Curve, lhs: Fq, rhs: Fq) -> Fq {
        add(lhs.c0, rhs.c0, self.q).into()
    }
    fn sub(ref self: Bn254U256Curve, lhs: Fq, rhs: Fq) -> Fq {
        sub(lhs.c0, rhs.c0, self.q).into()
    }
    fn neg(ref self: Bn254U256Curve, lhs: Fq) -> Fq {
        neg(lhs.c0, self.q).into()
    }
    fn eq(self: @Bn254U256Curve, lhs: @Fq, rhs: @Fq) -> bool {
        lhs.c0 == rhs.c0
    }
    fn mul(ref self: Bn254U256Curve, lhs: Fq, rhs: Fq) -> Fq {
        mul_nz(lhs.c0, rhs.c0, self.qnz).into()
    }
    fn div(ref self: Bn254U256Curve, lhs: Fq, rhs: Fq) -> Fq {
        div_nz(lhs.c0, rhs.c0, self.qnz).into()
    }
    fn sqr(ref self: Bn254U256Curve, lhs: Fq) -> Fq {
        sqr_nz(lhs.c0, self.qnz).into()
    }
    fn inv(ref self: Bn254U256Curve, lhs: Fq) -> Fq {
        inv(lhs.c0, self.qnz).into()
    }
}

pub impl Bn254FqUtils of FieldUtils<Bn254U256Curve, Fq> {
    fn one(ref self: Bn254U256Curve) -> Fq {
        Fq { c0: 1 }
    }
    fn zero(ref self: Bn254U256Curve) -> Fq {
        Fq { c0: 0 }
    }
    fn conjugate(ref self: Bn254U256Curve, el: Fq) -> Fq {
        core::panic_with_felt252('no_impl: fq conjugate');
        el
    }
    fn mul_by_nonresidue(ref self: Bn254U256Curve, el: Fq) -> Fq {
        self.neg(el)
    }
    fn frobenius_map(ref self: Bn254U256Curve, el: Fq, power: usize) -> Fq {
        core::panic_with_felt252('no_impl: fq frobenius_map');
        el
    }
}
