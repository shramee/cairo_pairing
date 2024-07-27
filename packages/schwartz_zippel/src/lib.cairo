pub mod eval;
pub use eval::{SchZipEvalTrait, SchZipEval};
pub use fq_types::{Fq2, Fq3, F12S034 as FS034, Fq12Direct};
use pairing::CubicScale;

pub type Lines<T> = (FS034<T>, FS034<T>, FS034<T>);
pub type F034X2<T> = (FS034<T>, FS034<T>);
pub type LinesDbl<T> = (F034X2<T>, F034X2<T>, F034X2<T>);
pub type Residue<T> = (CubicScale, Fq12Direct<T>, Fq12Direct<T>);

pub trait SchZipSteps<TCurve, T, TAcc, TFq, TFq12> {
    fn sz_init(ref self: TCurve, sz: @T, ref sz_acc: TAcc, ref f: TFq12);
    fn sz_zero_bit(
        ref self: TCurve, sz: @T, ref sz_acc: TAcc, ref f: TFq12, lines: Lines<Fq2<TFq>>
    );
    fn sz_nz_bit(
        ref self: TCurve,
        sz: @T,
        ref sz_acc: TAcc,
        ref f: TFq12,
        lines: LinesDbl<Fq2<TFq>>,
        witness: TFq12
    );
    fn sz_last_step(
        ref self: TCurve, sz: @T, ref sz_acc: TAcc, ref f: TFq12, lines: LinesDbl<Fq2<TFq>>
    );

    fn sz_final(
        ref self: TCurve,
        sz: @T,
        ref sz_acc: TAcc,
        ref f: TFq12,
        alpha_beta: TFq12,
        r_pow_q: TFq12,
        r_inv_q2: TFq12,
        r_pow_q3: TFq12,
        cubic_scale: CubicScale
    );

    fn sz_verify(
        ref self: TCurve, sz: @T, ref sz_acc: TAcc, f: TFq12, witness: TFq12, witness_inv: TFq12,
    ) -> bool;
}
