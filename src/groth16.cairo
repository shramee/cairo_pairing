use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::Fq12Display};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
#[test]
#[available_gas(20000000000)]
fn simple_test() {
    let A_G1 = g1(
        19092006581455788758709004813424108450475230671546198110182704126760952021248,
        18428185916649502171614192229986655674799279684527591370328182794110727996633
    );
    let neg_A_G1 = g1(A_G1.x.c0, A_G1.y.neg().c0);
    let B_G2 = g2(
        1110332524507442648511549408896049077062269578877062826069065960274388112308,
        15815785354885964222010325771656100864105333417560377595802485750386873282739,
        20784382045877636010618629654573620888044404319093695781168988411617616204166,
        5234804291052944426941184034424257962428641145809086397589880058685491457835
    );
    let C_G1 = g1(
        21755526246297599392782387322262927251662305599666002632514868138515690603377,
        19883332083442129478217826420060112230198011363938980948134718366700920887106
    );
    let lhs = single_ate_pairing(A_G1, B_G2);
    let rhs = single_ate_pairing(C_G1, AffineG2Impl::one());
    let nlhs = single_ate_pairing(neg_A_G1, B_G2);
    assert(nlhs * rhs == fq12(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 'lhs == rhs failed')
}
