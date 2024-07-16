pub mod curve;
pub mod fq_1;
pub mod utils;
pub mod print;
pub mod pairing {
    pub mod utils;
    pub mod schzip_miller_runner;
    pub mod schzip_miller;
    pub mod schzip_steps;
}

#[cfg(test)]
mod tests {
    pub mod tests;
    pub mod test_pairing_utils;
    pub mod fixtures;
}

use fq_types::{Fq2 as Fq2Gen, Fq3 as Fq3Gen, F12S034, fq3, Fq2PartialEq, Fq3PartialEq,};
pub use curve::{Bn254U256Curve, PtG1, PtG2, AffineOpsBn, CubicScale};
pub use fq_1::{
    {U256IntoFq, FqPartialEq, Bn254FqOps, Bn254FqUtils},
    {scale_9, Fq, FieldOps, FieldOpsExtended, FieldUtils},
};
pub use utils::{g1, g2, fq12, fq2};

pub type Fq2 = Fq2Gen<Fq>;
pub type Fq6 = Fq3Gen<Fq2>;
pub type Fq12 = Fq2Gen<Fq6>;
pub type F034 = F12S034<Fq2>;

pub use pairing::{
    utils::{ICProcess, ICArrayInput, LnArrays, //
     {SZCommitment, SZPreCompute, SZAccumulator}},
    schzip_miller::{
        schzip_verify, InputConstraintPoints, PPrecompute,
        {Groth16MillerG1, Groth16MillerG2, Groth16PreCompute, Groth16Circuit}
    },
    schzip_steps::Bn254SchwartzZippelSteps,
};

pub fn bn254_curve() -> Bn254U256Curve {
    Bn254U256Curve {
        q: 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47,
        qnz: 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47,
    }
}
