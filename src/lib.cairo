mod i257;

mod fast_mod;
#[cfg(test)]
mod fast_mod_tests;

mod traits;

mod fields;

mod g1;
#[cfg(test)]
mod g1_tests;
mod g2;

mod pairing;
#[cfg(test)]
mod pairing_tests;

// These paramas from:
// https://hackmd.io/@jpw/bn254
const ORDER: u256 = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
const FIELD: u256 = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
const B: u256 = 3;

fn fq_non_residue() -> fields::Fq {
    fields::fq(21888242871839275222246405745257275088696311157297823662689037894645226208582)
}

fn fq2_non_residue() -> fields::Fq2 {
    fields::fq2(9, 1)
}

const ATE_LOOP_COUNT: u128 = 29793968203157093288;
const LOG_ATE_LOOP_COUNT: u128 = 63;
