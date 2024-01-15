mod i257;

mod fast_mod;
#[cfg(test)]
mod fast_mod_tests;

mod traits;

mod g1;
mod g2;
mod pairing;
mod pt;
#[cfg(test)]
mod curve_tests;

const FIELD: u256 = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
const B: u256 = 3;

const ATE_LOOP_COUNT: u128 = 29793968203157093288;
const LOG_ATE_LOOP_COUNT: u128 = 63;
