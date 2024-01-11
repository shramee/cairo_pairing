use cairo_ec::bn::g1::{AffineG1, one as g1_one, g1_pt};
use cairo_ec::bn::g2::{AffineG2, one as g2_one, g2_pt};
use cairo_ec::traits::ECOperations;

const FIELD: u256 = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
const B: u256 = 3;
