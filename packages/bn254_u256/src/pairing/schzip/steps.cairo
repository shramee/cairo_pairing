use schwartz_zippel::eval::SchZipEvalTrait;
use bn254_u256::curve::{ROOT_27TH, ROOT_27TH_SQ};
use bn254_u256::print::{FqDisplay, F034Display, Fq12Display, FqD12Display};
use bn254_u256::{
    direct_f034, direct_to_tower_fq12, Fq, Fq2, Fq3, Fq6, Fq12, FqD12, FqD4, scale_9,
    Bn254U256Curve, Bn254FqOps, SZCommitment, SZCommitmentAccumulator
};
use schwartz_zippel::{SchZipSteps, SchZipEval, Lines, FS034, F034X2, LinesDbl, Residue};
use pairing::{CubicScale};

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
    eval = self.mul(eval, *(*sz.rlc_fiat_shamir).at(sz_acc.index));

    // accumulate
    sz_acc.rhs_lhs = self.add(sz_acc.rhs_lhs, eval);
    sz_acc.index += 1;
}

fn acc_equation_lhs_rem(ref self: Curve, sz: @SZCommitment, ref sz_acc: SZCAcc, mut eval: Fq) {
    // evaluate remainder and cache it for later
    sz_acc.rem_cache = self.eval_fq12(*((*sz.remainders).at(sz_acc.index)), *sz.fiat_shamir_powers);

    // sub remainder from accumulator
    eval = self.sub(eval, sz_acc.rem_cache);

    acc_equation_eval(ref self, sz, ref sz_acc, eval)
}

pub impl Bn254SchwartzZippelSteps of SchZipSteps<Curve, SZCommitment, Fq, FqD12> {
    fn sz_init(ref self: Curve, ref sz: SZCommitment, ref f: FqD12) { //
        // Compute remainder for the first step
        sz.acc.rem_cache = self.eval_fq12(f, sz.fiat_shamir_powers);
    }

    // Handles Schwartz Zippel verification for zero `O` bits,
    // * F ∈ Fq12, miller loop aggregation
    // * L1_L2 ∈ Sparse01234, Loop step lines L1 and L2 multiplied for lower degree
    // * L3 ∈ Sparse034, Last L3 line
    // * ```F(x) * F(x) * L1_L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * F(x) * L1_L2(x) * L3(x) - R(x) = Q(x) * P12(x)```
    fn sz_zero_bit(ref self: Curve, ref sz: SZCommitment, ref f: FqD12, lines: Lines<Fq2>) {
        // equation equivalence with p12 = x^12 + 18x^6 + 82
        // f * f * lines = q * p12 + remainder
        // all quotients are combined with rlc, so we isolate q and check equivalence at the end
        // thus the equation becomes,
        // f * f * lines - remainder = q * p12
        // remainder here is f for the next equation so we use it with sz.acc.rem_cache
        // at the end we multiply it with rem_fiat_shmir for RLC

        // init eval as a square of previous remainder evaluation cache
        let mut eval = self.sqr(sz.acc.rem_cache);

        // eval and accumulate lines
        acc_mul_eval_034_x3(ref self, lines, ref eval, sz.fiat_shamir_powers);

        // accumulate equation and remainder
        acc_equation_lhs_rem(ref self, @sz, ref sz.acc, eval)
    }

    // Handles Schwartz Zippel verification for non-zero `P`/`N` bits,
    // * F ∈ Fq12, miller loop aggregation
    // * L1, L2, L3 ∈ Sparse01234, Loop step lines
    // * Witness ∈ Fq12, Residue witness (or it's inverse based on the bit value)
    // * ```F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) = R(x) + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) - R(x) = Q(x) * P12(x)```
    fn sz_nz_bit(
        ref self: Curve, ref sz: SZCommitment, ref f: FqD12, lines: LinesDbl<Fq2>, witness: FqD12
    ) {
        // equation equivalence with p12 = x^12 + 18x^6 + 82
        // f * f * lines * witness = q * p12 + remainder
        // all quotients are combined with rlc, so we isolate q and check equivalence at the end
        // thus the equation becomes,
        // f * f * lines * witness - remainder = q * p12
        // remainder here is f for the next equation so we use it with sz.acc.rem_cache
        // at the end we multiply it with rem_fiat_shmir for RLC

        // init eval as a square of previous remainder evaluation cache
        let mut eval = self.sqr(sz.acc.rem_cache);

        // eval and accumulate lines
        let ((l10, l11), (l20, l21), (l30, l31)) = lines;
        acc_mul_eval_034_x3(ref self, (l10, l20, l30), ref eval, sz.fiat_shamir_powers);
        acc_mul_eval_034_x3(ref self, (l11, l21, l31), ref eval, sz.fiat_shamir_powers);

        // eval and accumulate witness
        acc_mul_eval_12(ref self, witness, ref eval, sz.fiat_shamir_powers);

        // accumulate equation and remainder
        acc_equation_lhs_rem(ref self, @sz, ref sz.acc, eval)
    }

    // Handles Schwartz Zippel verification for miller loop correction step,
    // * F ∈ Fq12, miller loop aggregation
    // * L1, L2, L3 ∈ Sparse01234, Correction step lines
    // * ```F(x) * L1(x) * L2(x) * L3(x) = R(x) + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * L1(x) * L2(x) * L3(x) - R(x) = Q(x) * P12(x)```
    fn sz_last_step(ref self: Curve, ref sz: SZCommitment, ref f: FqD12, lines: LinesDbl<Fq2>) {
        // equation equivalence with p12 = x^12 + 18x^6 + 82
        // f * lines = q * p12 + remainder
        // all quotients are combined with rlc, so we isolate q and check equivalence at the end
        // thus the equation becomes,
        // f * lines - remainder = q * p12
        // remainder here is f for the next equation so we use it with sz.acc.rem_cache
        // at the end we multiply it with rem_fiat_shmir for RLC

        // init eval from previous remainder evaluation cache
        let mut eval: Fq = sz.acc.rem_cache;

        // eval and accumulate lines
        let ((l10, l11), (l20, l21), (l30, l31)) = lines;
        acc_mul_eval_034_x3(ref self, (l10, l20, l30), ref eval, sz.fiat_shamir_powers);
        acc_mul_eval_034_x3(ref self, (l11, l21, l31), ref eval, sz.fiat_shamir_powers);

        f = *sz.remainders.at(sz.acc.index);
        // accumulate equation and remainder
        acc_equation_lhs_rem(ref self, @sz, ref sz.acc, eval);
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
        ref sz: SZCommitment,
        ref f: FqD12,
        alpha_beta: FqD12,
        r_pow_q: FqD12,
        r_inv_q2: FqD12,
        r_pow_q3: FqD12,
        cubic_scale: CubicScale
    ) {
        let fiat_shamir = sz.fiat_shamir_powers;
        // init eval from previous remainder evaluation cache
        let mut eval = sz.acc.rem_cache;

        // eval and accumulate alpha_beta, r_pow_q, r_inv_q2, r_pow_q3
        acc_mul_eval_12(ref self, alpha_beta, ref eval, fiat_shamir);
        acc_mul_eval_12(ref self, r_pow_q, ref eval, fiat_shamir);
        acc_mul_eval_12(ref self, r_inv_q2, ref eval, fiat_shamir);
        acc_mul_eval_12(ref self, r_pow_q3, ref eval, fiat_shamir);
        match cubic_scale {
            CubicScale::Zero => {},
            CubicScale::One => {
                let ((_, _, _, _), (c4, _, _, _), (_, _, c10, _),) = ROOT_27TH;
                let cubic_scale = self
                    .add(self.mul(c4, *fiat_shamir[4]), self.mul(c10, *fiat_shamir[10]));
                eval = self.mul(eval, cubic_scale);
            },
            CubicScale::Two => {
                let ((_, _, c2, _), (_, _, _, _), (c8, _, _, _),) = ROOT_27TH_SQ;
                let cubic_scale = self
                    .add(self.mul(c2, *fiat_shamir[2]), self.mul(c8, *fiat_shamir[8]));
                eval = self.mul(eval, cubic_scale);
            },
        };
        // accumulate equation and remainder
        // remainder is one
        eval = self.sub(eval, 1_u256.into());
        // This is a separate verification and shouldn't change remainder
        acc_equation_eval(ref self, @sz, ref sz.acc, eval);
    }

    // Handles Schwartz Zippel witness invert verification
    // * F, FInv ∈ Fq12, miller loop aggregation
    // * ```F(x) * FInv(x) = 1 + Q(x) * P12(x)```
    // * Isolating Q(x) for RLC,
    // * ```F(x) * FInv(x) - 1 = Q(x) * P12(x)```
    // * Also compares cached rhs_lhs against quotient RLC
    // * ```rhs_lhs - QRLC(x) = 0```
    fn sz_verify(
        ref self: Curve, ref sz: SZCommitment, f: FqD12, witness: FqD12, witness_inv: FqD12,
    ) -> bool {
        // witness * witness_inv = 1 + q * p12
        // or, isolating q again,
        // witness * witness_inv - 1 = q * p12
        let mut eval = self.eval_fq12(witness, sz.fiat_shamir_powers); // witness
        acc_mul_eval_12(ref self, witness_inv, ref eval, sz.fiat_shamir_powers); // witness_inv

        eval = self.sub(eval, 1_u256.into());
        // This is a separate verification and shouldn't change remainder
        acc_equation_eval(ref self, @sz, ref sz.acc, eval);

        let qrlc = self.eval_poly(sz.qrlc, sz.fiat_shamir_powers);
        let qrlc = self.mul(qrlc, *sz.p12_x);
        sz.acc.rhs_lhs == qrlc
    }
}
