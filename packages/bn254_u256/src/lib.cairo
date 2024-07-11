use fq_types::{Fq2 as Fq2Gen, fq2, Fq3 as Fq3Gen, fq3,};
pub mod curve;
pub mod fq_1;

pub use curve::{Bn254U256Curve, PtG1, PtG2, AffineOpsBn};
pub use fq_1::{scale_9, Fq, FieldOps, FieldOpsExtended, FieldUtils};
pub use fq_1::{U256IntoFq, Bn254FqOps, Bn254FqUtils};

pub type Fq2 = Fq2Gen<Fq>;
pub type Fq6 = Fq3Gen<Fq2Gen<Fq>>;
pub type Fq12 = Fq2Gen<Fq6>;

pub mod pairing {
    pub mod utils;
    pub mod schzip_miller_runner;
    pub mod schzip_miller;
}

pub use pairing::utils::{ICProcess, ICArrayInput, CubicScale};
pub use pairing::utils::{SZCommitment, SZPreCompute, SZAccumulator};
pub use pairing::utils::{p_precompute};
