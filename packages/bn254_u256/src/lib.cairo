use fq_types::{Fq2 as Fq2Gen, fq2, Fq3 as Fq3Gen, fq3,};
pub mod curve;
pub mod fq_1;

pub use curve::{Bn254U256Curve, PtG1, PtG2, AffineOpsBn};
pub use fq_1::{
    {scale_9, Fq, FieldOps, FieldOpsExtended, FieldUtils}, {U256IntoFq, Bn254FqOps, Bn254FqUtils}
};
pub use fq_types::CubicScale;

pub type Fq2 = Fq2Gen<Fq>;
pub type Fq6 = Fq3Gen<Fq2Gen<Fq>>;
pub type Fq12 = Fq2Gen<Fq6>;

pub mod pairing {
    pub mod utils;
    pub mod schzip_miller_runner;
    pub mod schzip_miller;
}

pub use pairing::{
    utils::{ICProcess, ICArrayInput, LnArrays, //
     {SZCommitment, SZPreCompute, SZAccumulator}},
    schzip_miller::{
        schzip_verify, InputConstraintPoints, PPrecompute,
        {Groth16MillerG1, Groth16MillerG2, Groth16PreCompute, Groth16Circuit}
    },
};

pub fn bn254_curve() -> Bn254U256Curve {
    Bn254U256Curve {
        q: 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47,
        qnz: 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47,
    }
}