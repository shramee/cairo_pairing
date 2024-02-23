fn recurse(mut a: felt252) -> felt252 {
    a += 1;
    // println!("{a}");
    if a == 10 {
        a
    } else {
        recurse(a)
    }
}

#[test]
#[available_gas(2000000)]
fn rcrsve() -> felt252 {
    recurse(0)
}

#[test]
#[available_gas(2000000)]
fn loop10() -> felt252 {
    let mut a: felt252 = 0;

    loop {
        a += 1;
        if a == 10 {
            break;
        }
    };
    // println!("{a}");
    a
}

#[test]
#[available_gas(2000000)]
fn noloop() -> felt252 {
    let mut a: felt252 = 0;

    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    a += 1;
    if a == 10 {}
    // println!("{a}");
    a
}
