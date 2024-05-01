// test bn::groth16::tests::groth16_verify ... ok (gas usage est.: 1802616140)
// test bn::groth16::tests::test_alphabeta_miller ... ok (gas usage est.: 404856360)

use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
use bn::traits::FieldOps;
use bn::curve::groups::ECOperations;
use bn::g::{Affine, AffineG1Impl, AffineG2Impl, g1, g2, AffineG1, AffineG2,};
use bn::fields::{Fq, Fq2, print::{FqDisplay, Fq12Display}};
use bn::fields::{fq12, Fq12, Fq12Utils, Fq12Exponentiation};
use bn::curve::pairing;
use pairing::optimal_ate::{single_ate_pairing, ate_miller_loop};
use pairing::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
use pairing::optimal_ate_utils::LineFn;
use bn::groth16::utils::{process_input_constraints, FixedG2Precompute};
use bn::groth16::verifier::{verify};
use bn::groth16::setup::{setup_precompute, G16CircuitSetup};
use core::fmt::{Display, Formatter, Error};

impl AffineG2Display of Display<AffineG2> {
    fn fmt(self: @AffineG2, ref f: Formatter) -> Result<(), Error> {
        write!(f, "\ng2({},{},{},{})", *self.x.c0, *self.x.c1, *self.y.c0, *self.y.c1)
    }
}

impl LineFnArrDisplay of Display<Array<LineFn>> {
    fn fmt(self: @Array<LineFn>, ref f: core::fmt::Formatter) -> Result<(), Error> {
        let mut i = 0;
        loop {
            let res = write!(
                f,
                "\nline_fn_from_u256({},{},{},{}),",
                *self.at(i).slope.c0,
                *self.at(i).slope.c1,
                *self.at(i).c.c0,
                *self.at(i).c.c1
            );
            i = i + 1;
            if i == self.len() {
                break res;
            }
        }
    }
}


fn vk() -> (AffineG1, AffineG2, AffineG2, AffineG2, Fq12, (AffineG1, AffineG1)) {
    let mut alpha = g1(
        20491192805390485299153009773594534940189261866228447918068658471970481763042,
        9383485363053290200918347156157836566562967994039712273449902621266178545958
    );
    let beta = g2(
        6375614351688725206403948262868962793625744043794305715222011528459656738731,
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        10505242626370262277552901082094356697409835680220590971873171140371331206856,
        21847035105528745403288232691147584728191162732299865338377159692350059136679
    );
    let gamma = g2(
        10857046999023057135944570762232829481370756359578518086990519993285655852781,
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        8495653923123431417604973247489272438418190587263600148770280649306958101930,
        4082367875863433681332203403145435568316851327593401208105741076214120093531
    );
    let delta = g2(
        18843522656454103229460441939617973919282852773928454389351548381771109175804,
        20939788735433971235553050176856161353732417040828392785429509147312127378598,
        20154620275540267962893477662314018482859018034691595131178696575286779357689,
        4547106032091524596969837323375385497187441697194445474662172759730343393129
    );
    let ic = (
        g1(
            1655549413518972190198478012616802994254462093161203201613599472264958303841,
            21742734017792296281216385119397138748114275727065024271646515586404591497876
        ),
        g1(
            16497930821522159474595176304955625435616718625609462506360632944366974274906,
            10404924572941018678793755094259635830045501866471999610240845041996101882275
        )
    );
    let alphabeta_miller = fq12(
        0x27c20318505e03cea84a04223b8679a6c84c1e55e83957a21e8986c1b8140510,
        0x104bb1b78f934618c94ba0290a964c58f1400e450e9e19680c39a8aca6fa15f4,
        0x2e56f81476f8d79f0caef927ac110b77cec88490d0860c746d82583440bb8919,
        0x1a814cb6d1fa262a5882e06c097fd68c05fdd1f27e2288f84726985dea9706e,
        0x19bdc2cd81965796abc4dd1ac13a5941ce94ead67c26445a67ca63f07def54fa,
        0xe328b63e1f95c3e6208878e9ca68fa49960e71588c6302c244b428b2cf5aa6,
        0x159ad96d8a0f81d1e048379cb2dee2671581cb84e58de9cbf2d4ea8d11a5a262,
        0xf63ca25374f5b91be7d57a067f1e5ec7a906be473fb01f091d1793fd999b926,
        0x231b22b4c91411c1aeb9724839622abf9d9297cad863a0312452df9f56e9872a,
        0x2cc3c64540e5e5af46b3c583a7314a94fedb672da5da977c6ac70927247c73bb,
        0xbd670107051399799978f2a70d7a08ed0bb130d1fa74638dce3d81536701c96,
        0x221446e74ef53a921abb7b8a0fa2afee56481780d136bc649916f1beeb52aaa
    );
    (alpha, beta, gamma, delta, alphabeta_miller, ic)
}

fn proof() -> (AffineG1, AffineG2, AffineG1, u256) {
    let pi_a = g1(
        21869318927288279352976009554602485400194222893443965440964860860113038611333,
        18311135712289946861315992474690361768373551919702286485795766144098633284656,
    );
    let pi_b = g2(
        10022883437199133497429724894217743345007175536382603527810937928471784278544,
        17847188618426698749899308504244999133998140738319907268599259829537979435105,
        7206719342459067270750328127893044383768922785737900891173474267747233610797,
        10190861912483383555079439540237798028694495449372197543107740729805978332256,
    );
    let pi_c = g1(
        9705330802798333149196349399272648034569447771243096213977283095662805051802,
        5611531129077709352565605843416215629032027923761887684873913606256162034924,
    );
    let pub_input = 16941831391195391826097405368824996545623792600381113317588874714920518273658;
    (pi_a, pi_b, pi_c, pub_input,)
}

// @TODO
// Fix Groth16 verify function for negative G2 and not neg pi_a
// #[test]
// #[available_gas(20000000000)]
// fn groth16_verify() {
//     // Verification key parameters
//     let (_, _, gamma, delta, albe_miller, (ic0, ic1)) = vk();

//     // Proof parameters
//     let (pi_a, pi_b, pi_c, pub_input,) = proof();

//     let verified = verify(pi_a, pi_b, pi_c, ic0, (ic1, pub_input), albe_miller, delta, gamma,);

//     assert(verified, 'verification failed');
// }

#[test]
#[available_gas(20000000000)]
fn test_alphabeta_precompute() {
    let (alpha, beta, _, _, alphabeta, _) = vk();
    let computed_alpha_beta = ate_miller_loop(alpha, beta.neg());
    assert(alphabeta == computed_alpha_beta, 'incorrect miller precompute');
}

fn print_g2_precompute(precom: FixedG2Precompute) {
    println!("\nFixedG2Precompute {{");
    println!("\npoint: {},", precom.point);
    println!("\nneg: {},", precom.neg);
    println!("\nlines: array![{}]", precom.lines);
    println!("}}");
}

#[test]
#[available_gas(20000000000)]
fn test_setup() {
    let (alpha, beta, gamma, delta, alphabeta, _) = vk();
    let G16CircuitSetup { alpha_beta, gamma, delta } = setup_precompute(alpha, beta, gamma, delta);

    // // Print FixedG2Precompute for mocks
    // ---------------------------------

    // println!("\nfn gamma_precompute() -> FixedG2Precompute {{");
    // print_g2_precompute(gamma);
    // println!("\n}}");

    // println!("\nfn delta_precompute() -> FixedG2Precompute {{");
    // print_g2_precompute(delta);
    // println!("\n}}");

    assert(alpha_beta == alphabeta, 'incorrect miller precompute');
}
