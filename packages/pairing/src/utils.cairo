use fq_types::{FieldOps, FieldUtils, Fq2, Fq2Ops, F12S034, fq2_scale, fq2_conjugate};
use ec_groups::{Affine, ECOperations};
use pairing::{PPrecompute, PiMapping, LineFn};

type F034<TFq> = F12S034<Fq2<TFq>>;

pub trait PairingUtilsTrait<TCurve, TFq> {
    // region Utils
    fn p_precompute(ref self: TCurve, p: Affine<TFq>) -> PPrecompute<TFq>;
    fn line_fn(ref self: TCurve, slope: Fq2<TFq>, s: Affine<Fq2<TFq>>) -> LineFn<Fq2<TFq>>;
    fn line_fn_at_p(ref self: TCurve, line: LineFn<Fq2<TFq>>, ppc: @PPrecompute<TFq>) -> F034<TFq>;
    fn point_and_slope_at_p(
        ref self: TCurve, slope: Fq2<TFq>, s: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> F034<TFq>;

    // region point operations
    fn step_dbl_add(
        ref self: TCurve, ref acc: Affine<Fq2<TFq>>, q: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> (F034<TFq>, F034<TFq>);
    fn step_double(
        ref self: TCurve, ref acc: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> F034<TFq>;
    fn step_add(
        ref self: TCurve, ref acc: Affine<Fq2<TFq>>, q: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> F034<TFq>;
    fn correction_step(
        ref self: TCurve,
        ref acc: Affine<Fq2<TFq>>,
        q: Affine<Fq2<TFq>>,
        pi_map: @PiMapping<TFq>,
        ppc: @PPrecompute<TFq>
    ) -> (F034<TFq>, F034<TFq>);
}

// #[generate_trait]
pub impl PairingUtils<
    TCurve,
    TFq,
    +FieldOps<TCurve, TFq>,
    +FieldOps<TCurve, Fq2<TFq>>,
    +ECOperations<TCurve, TFq>,
    +ECOperations<TCurve, Fq2<TFq>>,
    +Drop<TFq>,
    +Copy<TFq>
> of PairingUtilsTrait<TCurve, TFq> {
    // Precomputes p for the pairing function
    fn p_precompute(ref self: TCurve, p: Affine<TFq>) -> PPrecompute<TFq> {
        let y_inv = self.inv(p.y);
        let negx = self.neg(p.x);
        PPrecompute { neg_x_over_y: self.mul(negx, y_inv), y_inv }
    }

    #[inline(always)]
    fn line_fn(ref self: TCurve, slope: Fq2<TFq>, s: Affine<Fq2<TFq>>) -> LineFn<Fq2<TFq>> {
        let mx = self.mul(slope, s.x);
        LineFn { slope, c: self.sub(mx, s.y), }
    }

    #[inline(always)]
    fn line_fn_at_p(ref self: TCurve, line: LineFn<Fq2<TFq>>, ppc: @PPrecompute<TFq>) -> F034<TFq> {
        F034 {
            c3: fq2_scale(ref self, line.slope, *ppc.neg_x_over_y),
            c4: fq2_scale(ref self, line.c, *ppc.y_inv),
        }
    }

    #[inline(always)]
    fn point_and_slope_at_p(
        ref self: TCurve, slope: Fq2<TFq>, s: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> F034<TFq> {
        // 𝝺x - y
        let c = self.sub(self.mul(slope, s.x), s.y);
        F034 {
            c3: fq2_scale(ref self, slope, *ppc.neg_x_over_y), // 𝝺x/y
            c4: fq2_scale(ref self, c, *ppc.y_inv), // c/y
        }
    }

    // https://eprint.iacr.org/2022/1162 (Section 6.1)
    // computes acc = acc + q + acc and line evals for p
    // returns product of line evaluations to multiply with f
    fn step_dbl_add(
        ref self: TCurve, ref acc: Affine<Fq2<TFq>>, q: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> (F034<TFq>, F034<TFq>) {
        let s = acc;
        // s + q
        let slope1 = self.chord(s, q);
        let x1 = self.x_on_slope(s, slope1, q.x);
        let line1 = self.point_and_slope_at_p(slope1, s, ppc);

        // we skip y1 calculation and sub slope1 directly in second slope calculation

        // (s + q) + s
        // λ2 = (y2-y1)/(x2-x1), subbing y2 = λ(x2-x1)+y1
        // λ2 = -λ1-2y1/(x2-x1)
        let neg_slope1 = self.neg(slope1); // -λ1
        let y_2x = self.add(s.y, s.y); // 2s.y

        let x_diff = self.sub(x1, s.x); // x2 - s.x

        let slope_fraction = self.div(y_2x, x_diff); // y_2x / x_diff

        // -λ1 - (y1 + y1) / (x1 - s.x)
        let slope2 = self.sub(neg_slope1, slope_fraction); // -λ1 - slope_fraction
        acc = self.pt_on_slope(s, slope2, x1);
        let line2 = self.point_and_slope_at_p(slope2, s, ppc);

        // line functions
        (line1, line2)
    }

    // https://eprint.iacr.org/2022/1162 (Section 6.1)
    // computes acc = 2 * acc and line eval for p
    // returns line evaluation to multiply with f
    // #[inline(always)]
    fn step_double(
        ref self: TCurve, ref acc: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> F034<TFq> {
        let s = acc;
        // λ = 3x²/2y
        let slope = self.tangent(s);

        // p = (λ²-2x, λ(x-xr)-y)
        acc = self.pt_on_slope(s, slope, acc.x);
        self.point_and_slope_at_p(slope, s, ppc)
    }
    // https://eprint.iacr.org/2022/1162 (Section 6.1)
    // computes acc = acc + q and line eval for p
    // returns line evaluation to multiply with f
    // #[inline(always)]
    fn step_add(
        ref self: TCurve, ref acc: Affine<Fq2<TFq>>, q: Affine<Fq2<TFq>>, ppc: @PPrecompute<TFq>
    ) -> F034<TFq> {
        let s = acc;
        // λ = (yS−yQ)/(xS−xQ)
        let slope = self.chord(s, q);
        // p = (λ²-2x, λ(x-xr)-y)
        acc = self.pt_on_slope(s, slope, q.x);
        self.point_and_slope_at_p(slope, s, ppc)
    }

    // Realm of pairings, Algorithm 1, lines 8, 9, 10
    // https://eprint.iacr.org/2013/722.pdf
    // Code inspired by gnark
    // https://github.com/Consensys/gnark/blob/v0.9.1/std/algebra/emulated/sw_bn254/pairing.go#L529
    // #[inline(always)]
    fn correction_step(
        ref self: TCurve,
        ref acc: Affine<Fq2<TFq>>,
        q: Affine<Fq2<TFq>>,
        pi_map: @PiMapping<TFq>,
        ppc: @PPrecompute<TFq>,
    ) -> (F034<TFq>, F034<TFq>) {
        // Line 9: Q1 ← πₚ(Q),Q2 ← πₚ²(Q)
        // πₚ(x,y) = (xp,yp)
        // Q1 = π(Q)
        let q1 = Affine {
            x: self.mul(fq2_conjugate(ref self, q.x), *pi_map.PiQ1X2),
            y: self.mul(fq2_conjugate(ref self, q.y), *pi_map.PiQ1X3),
        };

        // Q2 = -π²(Q)
        let q2 = Affine {
            x: fq2_scale(ref self, q.x, *pi_map.PiQ2X2),
            y: self.neg(fq2_scale(ref self, q.y, *pi_map.PiQ2X3)),
        };

        // Line 10: if u < 0 then T ← −T, f ← fp6
        // skip line 10, ∵ x > 0

        // Line 11: d ← (gT,Q1)(P), T ← T + Q1, e ← (gT,−Q2)(P), T ← T − Q2

        // d ← (gT,Q1)(P), T ← T + Q1
        let d = self.step_add(ref acc, q1, ppc);

        // e ← (gT,−Q2)(P), T ← T − Q2
        // we can skip the T ← T − Q2 step coz we don't need the final point, just the line
        // function
        let slope = self.chord(acc, q2);
        let e = self.point_and_slope_at_p(slope, acc, ppc);

        // f ← f·(d·e) is left for the caller

        // return line functions
        (d, e)
    }
}

pub trait MillerRunnerTrait<TCurve, TRunner> {
    // first and second step, O and N
    fn miller_bit_1_2(ref self: TCurve, ref runner: TRunner, i: (u32, u32));

    // 0 bit
    fn miller_bit_o(ref self: TCurve, ref runner: TRunner, i: u32);

    // 1 bit
    fn miller_bit_p(ref self: TCurve, ref runner: TRunner, i: u32);

    // -1 bit
    fn miller_bit_n(ref self: TCurve, ref runner: TRunner, i: u32);

    // last step
    fn miller_last(ref self: TCurve, ref runner: TRunner);
}

