use ec_groups::Affine;
use fq_types::{Fq2, Fq3, Fq12Direct, F12S034,};

// region pairing

#[derive(Copy, Drop, Serde)]
pub struct PPrecompute<TFq> {
    pub neg_x_over_y: TFq,
    pub y_inv: TFq,
}

#[derive(Copy, Drop, Serde)]
pub enum CubicScale {
    Zero,
    One,
    Two,
}

#[derive(Copy, Drop)]
pub struct PiMapping<TFq> {
    // for πₚ mapping
    pub PiQ1X2: Fq2<TFq>,
    pub PiQ1X3: Fq2<TFq>,
    // for π² mapping, only Fq2.c0, c1 is 0
    pub PiQ2X2: TFq,
    pub PiQ2X3: TFq,
}

// endregion pairing

// region groth16

#[derive(Drop, Serde)]
pub struct Groth16Circuit<TPtG1, TPtG2, TLines, TIC, TFq12> {
    pub alpha_beta: TFq12,
    pub gamma: TPtG2,
    pub gamma_neg: TPtG2,
    pub delta: TPtG2,
    pub delta_neg: TPtG2,
    pub lines: TLines,
    pub ic: TIC,
}

#[derive(Copy, Drop, Serde)]
pub struct Groth16MillerG1<PtG1> { // Points in G1
    pub pi_a: PtG1,
    pub pi_c: PtG1,
    pub k: PtG1,
}

#[derive(Copy, Drop, Serde)]
pub struct Groth16MillerG2<PtG2> { // Points in G2
    pub pi_b: PtG2,
    pub delta: PtG2,
    pub gamma: PtG2,
}

#[derive(Copy, Drop, Serde)]
pub struct Groth16PreCompute<TG1Pts, TG1Precomputes, TG2Pts, TLines, TPiMap, TFq12> {
    pub p: TG1Pts,
    pub q: TG2Pts,
    pub ppc: TG1Precomputes,
    pub neg_q: TG2Pts,
    pub lines: TLines,
    pub residue_witness: TFq12,
    pub residue_witness_inv: TFq12,
    pub pi_mapping: TPiMap,
}

// endregion groth16

// region lines

#[derive(Copy, Drop, Serde)]
pub struct LineFn<TFq> {
    pub slope: TFq,
    pub c: TFq,
}

pub type LineResult<T> = (F12S034<Fq2<T>>, F12S034<Fq2<T>>);
pub type LnFn<T> = LineFn<Fq2<T>>;

#[derive(Drop, Serde)]
pub struct LinesArrays<TLinesArray> {
    pub gamma: TLinesArray,
    pub delta: TLinesArray,
}

pub type LnArrays<T> = LinesArrays<Array<LnFn<T>>>;

// endregion lines

pub type FqD12<T> = Fq12Direct<T>;

pub type MillerRunner<TFq, TSZ, TAcc> =
    MillerRunnerGeneric<
        Groth16PreCompute<
            Groth16MillerG1<Affine<TFq>>,
            Groth16MillerG1<PPrecompute<TFq>>,
            Groth16MillerG2<Affine<Fq2<TFq>>>,
            LnArrays<TFq>,
            PiMapping<TFq>,
            FqD12<TFq>,
        >,
        TSZ,
        TAcc
    >;


#[derive(Drop)]
pub struct MillerRunnerGeneric<TG16, TSZ, TAcc> {
    pub g16: @TG16,
    pub schzip: TSZ,
    pub acc: TAcc,
}


#[derive(Drop)]
pub struct MillerAccGeneric<TFq12, TG2Pts> {
    pub f: TFq12,
    pub g2: TG2Pts,
    pub line_index: u32,
}

pub type MillerAcc<TFq> = MillerAccGeneric<FqD12<TFq>, Groth16MillerG2<Affine<Fq2<TFq>>>>;
