pub use fq_types::{Fq12Direct, Fq4Direct};
use fq_types::{FieldOps, FieldUtils};
use schwartz_zippel::{Lines, SchZipManagerTrait, SchZipEvalTrait};

#[derive(Drop)]
pub struct SchZipQRRLC<TFq> {
    // commitment, fiat shamir and rlc data
    pub lookup: @SchZipQRRLCPrecompute<TFq>,
    // temporary equation rhs evaluation
    pub eq_acc: TFq,
    // index of equation (remainder) being processed, used for rlc
    pub eq_count: u32,
    // accumulation of all equation rhs and lhs to compare against qrlc
    pub acc: TFq,
    // remainder cache for next equation
    pub rem_cache: TFq,
}

#[derive(Drop)]
pub struct SchZipQRRLCPrecompute<TFq> {
    pub remainders: Array<Fq12Direct<TFq>>,
    pub qrlc: Array<TFq>,
    pub fiat_shamir: Array<TFq>,
    pub rlc: Array<TFq>,
}

pub impl SchZipManagerQuoRemRLC<
    TCurve,
    TFq,
    +SchZipEvalTrait<TCurve, TFq>,
    +FieldOps<TCurve, TFq>,
    +Drop<TCurve>,
    +Copy<TFq>,
    +Drop<TFq>
> of SchZipManagerTrait<TCurve, TFq, SchZipQRRLC<TFq>> {
    // initiates an equation for verification
    fn init(ref self: SchZipQRRLC<TFq>, ref curve: TCurve) {}

    fn start_equation(ref self: SchZipQRRLC<TFq>, ref curve: TCurve, val_fq12: Fq12Direct<TFq>) {
        self.eq_acc = self.rem_cache;
    }

    // evaluate and accumulate Fq12 for verification
    fn start_equation_sq(ref self: SchZipQRRLC<TFq>, ref curve: TCurve, val_fq12: Fq12Direct<TFq>) {
        self.eq_acc = curve.sqr(self.rem_cache);
    }

    fn mul_fq12(ref self: SchZipQRRLC<TFq>, ref curve: TCurve, val_fq12: Fq12Direct<TFq>) { //
        self.eq_acc = curve.mul(self.eq_acc, curve.eval_fq12(val_fq12, self.lookup.fiat_shamir));
    }

    // evaluate and accumulate Fq034 for verification
    fn mul_f1379(ref self: SchZipQRRLC<TFq>, ref curve: TCurve, val_f1379: Fq4Direct<TFq>) {
        self.eq_acc = curve.mul(self.eq_acc, curve.eval_f1379(val_f1379, self.lookup.fiat_shamir));
    }

    // evaluate and accumulate arbitrary polynomial for verification
    fn mul_poly(ref self: SchZipQRRLC<TFq>, ref curve: TCurve, poly: Array<TFq>) {
        self.eq_acc = curve.mul(self.eq_acc, curve.eval_poly(@poly, self.lookup.fiat_shamir));
    }

    // subtract evaluation from equation
    fn sub_evaluation(ref self: SchZipQRRLC<TFq>, ref curve: TCurve, eval: TFq) { //
        self.eq_acc = curve.sub(self.eq_acc, eval);
    }

    // equation completed, store for verification
    fn finish_equation(ref self: SchZipQRRLC<TFq>, ref curve: TCurve) { //
        self.eq_count += 1;
        let eq_acc = curve.mul(self.eq_acc, *self.lookup.rlc.at(self.eq_count));
        self.acc = curve.add(self.acc, eq_acc);
    }

    // verify the equations stored
    fn verify(ref self: SchZipQRRLC<TFq>, ref curve: TCurve) { //
    //
    }
}
