use super::{Fq2, Fq6};

#[derive(Copy, Drop, Serde)]
struct Fq {
    c0: u256,
}

// Sparse Fq12 element containing only c3 and c4 Fq2 (c0 is 1)
// Equivalent to,
// Fq12{
//   c0: Fq6{c0: 1, c1: 0, c2: 0},
//   c1: Fq6{c0: c3, c1: c4, c2: 0},
// }
#[derive(Copy, Drop, Serde)]
struct F12S034 {
    pub c3: Fq,
    pub c4: Fq,
}

// Sparse Fq6 element containing c0 and c1 Fq2
type F6S01 = Fq2<Fq2<u256>>;

// Sparse Fq12 element containing c0, c1, c2, c3 and c4 Fq2
#[derive(Copy, Drop, Serde)]
struct F12S01234 {
    pub c0: Fq6<u256>,
    pub c1: F6S01,
}

type Fq12Direct<T> = (Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq);
type F12S01234Direct<T> = ((Fq, Fq, Fq, Fq, Fq), (Fq, Fq, Fq, Fq, Fq));

struct F12S034Direct {
    c1: Fq,
    c3: Fq,
    c7: Fq,
    c9: Fq,
}
