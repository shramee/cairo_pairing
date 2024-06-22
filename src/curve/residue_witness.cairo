use bn::traits::FieldUtils;
use bn::fields::{Fq, Fq12, Fq6, Fq2};
use bn::fields::fq_12_direct::{Fq12Direct};
use bn::fields::fq_12_direct::{
    tower_to_direct, tower01234_to_direct, tower034_to_direct, direct_to_tower,
};
use bn::fields::{FS034, FS01234, FS01, fq_sparse::FqSparseTrait};

#[derive(Copy, Drop, Serde)]
enum ResidueWitness {
    Zero,
    One,
    Two,
}

impl ResidueWitnessIntoFq12 of Into<ResidueWitness, Fq12> {
    fn into(self: ResidueWitness) -> Fq12 {
        match self {
            ResidueWitness::Zero => FieldUtils::one(),
            ResidueWitness::One => ROOT_27TH,
            ResidueWitness::Two => ROOT_27TH_SQ,
        }
    }
}

impl ResidueWitnessIntoFq12Direct of Into<ResidueWitness, Fq12Direct> {
    fn into(self: ResidueWitness) -> Fq12Direct {
        match self {
            ResidueWitness::Zero => FieldUtils::one(),
            ResidueWitness::One => ROOT_27TH_DIRECT,
            ResidueWitness::Two => ROOT_27TH_SQ_DIRECT,
        }
    }
}

pub const FQ_0: Fq = Fq { c0: 0x0 };
pub const FQ2_0: Fq2 = Fq2 { c0: FQ_0, c1: FQ_0, };

pub const ROOT_27TH_DIRECT: Fq12Direct =
    (
        FQ_0,
        FQ_0,
        FQ_0,
        FQ_0,
        Fq { c0: 0x778f7e113269a67bd294b9c757d6f7aa4c634773692b9376d090b20e5ccfca },
        FQ_0,
        FQ_0,
        FQ_0,
        FQ_0,
        FQ_0,
        Fq { c0: 0x279a0a9dbd98089c184dac0e71909eb223ea52bfc24790f6d545aed52a2fbdb8 },
        FQ_0,
    );


pub const ROOT_27TH_SQ_DIRECT: Fq12Direct =
    (
        FQ_0,
        FQ_0,
        Fq { c0: 0x2d47bdc1ad79a2d8f25dc130d86b34cb0fbe750ec2778d80388a54eae80e565b },
        FQ_0,
        FQ_0,
        FQ_0,
        FQ_0,
        FQ_0,
        Fq { c0: 0x10bd041a04b5422922463bd8b6519b59af036109a228aa43fdb7f215226ece12 },
        FQ_0,
        FQ_0,
        FQ_0,
    );


pub const ROOT_27TH: Fq6 =
    Fq6 {
        c0: FQ2_0,
        c1: FQ2_0,
        c2: Fq2 {
            c0: Fq { c0: 0x1223c9e5932f55ff4c5bb93e3ae400abc8ff620b6cd0ba64515fe1909e9f8e51 },
            c1: Fq { c0: 0x279a0a9dbd98089c184dac0e71909eb223ea52bfc24790f6d545aed52a2fbdb8 },
        },
    };

pub const ROOT_27TH_SQ: Fq6 =
    Fq6 {
        c0: FQ2_0,
        c1: Fq2 {
            c0: Fq { c0: 0x25ba8e0531275a44594c4f53b44497bd8d7341fd41e5faf337fa74dbbff9fe1 },
            c1: Fq { c0: 0x10bd041a04b5422922463bd8b6519b59af036109a228aa43fdb7f215226ece12 },
        },
        c2: FQ2_0,
    };

fn mul_by_root_27th(f: Fq12) -> Fq12 {
    f.scale(ROOT_27TH)
}

fn mul_by_root_27th_sq(f: Fq12) -> Fq12 {
    f.scale(ROOT_27TH_SQ)
}
