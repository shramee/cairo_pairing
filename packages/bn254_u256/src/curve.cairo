use bn254_u256::{Fq, U256IntoFq, Fq2, FqD12, fq2, fq3, Bn254FqOps, Bn254FqUtils};
use ec_groups::{Affine, ECGroupUtils};
pub use ec_groups::AffineOpsBn;
pub use pairing::CubicScale;

#[derive(Drop, Serde)]
pub struct Bn254U256Curve {
    pub q: u256,
    pub qnz: NonZero<u256>,
}

pub type PtG1 = Affine<Fq>;
pub type PtG2 = Affine<Fq2>;

impl PtG1One of ECGroupUtils<Bn254U256Curve, Fq> {
    fn pt_one(ref self: Bn254U256Curve) -> PtG1 {
        Affine { x: 1_u256.into(), y: 2_u256.into() }
    }
}

impl PtG2One of ECGroupUtils<Bn254U256Curve, Fq2> {
    fn pt_one(ref self: Bn254U256Curve) -> PtG2 {
        Affine {
            x: fq2(
                10857046999023057135944570762232829481370756359578518086990519993285655852781,
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
            ),
            y: fq2(
                8495653923123431417604973247489272438418190587263600148770280649306958101930,
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
            )
        }
    }
}

pub const FQ_0: Fq = Fq { c0: 0x0 };
pub const ROOT_27TH: FqD12 =
    (
        (FQ_0, FQ_0, FQ_0, FQ_0),
        (
            Fq { c0: 0x778f7e113269a67bd294b9c757d6f7aa4c634773692b9376d090b20e5ccfca },
            FQ_0,
            FQ_0,
            FQ_0
        ),
        (
            FQ_0,
            FQ_0,
            Fq { c0: 0x279a0a9dbd98089c184dac0e71909eb223ea52bfc24790f6d545aed52a2fbdb8 },
            FQ_0
        ),
    );


pub const ROOT_27TH_SQ: FqD12 =
    (
        (
            FQ_0,
            FQ_0,
            Fq { c0: 0x2d47bdc1ad79a2d8f25dc130d86b34cb0fbe750ec2778d80388a54eae80e565b },
            FQ_0
        ),
        (FQ_0, FQ_0, FQ_0, FQ_0),
        (
            Fq { c0: 0x10bd041a04b5422922463bd8b6519b59af036109a228aa43fdb7f215226ece12 },
            FQ_0,
            FQ_0,
            FQ_0
        ),
    );
