type Fq = u256;
type Fq2 = (Fq, Fq);

#[derive(Copy, Drop)]
struct AffineG2 {
    x: Fq2,
    y: Fq2
}


fn g2_pt(x1: Fq, x2: Fq, y1: Fq, y2: Fq) -> AffineG2 {
    AffineG2 { x: (x1, x2), y: (y1, y2) }
}


#[inline(always)]
fn one() -> AffineG2 {
    g2_pt(1, 2, 3, 4)
}
