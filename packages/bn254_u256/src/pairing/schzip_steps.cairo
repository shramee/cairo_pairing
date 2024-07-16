use bn254_u256::{Fq, Fq2, Fq12, Bn254U256Curve, SZCommitment};
use schwartz_zippel::{SchZipSteps, Lines, FS034, F034X2, LinesDbl, Residue};

type Curve = Bn254U256Curve;
type SZAcc = (u32, Fq);

pub impl Bn254SchwartzZippelSteps of SchZipSteps<Curve, SZCommitment, SZAcc, Fq> {
    fn sz_init(ref self: Curve, sz: @SZCommitment, ref sz_acc: SZAcc, ref f: Fq12) {}
    fn sz_sqr(ref self: Curve, sz: @SZCommitment, ref sz_acc: SZAcc, ref f: Fq12) {}
    fn sz_zero_bit(
        ref self: Curve, sz: @SZCommitment, ref sz_acc: SZAcc, ref f: Fq12, lines: Lines<Fq2>
    ) {
        let (_l1, _l2, _l3) = lines;
    }
    fn sz_nz_bit(
        ref self: Curve,
        sz: @SZCommitment,
        ref sz_acc: SZAcc,
        ref f: Fq12,
        lines: LinesDbl<Fq2>,
        witness: Fq12
    ) {}
    fn sz_last_step(
        ref self: Curve, sz: @SZCommitment, ref sz_acc: SZAcc, ref f: Fq12, lines: LinesDbl<Fq2>
    ) {}

    fn sz_post_miller(
        ref self: Curve,
        sz: @SZCommitment,
        ref sz_acc: SZAcc,
        f: Fq12,
        alpha_beta: Fq12,
        residue: Residue<Fq>
    ) -> bool {
        false
    }
}
