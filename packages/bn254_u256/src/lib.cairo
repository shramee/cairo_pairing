pub mod curve;
pub mod fq_1;
pub mod utils;
pub mod print;
pub mod pairing {
    pub mod utils;
    pub mod schzip {
        pub mod miller_runner;
        pub mod miller;
        pub mod steps;
    }
}

pub mod fixtures {
    pub mod lines_fix;
    pub mod proof_fix;
    pub mod schzip_fix;
    pub use proof_fix::{circuit_setup, residue_witness, proof};
    pub use schzip_fix::{schzip};
}

#[cfg(test)]
mod tests {
    pub mod curve;
    pub mod tests;
    pub mod test_pairing_utils;
    pub use super::fixtures;
}

use fq_types::{
    Fq2 as Fq2Gen, Fq3, F12S034, Fq12Direct, Fq4Direct, fq3, Fq2PartialEq, Fq3PartialEq,
};
pub use curve::{Bn254U256Curve, PtG1, PtG2, AffineOpsBn, CubicScale, PiMapping};
pub use curve::{bn254_curve, pi_mapping};

// Frobenius maps
pub use curve::fq12_frobenius_map;
pub use fq_types::frobenius_bn254::{FrobFq12, FrobFq6};

pub use fq_1::{
    {U256IntoFq, FqPartialEq, Bn254FqOps, Bn254FqUtils},
    {scale_9, Fq, FieldOps, FieldOpsExtended, FieldUtils},
};
pub use utils::{
    g1, g2, fqd12, fq12, fq2, fq, tower_to_direct_fq12, direct_to_tower_fq12, direct_f034
};

pub type Fq2 = Fq2Gen<Fq>;
pub type Fq6 = Fq3<Fq2>;
pub type Fq12 = Fq2Gen<Fq6>;
pub type FqD12 = Fq12Direct<Fq>;
pub type FqD4 = Fq4Direct<Fq>;
pub type F034 = F12S034<Fq2>;

pub use pairing::{
    utils::{
        {ICProcess, ICArrayInput, LnArrays},
        {SZCommitment, SZMillerRunner, SZAccumulator, SZCommitmentAccumulator}
    },
    schzip::miller::{
        schzip_verify, InputConstraintPoints, PPrecompute,
        {Groth16MillerG1, Groth16MillerG2, Groth16PreCompute, Groth16Circuit}
    },
    schzip::steps::Bn254SchwartzZippelSteps, schzip::miller_runner::Miller_Bn254_U256
};
