use schwartz_zippel::eval::SchZipEvalTrait;
use bn254_u256::print::{FqDisplay};
use bn254_u256::{
    Fq, Fq2, Fq3, Fq12, FqD12, FqD4, scale_9, Bn254U256Curve, Bn254FqOps, SZCommitment,
    SZCommitmentAccumulator
};
use schwartz_zippel::{SchZipSteps, SchZipEval, Lines, FS034, F034X2, LinesDbl, Residue};

type Curve = Bn254U256Curve;
type SZCAcc = SZCommitmentAccumulator;

fn acc_mul_eval_12(ref self: Curve, a: FqD12, ref acc: Fq, fiat_shamir: @Array<Fq>) {
    acc = self.mul(acc, self.eval_fq12(a, fiat_shamir));
}

fn acc_mul_eval_034_x3(ref self: Curve, lines: Lines<Fq2>, ref acc: Fq, fiat_shamir: @Array<Fq>) {
    let (l1, l2, l3) = lines;
    acc = self.mul(acc, self.eval_f1379(direct_f034(ref self, l1), fiat_shamir));
    acc = self.mul(acc, self.eval_f1379(direct_f034(ref self, l2), fiat_shamir));
    acc = self.mul(acc, self.eval_f1379(direct_f034(ref self, l3), fiat_shamir));
}

fn acc_equation_eval(ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, mut eval: Fq) {
    // multiply fiat shamir for rlc
    eval = self.mul(eval, *sz.rlc_fiat_shamir.at(sz_acc.index));

    // accumulate
    sz_acc.rhs_lhs = self.add(sz_acc.rhs_lhs, eval);
    sz_acc.index += 1;
}

fn acc_equation_lhs_rem(ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, mut eval: Fq) {
    // evaluate remainder and cache it for later
    sz_acc.rem_cache = self.eval_fq12(*(sz.remainders.at(sz_acc.index)), sz.fiat_shamir_powers);

    // sub remainder from accumulator
    eval = self.sub(eval, sz_acc.rem_cache);

    acc_equation_eval(ref self, sz, ref sz_acc, eval)
}

pub impl Bn254SchwartzZippelSteps of SchZipSteps<Curve, SZCommitment, SZCAcc, Fq, FqD12> {
    fn sz_init(ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, ref f: FqD12) {}
    fn sz_zero_bit(
        ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, ref f: FqD12, lines: Lines<Fq2>
    ) {
        let (_l1, _l2, _l3) = lines;
        let _f_eval: Fq = self.eval_fq12(f, sz.fiat_shamir_powers);
    }

    fn sz_nz_bit(
        ref self: Curve,
        sz: @SZCommitment,
        ref sz_acc: SZCAcc,
        ref f: FqD12,
        lines: LinesDbl<Fq2>,
        witness: FqD12
    ) {
        let _f_eval: Fq = self.eval_fq12(f, sz.fiat_shamir_powers);
        let _wit_eval: Fq = self.eval_fq12(witness, sz.fiat_shamir_powers);
    }

    fn sz_last_step(
        ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, ref f: FqD12, lines: LinesDbl<Fq2>
    ) {
        let _f_eval: Fq = self.eval_fq12(f, sz.fiat_shamir_powers);
    }

    fn sz_post_miller(
        ref self: Curve,
        sz: @SZCommitment,
        ref sz_acc: SZCAcc,
        f: FqD12,
        alpha_beta: FqD12,
        residue: Residue<Fq>
    ) -> bool {
        let _f_eval: Fq = self.eval_fq12(f, sz.fiat_shamir_powers);
        let _albe_eval: Fq = self.eval_fq12(alpha_beta, sz.fiat_shamir_powers);
        false
    }
}

fn direct_fq12(ref curve: Curve, a: Fq12) -> FqD12 {
    let Fq12 { //
    c0: Fq3 { //
    c0: Fq2 { c0: a0, c1: a1 }, //
    c1: Fq2 { c0: a2, c1: a3 }, //
    c2: Fq2 { c0: a4, c1: a5 } //
    }, //
    c1: Fq3 { //
    c0: Fq2 { c0: a6, c1: a7 }, //
    c1: Fq2 { c0: a8, c1: a9 }, //
    c2: Fq2 { c0: a10, c1: a11 } //
    } //
    } =
        a;
    (
        (
            curve.sub(a0, scale_9(ref curve, a1)),
            curve.sub(a6, scale_9(ref curve, a7)),
            curve.sub(a2, scale_9(ref curve, a3)),
            curve.sub(a8, scale_9(ref curve, a9)),
        ),
        (curve.sub(a4, scale_9(ref curve, a5)), curve.sub(a10, scale_9(ref curve, a11)), a1, a7,),
        (a3, a9, a5, a11,)
    )
}

fn direct_f034(ref curve: Curve, a: FS034<Fq2>) -> FqD4 {
    let FS034::<Fq2> { c3: Fq2 { c0: a6, c1: a7 }, c4: Fq2 { c0: a8, c1: a9 } } = a;

    (
        curve.sub(a6, scale_9(ref curve, a7)), // c1
        curve.sub(a8, scale_9(ref curve, a9)), // c3
        a7, // c7
        a9, // c9
    )
}
