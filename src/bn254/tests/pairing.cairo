use bn::traits::ECOperations;
use bn::pairing::line_func;
use bn::{g1, g2};
use bn::bn254::ORDER;

#[test]
#[available_gas(2000000000)]
fn test_line_func() {
    let one = g1::one();
    let two = one.double();
    let three = two.add(one);
    let negthree = g1::one().multiply(ORDER - 3);
    // let negtwo = g1::one().multiply(ORDER - 2);
    let negtwo = negthree.add(g1::one());
    // let negone = g1::one().multiply(ORDER - 1);
    let negone = negtwo.add(g1::one());

    // Adding a tenth test breaks stuff with:
    //  #747->#748: Got 'Offset overflow' error while moving [29].

    // assert(line_func(one, two, one).c0 == 0, 'wrong line one, two, one');
    assert(line_func(one, two, two).c0 == 0, 'wrong line one, two, two');
    assert(line_func(one, two, three).c0 != 0, 'wrong line one, two, three');
    assert(line_func(one, two, negthree).c0 == 0, 'wrong line one, two, negthree');
    assert(line_func(one, negone, one).c0 == 0, 'wrong line one, negone, one');
    assert(line_func(one, negone, negone).c0 == 0, 'wrong line one, negone, negone');
    assert(line_func(one, negone, two).c0 != 0, 'wrong line one, negone, two');
    assert(line_func(one, one, one).c0 == 0, 'wrong line one, one, one');
    assert(line_func(one, one, two).c0 != 0, 'wrong line one, one, two');
    assert(line_func(one, one, negtwo).c0 == 0, 'wrong line one, one, negtwo');
}

#[test]
#[available_gas(200000000)]
fn bench_line_func() {
    // bench_line_func ... ok (gas: 350050)
    // bench_line_func ... ok (gas: 287880)
    line_func(g1::one(), g1::one(), g1::one());
}
