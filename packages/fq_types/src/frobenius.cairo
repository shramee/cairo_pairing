use fq_types::{Fq2, Fq3, FieldOps, FieldUtils, fq2_conjugate, fq2_scale};

#[derive(Drop)]
pub struct FrobeniusFq12Maps<TFq> {
    pub frob1_c1: Fq2<TFq>,
    pub frob2_c1: Fq2<TFq>,
    pub frob3_c1: Fq2<TFq>,
    pub fq6: FrobeniusFq6Maps<TFq>,
}

#[derive(Drop)]
pub struct FrobeniusFq6Maps<TFq> {
    pub frob1_c1: Fq2<TFq>,
    pub frob1_c2: Fq2<TFq>,
    pub frob2_c1: Fq2<TFq>,
    pub frob2_c2: Fq2<TFq>,
    pub frob3_c1: Fq2<TFq>,
    pub frob3_c2: Fq2<TFq>,
}


pub trait Frobenius1To3<TCurve, TFq, TFrobMap> {
    fn frob1(ref self: TCurve, a: TFq, maps: @TFrobMap) -> TFq;
    fn frob2(ref self: TCurve, a: TFq, maps: @TFrobMap) -> TFq;
    fn frob3(ref self: TCurve, a: TFq, maps: @TFrobMap) -> TFq;
}

