use bn254_u256::{Fq, U256IntoFq, Fq2, FqD12, fq2, fq3, Bn254FqOps, Bn254FqUtils};
use fq_types::{FrobeniusFq12Maps, FrobeniusFq6Maps};
use ec_groups::{Affine, ECGroupUtils};
pub use ec_groups::AffineOpsBn;
pub use pairing::{CubicScale, PiMapping};

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

pub fn pi_mapping() -> PiMapping<Fq> {
    // π (Pi) - Untwist-Frobenius-Twist Endomorphisms on twisted curves
    // -----------------------------------------------------------------
    // BN254_Snarks is a D-Twist: pi1_coef1 = ξ^((p-1)/6)
    // https://github.com/mratsim/constantine/blob/976c8bb215a3f0b21ce3d05f894eb506072a6285/constantine/math/constants/bn254_snarks_frobenius.nim#L131
    // In the link above this is referred to as ψ (Psi)

    // pi2_coef3 is always -1 (mod p^m) with m = embdeg/twdeg
    // Recap, with ξ (xi) the sextic non-residue for D-Twist or 1/SNR for M-Twist
    // pi_2 ≡ ξ^((p-1)/6)^2 ≡ ξ^(2(p-1)/6) ≡ ξ^((p-1)/3)
    // pi_3 ≡ pi_2 * ξ^((p-1)/6) ≡ ξ^((p-1)/3) * ξ^((p-1)/6) ≡ ξ^((p-1)/2)

    // -----------------------------------------------------------------
    // for πₚ mapping

    // Fp2::NONRESIDUE^(2((q^1) - 1) / 6)
    let Q1X2_0 = 0x2fb347984f7911f74c0bec3cf559b143b78cc310c2c3330c99e39557176f553d;
    let Q1X2_1 = 0x16c9e55061ebae204ba4cc8bd75a079432ae2a1d0b7c9dce1665d51c640fcba2;

    // Fp2::NONRESIDUE^(3((q^1) - 1) / 6)
    let Q1X3_0 = 0x63cf305489af5dcdc5ec698b6e2f9b9dbaae0eda9c95998dc54014671a0135a;
    let Q1X3_1 = 0x7c03cbcac41049a0704b5a7ec796f2b21807dc98fa25bd282d37f632623b0e3;

    // -----------------------------------------------------------------
    // for π² mapping

    // Fp2::NONRESIDUE^(2(p^2-1)/6)
    let PiQ2X2: Fq = 0x30644e72e131a0295e6dd9e7e0acccb0c28f069fbb966e3de4bd44e5607cfd48_u256.into();
    // Fp2::NONRESIDUE^(3(p^2-1)/6)
    let PiQ2X3: Fq = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd46_u256.into();

    PiMapping {
        PiQ1X2: fq2(Q1X2_0, Q1X2_1,), // Fp2::NONRESIDUE^(2((q^1) - 1) / 6)
        PiQ1X3: fq2(Q1X3_0, Q1X3_1,), // Fp2::NONRESIDUE^(3((q^1) - 1) / 6)
        // for π² mapping
        PiQ2X2, // Fp2::NONRESIDUE^(2(p^2-1)/6)
        PiQ2X3, // Fp2::NONRESIDUE^(3(p^2-1)/6)
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

pub fn fq12_frobenius_map() -> FrobeniusFq12Maps<Fq> {
    FrobeniusFq12Maps {
        frob1_c1: fq2(
            8376118865763821496583973867626364092589906065868298776909617916018768340080,
            16469823323077808223889137241176536799009286646108169935659301613961712198316
        ),
        frob2_c1: fq2(
            21888242871839275220042445260109153167277707414472061641714758635765020556617, 0
        ),
        frob3_c1: fq2(
            11697423496358154304825782922584725312912383441159505038794027105778954184319,
            303847389135065887422783454877609941456349188919719272345083954437860409601
        ),
        fq6: FrobeniusFq6Maps {
            frob1_c1: fq2(
                21575463638280843010398324269430826099269044274347216827212613867836435027261,
                10307601595873709700152284273816112264069230130616436755625194854815875713954
            ),
            frob1_c2: fq2(
                2581911344467009335267311115468803099551665605076196740867805258568234346338,
                19937756971775647987995932169929341994314640652964949448313374472400716661030
            ),
            frob2_c1: fq2(
                21888242871839275220042445260109153167277707414472061641714758635765020556616, 0
            ),
            frob2_c2: fq2(2203960485148121921418603742825762020974279258880205651966, 0),
            frob3_c1: fq2(
                3772000881919853776433695186713858239009073593817195771773381919316419345261,
                2236595495967245188281701248203181795121068902605861227855261137820944008926
            ),
            frob3_c2: fq2(
                5324479202449903542726783395506214481928257762400643279780343368557297135718,
                16208900380737693084919495127334387981393726419856888799917914180988844123039
            ),
        }
    }
}

pub fn bn254_curve() -> Bn254U256Curve {
    Bn254U256Curve {
        q: 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47,
        qnz: 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47,
    }
}
