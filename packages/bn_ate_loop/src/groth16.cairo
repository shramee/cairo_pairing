use ec_groups::Affine;
use fq_types::{Fq2, Fq3};

#[derive(Copy, Drop, Serde)]
pub struct PPrecompute<TFq> {
    neg_x_over_y: TFq,
    y_inv: TFq,
}

#[derive(Drop, Serde)]
pub struct Groth16Circuit<TPtG1, TPtG2, TLines, TIC, TFq12> {
    alpha_beta: TFq12,
    gamma: TPtG2,
    gamma_neg: TPtG2,
    delta: TPtG2,
    delta_neg: TPtG2,
    lines: TLines,
    ic: TIC,
}

#[derive(Copy, Drop, Serde)]
pub struct Groth16MillerG1<PtG1> { // Points in G1
    pi_a: PtG1,
    pi_c: PtG1,
    k: PtG1,
}

#[derive(Copy, Drop, Serde)]
pub struct Groth16MillerG2<PtG2> { // Points in G2
    pi_b: PtG2,
    delta: PtG2,
    gamma: PtG2,
}

#[derive(Copy, Drop, Serde)]
pub struct Groth16PreCompute<TG1Pts, TG2Pts, TLines, TFq, TFq12> {
    p: TG1Pts,
    q: TG2Pts,
    ppc: TG1Pts,
    neg_q: TG2Pts,
    lines: TLines,
    residue_witness: TFq12,
    residue_witness_inv: TFq12,
    field_nz: NonZero<u256>,
}
