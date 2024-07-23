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
    fn sz_init(ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, ref f: FqD12) { //
    // Compute next remainder
    }

    // Handles Schwartz Zippel verification for zero `O` bits,
    // * F ∈ Fq12, miller loop aggregation
    // * L1_L2 ∈ Sparse01234, Loop step lines L1 and L2 multiplied for lower degree
    // * L3 ∈ Sparse034, Last L3 line
    // * ```F(x) * F(x) * L1_L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * F(x) * L1_L2(x) * L3(x) - R(x) = Q(x) * P12(x)```
    fn sz_zero_bit(
        ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, ref f: FqD12, lines: Lines<Fq2>
    ) {
        // equation equivalence with p12 = x^12 + 18x^6 + 82
        // f * f * lines = q * p12 + remainder
        // all quotients are combined with rlc, so we isolate q and check equivalence at the end
        // thus the equation becomes,
        // f * f * lines - remainder = q * p12
        // remainder here is f for the next equation so we use it with sz_acc.rem_cache
        // at the end we multiply it with rem_fiat_shmir for RLC

        // init eval as a square of previous remainder evaluation cache
        let mut eval: Fq = self.sqr(sz_acc.rem_cache);

        // eval and accumulate lines
        acc_mul_eval_034_x3(ref self, lines, ref eval, sz.fiat_shamir_powers);

        // accumulate equation and remainder
        acc_equation_lhs_rem(ref self, sz, ref sz_acc, eval)
    }

    // Handles Schwartz Zippel verification for non-zero `P`/`N` bits,
    // * F ∈ Fq12, miller loop aggregation
    // * L1, L2, L3 ∈ Sparse01234, Loop step lines
    // * Witness ∈ Fq12, Residue witness (or it's inverse based on the bit value)
    // * ```F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) = R(x) + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) - R(x) = Q(x) * P12(x)```
    fn sz_nz_bit(
        ref self: Curve,
        sz: @SZCommitment,
        ref sz_acc: SZCAcc,
        ref f: FqD12,
        lines: LinesDbl<Fq2>,
        witness: FqD12
    ) {
        // equation equivalence with p12 = x^12 + 18x^6 + 82
        // f * f * lines * witness = q * p12 + remainder
        // all quotients are combined with rlc, so we isolate q and check equivalence at the end
        // thus the equation becomes,
        // f * f * lines * witness - remainder = q * p12
        // remainder here is f for the next equation so we use it with sz_acc.rem_cache
        // at the end we multiply it with rem_fiat_shmir for RLC

        // init eval as a square of previous remainder evaluation cache
        let mut eval: Fq = self.sqr(sz_acc.rem_cache);

        // eval and accumulate lines
        let ((l10, l11), (l20, l21), (l30, l31)) = lines;
        acc_mul_eval_034_x3(ref self, (l10, l20, l30), ref eval, sz.fiat_shamir_powers);
        acc_mul_eval_034_x3(ref self, (l11, l21, l31), ref eval, sz.fiat_shamir_powers);

        // eval and accumulate witness
        acc_mul_eval_12(ref self, witness, ref eval, sz.fiat_shamir_powers);

        // accumulate equation and remainder
        acc_equation_lhs_rem(ref self, sz, ref sz_acc, eval)
    }

    // Handles Schwartz Zippel verification for miller loop correction step,
    // * F ∈ Fq12, miller loop aggregation
    // * L1, L2, L3 ∈ Sparse01234, Correction step lines
    // * ```F(x) * L1(x) * L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * L1(x) * L2(x) * L3(x) - R(x) = Q(x) * P12(x)```
    fn sz_last_step(
        ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, ref f: FqD12, lines: LinesDbl<Fq2>
    ) {
        // equation equivalence with p12 = x^12 + 18x^6 + 82
        // f * f * lines = q * p12 + remainder
        // all quotients are combined with rlc, so we isolate q and check equivalence at the end
        // thus the equation becomes,
        // f * f * lines - remainder = q * p12
        // remainder here is f for the next equation so we use it with sz_acc.rem_cache
        // at the end we multiply it with rem_fiat_shmir for RLC

        // init eval as a square of previous remainder evaluation cache
        let mut eval: Fq = self.sqr(sz_acc.rem_cache);

        // eval and accumulate lines
        let ((l10, l11), (l20, l21), (l30, l31)) = lines;
        acc_mul_eval_034_x3(ref self, (l10, l20, l30), ref eval, sz.fiat_shamir_powers);
        acc_mul_eval_034_x3(ref self, (l11, l21, l31), ref eval, sz.fiat_shamir_powers);

        // accumulate equation and remainder
        acc_equation_lhs_rem(ref self, sz, ref sz_acc, eval)
    }

    // Handles Schwartz Zippel verification for post miller operation,
    // * R is just 1 so we have 11 less coefficients
    // * F ∈ Fq12, miller loop aggregation
    // * RQ, RIQ2, RQ3 ∈ Fq12, residue witness frobenius maps
    // * CubicScale ∈ Sparse Fq12, cubic scale factor
    // * ```F(x) * RQ(x) * RIQ2(x) * RQ3(x) * CubicScale(x) = R(x) + Q(x) * P12(x)```
    // * For r = 1, ```F(x) * RQ(x) * RIQ2(x) * RQ3(x) * CubicScale(x) = 1 + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * Or, ```F(x) * RQ(x) * RIQ2(x) * RQ3(x) * CubicScale(x) - 1 = Q(x) * P12(x)```
    fn sz_final(
        ref self: Curve,
        sz: @SZCommitment,
        ref sz_acc: SZCAcc,
        ref f: FqD12,
        alpha_beta: FqD12,
        r_pow_q: FqD12,
        r_inv_q2: FqD12,
        r_pow_q3: FqD12,
        cubic_scale: CubicScale
    ) {

        let (cubic_scale, witness, witness_inv) = residue;

        // final step,
        // f * alpha_beta * cubic_scale
        // * ```F(x) * RQ(x) * RInvQ2(x) * RQ3(x) * CubicScale(x) = R(x) + Q(x) * P12(x)```

        let mut eval: Fq = self.sqr(sz_acc.rem_cache);
        acc_mul_eval_12(ref self, witness, ref eval, sz.fiat_shamir_powers);

    // Handles Schwartz Zippel witness invert verification
    // * F, FInv ∈ Fq12, miller loop aggregation
    // * ```F(x) * FInv(x) = 1 + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * FInv(x) - 1 = Q(x) * P12(x)```
    // * Also compares cached rhs_lhs against quotient RLC
    // * ```rhs_lhs - QRLC(x) = 0```
    fn sz_verify(
        ref self: Curve,
        sz: @SZCommitment,
        ref sz_acc: SZCAcc,
        f: FqD12,
        witness: FqD12,
        witness_inv: FqD12,
    ) -> bool {
        // witness * witness_inv = 1 + q * p12
        // or, isolating q again,
        // witness * witness_inv - 1 = q * p12
        let mut eval = self.eval_fq12(witness, sz.fiat_shamir_powers); // witness
        acc_mul_eval_12(ref self, witness_inv, ref eval, sz.fiat_shamir_powers); // witness_inv
        eval = self.sub(eval, 1_u256.into());
        // This is a separate verification and shouldn't change remainder
        acc_equation_eval(ref self, sz, ref sz_acc, eval);
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
