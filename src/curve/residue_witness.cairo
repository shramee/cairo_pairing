use bn::traits::{FieldUtils, FieldOps, FieldShortcuts};
use bn::curve::{mul_by_xi_nz};
use bn::fields::{Fq, Fq12, Fq6, Fq2};
use bn::fields::fq_12_direct::{Fq12Direct};
use bn::fields::fq_12_direct::{
    tower_to_direct, tower01234_to_direct, tower034_to_direct, direct_to_tower,
};
use bn::fields::{FS034, FS01234, FS01, fq_sparse::FqSparseTrait};

#[derive(Copy, Drop, Serde)]
enum CubicScale {
    Zero,
    One,
    Two,
}

impl ResidueWitnessIntoFq6 of Into<CubicScale, Fq6> {
    fn into(self: CubicScale) -> Fq6 {
        match self {
            CubicScale::Zero => FieldUtils::one(),
            CubicScale::One => ROOT_27TH,
            CubicScale::Two => ROOT_27TH_SQ,
        }
    }
}

impl ResidueWitnessIntoFq12Direct of Into<CubicScale, Fq12Direct> {
    fn into(self: CubicScale) -> Fq12Direct {
        match self {
            CubicScale::Zero => (
                FieldUtils::one(), FQ_0, FQ_0, FQ_0, FQ_0, FQ_0, FQ_0, FQ_0, FQ_0, FQ_0, FQ_0, FQ_0,
            ),
            CubicScale::One => ROOT_27TH_DIRECT,
            CubicScale::Two => ROOT_27TH_SQ_DIRECT,
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

fn mul_by_sparse_fq6_2(a: Fq6, b2: Fq2, field_nz: NonZero<u256>) -> Fq6 {
    // A reimplementation in Karatsuba multiplication with lazy reduction
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // uppercase vars are u512, lower case are u256
    core::internal::revoke_ap_tracking();

    // Input:a = (a0 + a1v + a2v2) and b = (b0 + b1v + b2v2) ∈ Fp6
    // Output:c = a · b = (c0 + c1v + c2v2) ∈ Fp6
    let Fq6 { c0: a0, c1: a1, c2: a2 } = a;

    // v0 = a0b0, v1 = a1b1, v2 = a2b2
    // only v2 is non-zero, added within the calculations

    // c0 = v0 + ξ((a1 + a2)(b1 + b2) - v1 - v2)
    let c0 = a1.mul(b2).mul_by_nonresidue();
    // c1 =(a0 + a1)(b0 + b1) - v0 - v1 + ξv2
    let c1 = a2.mul(b2).mul_by_nonresidue();
    // c2 = (a0 + a2)(b0 + b2) - v0 + v1 - v2,
    let c2 = a0.mul(b2);

    Fq6 { c0, c1, c2 }
}

fn mul_by_sparse_fq6_1(a: Fq6, b1: Fq2, field_nz: NonZero<u256>) -> Fq6 {
    // A reimplementation in Karatsuba multiplication with lazy reduction
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // uppercase vars are u512, lower case are u256
    core::internal::revoke_ap_tracking();

    // Input:a = (a0 + a1v + a2v2) and b = (b0 + b1v + b2v2) ∈ Fp6
    // Output:c = a · b = (c0 + c1v + c2v2) ∈ Fp6
    let Fq6 { c0: a0, c1: a1, c2: a2 } = a;

    // v0 = a0b0, v1 = a1b1, v2 = a2b2
    // only v1 is non-zero, added within the calculations

    // c0 = v0 + ξ((a1 + a2)(b1 + b2) - v1 - v2)
    let c0 = a2.mul(b1).mul_by_nonresidue();
    // c1 =(a0 + a1)(b0 + b1) - v0 - v1 + ξv2
    let c1 = a0.mul(b1);
    // c2 = (a0 + a2)(b0 + b2) - v0 + v1 - v2,
    let c2 = a1.mul(b1);

    Fq6 { c0, c1, c2 }
}

#[cfg(test)]
mod tests {
    use super::{mul_by_sparse_fq6_1, mul_by_sparse_fq6_2, ROOT_27TH, ROOT_27TH_SQ};
    use bn::fields::{fq6, Fq6, Fq2, FieldOps};
    fn a6() -> Fq6 {
        fq6(
            0x1223c9e5932f55ff4c5bb93e3ae400abc8ff620b6cd0ba64515fe1909e9f8e51,
            0x279a0a9dbd98089c184dac0e71909eb223ea52bfc24790f6d545aed52a2fbdb8,
            0x2bac0e719092bfc24790f6d545aed223ea5279a0a9dbd98089c184d52a2fbdb8,
            0x25ba8e0531275a44594c4f53b44497bd8d7341fd41e5faf337fa74dbbff9fe1,
            0x7b4f53b44491fd41e5faf337fa74dd8d73425ba8e0531275a44594cbbff9fe1,
            0x10bd041a04b5422922463bd8b6519b59af036109a228aa43fdb7f215226ece12,
        )
    }

    #[test]
    fn mul_fq6_1() {
        let f_nz = bn::curve::get_field_nz();
        let a = a6();
        let t = ROOT_27TH_SQ;
        let _res = mul_by_sparse_fq6_1(a, t.c1, f_nz);
        assert(a.mul(t) == _res, 'incorrect mul_fq6_1');
    }

    #[test]
    fn mul_fq6_2() {
        let f_nz = bn::curve::get_field_nz();
        let a = a6();
        let t = ROOT_27TH;
        let _res = mul_by_sparse_fq6_2(a, t.c2, f_nz);
        assert(a.mul(t) == _res, 'incorrect mul_fq6_2');
    }

    #[test]
    fn mul_fq6() {
        let _res = a6().mul(ROOT_27TH);
        assert(_res == _res, 'just benchmarking');
    }
}

fn mul_by_root_27th(f: Fq12, field_nz: NonZero<u256>) -> Fq12 {
    // A reimplementation in Karatsuba multiplication with lazy reduction
    // Faster Explicit Formulas for Computing Pairings over Ordinary Curves
    // uppercase vars are u512, lower case are u256
    core::internal::revoke_ap_tracking();

    let Fq12 { c0, c1, } = f;

    Fq12 {
        c0: mul_by_sparse_fq6_2(c0, ROOT_27TH.c2, field_nz),
        c1: mul_by_sparse_fq6_2(c1, ROOT_27TH.c2, field_nz),
    }
}

fn mul_by_root_27th_sq(f: Fq12, field_nz: NonZero<u256>) -> Fq12 {
    let Fq12 { c0, c1, } = f;

    Fq12 {
        c0: mul_by_sparse_fq6_1(c0, ROOT_27TH_SQ.c1, field_nz),
        c1: mul_by_sparse_fq6_1(c1, ROOT_27TH_SQ.c1, field_nz),
    }
}
