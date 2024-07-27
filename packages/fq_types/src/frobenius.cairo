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

pub mod frobenius_bn254 {
    use super::{Frobenius1To3, FrobeniusFq6Maps, FrobeniusFq12Maps,};
    use fq_types::{Fq2, Fq3, FieldOps, Fq2Ops, FieldUtils, fq2_conjugate, fq2_scale, fq3_scale};
    type Fq6<T> = Fq3<Fq2<T>>;

    pub impl FrobFq6<
        TCurve,
        TFq,
        +FieldOps<TCurve, Fq2<TFq>>,
        +FieldOps<TCurve, TFq>,
        +Copy<TFq>,
        +Drop<TFq>,
        +Drop<TCurve>,
    > of Frobenius1To3<TCurve, Fq6<TFq>, FrobeniusFq6Maps<TFq>> {
        fn frob1(ref self: TCurve, a: Fq6<TFq>, maps: @FrobeniusFq6Maps<TFq>) -> Fq6<TFq> {
            let Fq3 { c0, c1, c2 } = a;
            Fq3 {
                c0: fq2_conjugate(ref self, c0),
                c1: self.mul(fq2_conjugate(ref self, c1), *maps.frob1_c1),
                c2: self.mul(fq2_conjugate(ref self, c2), *maps.frob1_c2),
            }
        }

        fn frob2(ref self: TCurve, a: Fq6<TFq>, maps: @FrobeniusFq6Maps<TFq>) -> Fq6<TFq> {
            let Fq3 { c0, c1, c2 } = a;
            Fq3 { //
                c0: c0,
                c1: fq2_scale(ref self, c1, *maps.frob2_c1.c0), // maps.frob2_c1.c1 is zero
                c2: fq2_scale(ref self, c2, *maps.frob2_c2.c0), // maps.frob2_c2.c1 is zero
            }
        }

        fn frob3(ref self: TCurve, a: Fq6<TFq>, maps: @FrobeniusFq6Maps<TFq>) -> Fq6<TFq> {
            let Fq3 { c0, c1, c2 } = a;
            Fq3 {
                c0: fq2_conjugate(ref self, c0),
                c1: self.mul(fq2_conjugate(ref self, c1), *maps.frob3_c1),
                c2: self.mul(fq2_conjugate(ref self, c2), *maps.frob3_c2),
            }
        }
    }

    pub impl FrobFq12<
        TCurve,
        TFq,
        +FieldOps<TCurve, Fq2<TFq>>,
        +FieldOps<TCurve, TFq>,
        +Copy<TFq>,
        +Drop<TFq>,
        +Drop<TCurve>,
    > of Frobenius1To3<TCurve, Fq2<Fq6<TFq>>, FrobeniusFq12Maps<TFq>> {
        fn frob1(
            ref self: TCurve, a: Fq2<Fq6<TFq>>, maps: @FrobeniusFq12Maps<TFq>
        ) -> Fq2<Fq6<TFq>> {
            let Fq2 { c0, c1 } = a;
            Fq2 { //
                c0: self.frob1(c0, maps.fq6),
                c1: fq3_scale(ref self, self.frob1(c1, maps.fq6), *maps.frob1_c1),
            }
        }

        fn frob2(
            ref self: TCurve, a: Fq2<Fq6<TFq>>, maps: @FrobeniusFq12Maps<TFq>
        ) -> Fq2<Fq6<TFq>> {
            let Fq2 { c0, c1 } = a;
            let Fq3 { c0: b0, c1: b1, c2: b2 } = self.frob2(c1, maps.fq6);
            Fq2 { //
                c0: self.frob2(c0, maps.fq6), //
                c1: Fq3 {
                    c0: fq2_scale(ref self, b0, *maps.frob2_c1.c0),
                    c1: fq2_scale(ref self, b1, *maps.frob2_c1.c0),
                    c2: fq2_scale(ref self, b2, *maps.frob2_c1.c0),
                },
            }
        }

        fn frob3(
            ref self: TCurve, a: Fq2<Fq6<TFq>>, maps: @FrobeniusFq12Maps<TFq>
        ) -> Fq2<Fq6<TFq>> {
            let Fq2 { c0, c1 } = a;
            Fq2 { //
                c0: self.frob3(c0, maps.fq6), //
                c1: fq3_scale(ref self, self.frob3(c1, maps.fq6), *maps.frob3_c1),
            }
        }
    }
}
