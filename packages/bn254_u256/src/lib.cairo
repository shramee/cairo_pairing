use fq_types::{Fq2 as Fq2Gen, fq2, Fq3 as Fq3Gen, fq3,};
pub mod fq_1;
pub use fq_1::{scale_9, Fq, FieldOps, FieldOpsExtended, FieldUtils};
pub use fq_1::{U256IntoFq, Bn254FqOps, Bn254FqUtils};

pub type Fq2 = Fq2Gen<Fq>;
pub type Fq6 = Fq3Gen<Fq2Gen<Fq>>;
pub type Fq12 = Fq2Gen<Fq6>;

