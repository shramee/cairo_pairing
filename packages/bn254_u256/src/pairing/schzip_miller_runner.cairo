use pairing::{LineFn, LinesArrayGet, FixedPointLines, PiMapping};
use pairing::{PairingUtils};
use bn254_u256::{Fq, Fq2, fq2, Fq12, PtG1, PtG2, Bn254FqOps, Bn254U256Curve as Curve};
use bn254_u256::print::{FqDisplay, Fq12Display, G2Display};
use bn254_u256::pairing::utils::{
    LnArrays, SZCommitment, SZPreCompute, SZAccumulator as Accumulator, LnFn
};
use bn_ate_loop::MillerRunner;
use schwartz_zippel::SchZipSteps;

type PreCompute<TSchZip> = SZPreCompute<LnArrays, TSchZip>;

// TODO: +SchZipSteps<Curve, TCommitment, Fq>

pub impl Miller_Bn254_U256<
    TSchZip, +SchZipSteps<Curve, TSchZip, (u32, Fq), Fq>
> of MillerRunner<Curve, PreCompute<TSchZip>, Accumulator> {
    // first and second step, O and N
    fn miller_bit_1_2(
        ref self: Curve, runner: @PreCompute<TSchZip>, i: (u32, u32), ref acc: Accumulator
    ) { //
        let (i1, i2) = i;
        // runner.schzip
        self.miller_bit_o(runner, i1, ref acc);
        self.miller_bit_n(runner, i2, ref acc);
    }

    // 0 bit
    fn miller_bit_o(
        ref self: Curve, runner: @PreCompute<TSchZip>, i: u32, ref acc: Accumulator
    ) { //
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let l1 = self.step_double(ref acc.g2.pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_line(ref self, g16.ppc, ref acc.line_index);
        self.sz_zero_bit(runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3));
    }

    // 1 bit
    fn miller_bit_p(ref self: Curve, runner: @PreCompute<TSchZip>, i: u32, ref acc: Accumulator) {
        let g16 = runner.g16;
        let ppc = g16.ppc;
        let pi_b = runner.g16.q.pi_b;

        let l1 = self.step_dbl_add(ref acc.g2.pi_b, *pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref acc.line_index);
        self
            .sz_nz_bit(
                runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3), *g16.residue_witness_inv
            );
    }

    // -1 bit
    fn miller_bit_n(
        ref self: Curve, runner: @PreCompute<TSchZip>, i: u32, ref acc: Accumulator
    ) { //
        let g16 = runner.g16;
        let ppc = g16.ppc;
        // use neg q
        let pi_b = runner.g16.neg_q.pi_b;

        let l1 = self.step_dbl_add(ref acc.g2.pi_b, *pi_b, ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref acc.line_index);
        self
            .sz_nz_bit(
                runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3), *g16.residue_witness
            );
    // println!("n_bit {i}: {}", f);

    }

    // last step
    fn miller_last(ref self: Curve, runner: @PreCompute<TSchZip>, ref acc: Accumulator) { //
        let g16 = runner.g16;
        let ppc = g16.ppc;
        // use neg q
        let pi_b = runner.g16.neg_q.pi_b;

        let l1 = self.correction_step(ref acc.g2.pi_b, *pi_b, pi_mapping(), ppc.pi_a);
        let (l2, l3) = g16.lines.with_fxd_pt_lines(ref self, g16.ppc, ref acc.line_index);
        self.sz_last_step(runner.schzip, ref acc.schzip, ref acc.f, (l1, l2, l3));
    }
}

fn pi_mapping() -> PiMapping<Fq> {
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
