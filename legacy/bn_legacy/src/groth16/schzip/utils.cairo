// Groth16 utils
use bn::curve::residue_witness::{CubicScale};
use bn::groth16::utils::{ICProcess,};
use bn::groth16::utils::{Groth16MillerG1, Groth16MillerG2, PPrecomputeX3};
use core::poseidon::{PoseidonImpl, HashState};

// Fields
use bn::fields::{fq12, Fq12, FS034};
use bn::curve::m::{sqr_nz, mul_nz};

type F034X2 = (FS034, FS034);
type Lines = (FS034, FS034, FS034);
type LinesDbl = (F034X2, F034X2, F034X2);

// Calculate 51 powers of x modulo field
pub fn powers_51(x: u256, field_nz: NonZero<u256>) -> Array<u256> {
    let x2 = sqr_nz(x, field_nz);
    let x3 = mul_nz(x2, x, field_nz);
    let x4 = sqr_nz(x2, field_nz);
    let x5 = mul_nz(x4, x, field_nz);
    let x6 = sqr_nz(x3, field_nz);
    let x7 = mul_nz(x6, x, field_nz);
    let x8 = sqr_nz(x4, field_nz);
    let x9 = mul_nz(x8, x, field_nz);
    let x10 = sqr_nz(x5, field_nz);
    let x11 = mul_nz(x10, x, field_nz);
    let x12 = sqr_nz(x6, field_nz);
    let x13 = mul_nz(x12, x, field_nz);
    let x14 = sqr_nz(x7, field_nz);
    let x15 = mul_nz(x14, x, field_nz);
    let x16 = sqr_nz(x8, field_nz);
    let x17 = mul_nz(x16, x, field_nz);
    let x18 = sqr_nz(x9, field_nz);
    let x19 = mul_nz(x18, x, field_nz);
    let x20 = sqr_nz(x10, field_nz);
    let x21 = mul_nz(x20, x, field_nz);
    let x22 = sqr_nz(x11, field_nz);
    let x23 = mul_nz(x22, x, field_nz);
    let x24 = sqr_nz(x12, field_nz);
    let x25 = mul_nz(x24, x, field_nz);
    let x26 = sqr_nz(x13, field_nz);
    let x27 = mul_nz(x26, x, field_nz);
    let x28 = sqr_nz(x14, field_nz);
    let x29 = mul_nz(x28, x, field_nz);
    let x30 = sqr_nz(x15, field_nz);
    let x31 = mul_nz(x30, x, field_nz);
    let x32 = sqr_nz(x16, field_nz);
    let x33 = mul_nz(x32, x, field_nz);
    let x34 = sqr_nz(x17, field_nz);
    let x35 = mul_nz(x34, x, field_nz);
    let x36 = sqr_nz(x18, field_nz);
    let x37 = mul_nz(x36, x, field_nz);
    let x38 = sqr_nz(x19, field_nz);
    let x39 = mul_nz(x38, x, field_nz);
    let x40 = sqr_nz(x20, field_nz);
    let x41 = mul_nz(x40, x, field_nz);
    let x42 = sqr_nz(x21, field_nz);
    let x43 = mul_nz(x42, x, field_nz);
    let x44 = sqr_nz(x22, field_nz);
    let x45 = mul_nz(x44, x, field_nz);
    let x46 = sqr_nz(x23, field_nz);
    let x47 = mul_nz(x46, x, field_nz);
    let x48 = sqr_nz(x24, field_nz);
    let x49 = mul_nz(x48, x, field_nz);
    let x50 = sqr_nz(x25, field_nz);
    let x51 = mul_nz(x50, x, field_nz);
    array![
        1,
        x,
        x2,
        x3,
        x4,
        x5,
        x6,
        x7,
        x8,
        x9,
        x10,
        x11,
        x12,
        x13,
        x14,
        x15,
        x16,
        x17,
        x18,
        x19,
        x20,
        x21,
        x22,
        x23,
        x24,
        x25,
        x26,
        x27,
        x28,
        x29,
        x30,
        x31,
        x32,
        x33,
        x34,
        x35,
        x36,
        x37,
        x38,
        x39,
        x40,
        x41,
        x42,
        x43,
        x44,
        x45,
        x46,
        x47,
        x48,
        x49,
        x50,
        x51,
    ]
}

#[derive(Copy, Drop)]
pub struct SchZipAccumulator {
    g2: Groth16MillerG2,
    coeff_i: u32,
    rem_hash: HashState,
}

#[derive(Copy, Drop)]
pub struct SchzipPreCompute<TLines, TSchZip> {
    p: Groth16MillerG1,
    q: Groth16MillerG2,
    ppc: PPrecomputeX3,
    neg_q: Groth16MillerG2,
    lines: TLines,
    residue_witness: Fq12,
    residue_witness_inv: Fq12,
    schzip: TSchZip,
    field_nz: NonZero<u256>,
}

// All changes to f: Fq12 are made via the SchZipSteps implementation
pub trait SchZipSteps<T> {
    fn sz_init(self: @T, ref f: Fq12, f_nz: NonZero<u256>);
    fn sz_sqr(self: @T, ref f: Fq12, ref i: u32, f_nz: NonZero<u256>);
    fn sz_zero_bit(self: @T, ref f: Fq12, ref i: u32, lines: Lines, f_nz: NonZero<u256>);
    fn sz_nz_bit(
        self: @T, ref f: Fq12, ref i: u32, lines: LinesDbl, witness: Fq12, f_nz: NonZero<u256>
    );
    fn sz_last_step(self: @T, ref f: Fq12, ref i: u32, lines: LinesDbl, f_nz: NonZero<u256>);
    fn sz_post_miller(
        self: @T,
        f: Fq12,
        ref i: u32,
        alpha_beta: Fq12,
        residue: Fq12,
        residue_inv: Fq12,
        cubic_scale: CubicScale,
        hasher: HashState,
        f_nz: NonZero<u256>
    ) -> bool;
}

pub fn fq12_at_coeffs_index(coefficients: @Array<u256>, i: u32) -> Fq12 {
    fq12(
        *coefficients[i],
        *coefficients[i + 1],
        *coefficients[i + 2],
        *coefficients[i + 3],
        *coefficients[i + 4],
        *coefficients[i + 5],
        *coefficients[i + 6],
        *coefficients[i + 7],
        *coefficients[i + 8],
        *coefficients[i + 9],
        *coefficients[i + 10],
        *coefficients[i + 11],
    )
}
