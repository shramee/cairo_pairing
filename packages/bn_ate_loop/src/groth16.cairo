use ec_groups::Affine;
use fq_types::{Fq2, Fq3};

#[derive(Copy, Drop, Serde)]
pub struct PPrecompute<TFq> {
    pub neg_x_over_y: TFq,
    pub y_inv: TFq,
}

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
pub struct Groth16PreCompute<TG1Pts, TG2Pts, TLines, TFq, TFq12> {
    pub p: TG1Pts,
    pub q: TG2Pts,
    pub ppc: TG1Pts,
    pub neg_q: TG2Pts,
    pub lines: TLines,
    pub residue_witness: TFq12,
    pub residue_witness_inv: TFq12,
    pub field_nz: NonZero<u256>,
}
