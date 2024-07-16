use fq_types::{Fq2, Fq3, F12S034 as FS034};
use pairing::CubicScale;

pub type Lines<T> = (FS034<T>, FS034<T>, FS034<T>);
pub type F034X2<T> = (FS034<T>, FS034<T>);
pub type LinesDbl<T> = (F034X2<T>, F034X2<T>, F034X2<T>);
pub type Residue<T> = (CubicScale, Fq12<T>, Fq12<T>);

type Fq6<T> = Fq3<Fq2<T>>;
type Fq12<T> = Fq2<Fq6<T>>;

pub trait SchZipSteps<TCurve, T, TAcc, TFq> {
    fn sz_init(ref self: TCurve, sz: @T, ref sz_acc: TAcc, ref f: Fq12<TFq>);
    fn sz_sqr(ref self: TCurve, sz: @T, ref sz_acc: TAcc, ref f: Fq12<TFq>);
    fn sz_zero_bit(
        ref self: TCurve, sz: @T, ref sz_acc: TAcc, ref f: Fq12<TFq>, lines: Lines<Fq2<TFq>>
    );
    fn sz_nz_bit(
        ref self: TCurve,
        sz: @T,
        ref sz_acc: TAcc,
        ref f: Fq12<TFq>,
        lines: LinesDbl<Fq2<TFq>>,
        witness: Fq12<TFq>
    );
    fn sz_last_step(
        ref self: TCurve, sz: @T, ref sz_acc: TAcc, ref f: Fq12<TFq>, lines: LinesDbl<Fq2<TFq>>
    );

    fn sz_post_miller(
        ref self: TCurve,
        sz: @T,
        ref sz_acc: TAcc,
        f: Fq12<TFq>,
        alpha_beta: Fq12<TFq>,
        residue: Residue<TFq>
    ) -> bool;
}
