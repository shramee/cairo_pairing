use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;
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
    let rhs = ate_miller_loop(C_G1, AffineG2Impl::one());
    let nlhs = ate_miller_loop(neg_A_G1, B_G2);
    let pairing_product = (nlhs * rhs).final_exponentiation();
    assert(pairing_product == Fq12Utils::one(), 'lhs == rhs failed')
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
        0x1ac9750557221e57d8080e19cea275f681ff9f0c82e3e0c1494ba189c6d75ae5,
        0x2100844da9e24497f9d2ee16198f72711cf0feacf476c89caa4f12d6fee34421,
        0xd492bbe181d8e680996d36e481f2d9df9eed2c6900e2a5c17cdac778193761d,
        0x3a0882da04bba7a719c8032da500dc898a60363c2973310d15982efb400898c,
        0x248dde6270e066921eb8b68c10a9b7cec6c6578448ca84545f3cb401a20ce0b1,
        0x2e430a046c424c8096a48dfde0872d5eb21ce9195b5e5ec6f28f1cfae9c7d29d
    );
    (alpha, beta, gamma, delta, alphabeta_miller, ic)
}

fn proof() -> (AffineG1, AffineG2, AffineG1, u256) {
    let pi_a = g1(
        17569215349064499786665425572828383582759793266096859215024076014378993573542,
        14093361030964136607872935128606569476246367738810367780209973536364989420761,
    );
    let pi_b = g2(
        8906856236765577381907633973567321192541961974679857493894268848505999969718,
        12774627830442427246581584430481606296461775079839216044138283833122845195772,
        21432960101030034205832457816606491451947108454800368402484035699051428429767,
        9055973550915127493199259454760636015878416319195629250994300683841991741689,
    );
    let pi_c = g1(
        1405278045432909907575012750297125550437218281131079569379909617249902982424,
        14173631960723149344863508297580373682266031421199928978393750128575672066420,
    );
    let pub_input = 16941831391195391826097405368824996545623792600381113317588874714920518273658;
    (pi_a, pi_b, pi_c, pub_input,)
}

#[test]
#[available_gas(20000000000)]
fn test_alphabeta_miller() {
    let (alpha, beta, _, _, alphabeta_miller, _) = vk();
    assert(alphabeta_miller == ate_miller_loop(alpha, beta), 'incorrect miller precompute');
}
