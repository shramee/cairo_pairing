pub use fq_types::{Fq12Direct, Fq4Direct};
use fq_types::{FieldOps, FieldUtils};

pub trait SchZipEvalTrait<TCurve, TFq> {
    fn eval_fq12(ref self: TCurve, a: Fq12Direct<TFq>, fiat_shamir: @Array<TFq>) -> TFq;
    fn eval_f1379(ref self: TCurve, a: Fq4Direct<TFq>, fiat_shamir: @Array<TFq>) -> TFq;
    fn eval_poly(ref self: TCurve, a: Array<TFq>, fiat_shamir: @Array<TFq>) -> TFq;
}
pub impl SchZipEval<
    TCurve,
    TFq,
    +FieldOps<TCurve, TFq>,
    +FieldUtils<TCurve, TFq>,
    +Copy<TFq>,
    +Drop<TFq>,
    +Drop<TCurve>
> of SchZipEvalTrait<TCurve, TFq> {
    fn eval_fq12(ref self: TCurve, a: Fq12Direct<TFq>, fiat_shamir: @Array<TFq>) -> TFq {
        let ((a0, a1, a2, a3), (a4, a5, a6, a7), (a8, a9, a10, a11)) = a;

        // First term doesn't require multiplication
        let mut acc = a0;

        // terms 1 to 11
        let term_1 = self.mul((*fiat_shamir[1]), a1);
        let term_2 = self.mul((*fiat_shamir[2]), a2);
        let term_3 = self.mul((*fiat_shamir[3]), a3);
        let term_4 = self.mul((*fiat_shamir[4]), a4);
        let term_5 = self.mul((*fiat_shamir[5]), a5);
        let term_6 = self.mul((*fiat_shamir[6]), a6);
        let term_7 = self.mul((*fiat_shamir[7]), a7);
        let term_8 = self.mul((*fiat_shamir[8]), a8);
        let term_9 = self.mul((*fiat_shamir[9]), a9);
        let term_10 = self.mul((*fiat_shamir[10]), a10);
        let term_11 = self.mul((*fiat_shamir[11]), a11);

        // accumulate terms 1 to 11
        acc = self.add(acc, term_1);
        acc = self.add(acc, term_2);
        acc = self.add(acc, term_3);
        acc = self.add(acc, term_4);
        acc = self.add(acc, term_5);
        acc = self.add(acc, term_6);
        acc = self.add(acc, term_7);
        acc = self.add(acc, term_8);
        acc = self.add(acc, term_9);
        acc = self.add(acc, term_10);
        acc = self.add(acc, term_11);
        acc
    }

    fn eval_f1379(ref self: TCurve, a: Fq4Direct<TFq>, fiat_shamir: @Array<TFq>) -> TFq {
        let (a1, a3, a7, a9) = a;

        // First term is one, no multiplication required
        let mut acc = self.one();

        // terms 1, 3, 7 and 9
        let term_1 = self.mul((*fiat_shamir[1]), a1);
        let term_3 = self.mul((*fiat_shamir[3]), a3);
        let term_7 = self.mul((*fiat_shamir[7]), a7);
        let term_9 = self.mul((*fiat_shamir[9]), a9);

        // accumulate terms 1, 3, 7 and 9
        acc = self.add(acc, term_1);
        acc = self.add(acc, term_3);
        acc = self.add(acc, term_7);
        acc = self.add(acc, term_9);

        acc
    }

    fn eval_poly(ref self: TCurve, a: Array<TFq>, fiat_shamir: @Array<TFq>) -> TFq {
        let len = a.len();

        if len == 0 {
            return self.zero();
        }

        let mut i = 1;
        let mut acc = *a[0];

        while i != len {
            let term = self.mul((*fiat_shamir[i]), *a[i]);
            acc = self.add(acc, term);
            i += 1;
        };
        acc
    }
}
