#[derive(Copy, Drop, Serde)]
struct Fq {
    c0: u256
}

fn fq(c0: u256) -> Fq {
    Fq { c0 }
}

#[derive(Copy, Drop, Serde)]
struct Fq2 {
    c0: Fq,
    c1: Fq,
}

fn fq2(c0: u256, c1: u256) -> Fq2 {
    Fq2 { c0: fq(c0), c1: fq(c1), }
}

#[derive(Copy, Drop, Serde)]
struct Fq6 {
    c0: Fq2,
    c1: Fq2,
    c2: Fq2,
}

fn fq6(c0: u256, c1: u256, c2: u256, c3: u256, c4: u256, c5: u256) -> Fq6 {
    Fq6 { c0: fq2(c0, c1), c1: fq2(c2, c3), c2: fq2(c4, c5) }
}

#[derive(Copy, Drop, Serde)]
struct Fq12 {
    c0: Fq6,
    c1: Fq6,
}

fn fq12(
    c0: u256,
    c1: u256,
    c2: u256,
    c3: u256,
    c4: u256,
    c5: u256,
    c6: u256,
    c7: u256,
    c8: u256,
    c9: u256,
    c10: u256,
    c11: u256
) -> Fq12 {
    Fq12 { c0: fq6(c0, c1, c2, c3, c4, c5), c1: fq6(c6, c7, c8, c9, c10, c11), }
}
