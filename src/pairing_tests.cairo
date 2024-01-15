use bn::pairing::line_func;
use bn::{g1, g2};
#[test]
#[available_gas(200000000)]
fn test_line_func() {}

#[test]
#[available_gas(200000000)]
fn bench_line_func() {
    line_func(g1::one(), g1::one(), g1::one());
}
