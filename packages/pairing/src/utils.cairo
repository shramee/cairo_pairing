use fq_types::{FieldOps};
use ec_groups::{Affine, ECOperations};
use pairing::PPrecompute;

pub trait PairingUtilsTrait<TCurve, TFq> {
    fn p_precompute(ref self: TCurve, p: Affine<TFq>) -> PPrecompute<TFq>;
}


pub impl PairingUtils<
    TCurve, TFq, +FieldOps<TCurve, TFq>, +ECOperations<TCurve, TFq>, +Drop<TFq>, +Copy<TFq>
> of PairingUtilsTrait<TCurve, TFq> {
    // Precomputes p for the pairing function
    fn p_precompute(ref self: TCurve, p: Affine<TFq>) -> PPrecompute<TFq> {
        let y_inv = self.inv(p.y);
        let negx = self.neg(p.x);
        PPrecompute { neg_x_over_y: self.mul(negx, y_inv), y_inv }
    }
}
