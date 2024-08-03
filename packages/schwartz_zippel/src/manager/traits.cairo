// Schwartz-Zippel manager for Cairo
// This allows adding values for Schwartz Zippel commitments and verifying the Schwartz Zippel equation
// Can be run for evaluation or coefficient generation.

pub use fq_types::{Fq12Direct, Fq4Direct};
use fq_types::{FieldOps, FieldUtils};

pub trait SchZipManagerTrait<TCurve, TFq, TSchZip> {
    // initiates an equation for verification
    fn start_equation(ref self: TSchZip, ref curve: TCurve, initial_acc: TFq);

    // evaluate and accumulate Fq12 for verification
    fn mul_fq12(ref self: TSchZip, ref curve: TCurve, val_fq12: Fq12Direct<TFq>);

    // evaluate and accumulate Fq034 for verification
    fn mul_f1379(ref self: TSchZip, ref curve: TCurve, val_f1379: Fq4Direct<TFq>);

    // evaluate and accumulate arbitrary polynomial for verification
    fn mul_poly(ref self: TSchZip, ref curve: TCurve, poly: Array<TFq>);

    // subtract evaluation from equation
    fn sub_evaluation(ref self: TSchZip, ref curve: TCurve, eval: TFq);

    // equation completed, store for verification
    fn finish_equation(ref self: TSchZip, ref curve: TCurve);

    // verify the equations stored
    fn verify(ref self: TSchZip, ref curve: TCurve);
}
