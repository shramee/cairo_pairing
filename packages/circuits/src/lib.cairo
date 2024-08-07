use core::circuit::{
    AddMod, MulMod, u96, CircuitElement, CircuitInput, circuit_add, circuit_sub, circuit_mul,
    circuit_inverse, EvalCircuitTrait, u384, CircuitOutputsTrait, CircuitModulus,
    AddInputResultTrait, CircuitInputs,
};

#[test]
#[available_gas(25000000)]
fn test_circuit_success() {
    let in1 = CircuitElement::<CircuitInput<0>> {};
    let in2 = CircuitElement::<CircuitInput<1>> {};
    let add = circuit_add(in1, in2);
    let inv = circuit_inverse(add);
    let sub = circuit_sub(inv, in2);
    let mul = circuit_mul(inv, sub);

    let modulus = TryInto::<_, CircuitModulus>::try_into([7, 0, 0, 0]).unwrap();
    let outputs = (mul, add, inv)
        .new_inputs()
        .next([3, 0, 0, 0])
        .next([6, 0, 0, 0])
        .done()
        .eval(modulus)
        .unwrap();

    assert(outputs.get_output(add) == u384 { limb0: 2, limb1: 0, limb2: 0, limb3: 0 }, '');
    assert(outputs.get_output(inv) == u384 { limb0: 4, limb1: 0, limb2: 0, limb3: 0 }, '');
    assert(outputs.get_output(sub) == u384 { limb0: 5, limb1: 0, limb2: 0, limb3: 0 }, '');
    assert(outputs.get_output(mul) == u384 { limb0: 6, limb1: 0, limb2: 0, limb3: 0 }, '');
}

#[test]
#[available_gas(25000000)]
fn test_circuit_mul() {
    let in1 = CircuitElement::<CircuitInput<0>> {};
    let in2 = CircuitElement::<CircuitInput<1>> {};
    let mul = circuit_mul(in1, in2);

    let modulus = TryInto::<_, CircuitModulus>::try_into([0xfffff, 0, 0, 0]).unwrap();
    let outputs = (mul,)
        .new_inputs()
        .next([5, 0, 0, 0])
        .next([6, 0, 0, 0])
        .done()
        .eval(modulus)
        .unwrap();
    assert(
        outputs.get_output(mul) == u384 { limb0: 30, limb1: 0, limb2: 0, limb3: 0 }, 'incorrect mul'
    );
}

#[test]
#[available_gas(25000000)]
fn test_circuit_add() {
    let in1 = CircuitElement::<CircuitInput<0>> {};
    let in2 = CircuitElement::<CircuitInput<1>> {};
    let add = circuit_add(in1, in2);

    let modulus = TryInto::<_, CircuitModulus>::try_into([0xfffff, 0, 0, 0]).unwrap();
    let outputs = (add,)
        .new_inputs()
        .next([1, 0, 0, 0])
        .next([6, 0, 0, 0])
        .done()
        .eval(modulus)
        .unwrap();
    assert(
        outputs.get_output(add) == u384 { limb0: 7, limb1: 0, limb2: 0, limb3: 0 }, 'incorrect add'
    );
}


#[test]
#[available_gas(25000000)]
fn circuit_5x_add() {
    let in1 = CircuitElement::<CircuitInput<0>> {};
    let in2 = CircuitElement::<CircuitInput<1>> {};
    let add = circuit_add(in1, in2);
    let add = circuit_add(in1, add);
    let add = circuit_add(in1, add);
    let add1 = circuit_add(in1, add);
    let add2 = circuit_add(in1, add1);

    let modulus = TryInto::<_, CircuitModulus>::try_into([0xfffff, 0, 0, 0]).unwrap();
    let outputs = (add2,)
        .new_inputs()
        .next([1, 0, 0, 0])
        .next([6, 0, 0, 0])
        .done()
        .eval(modulus)
        .unwrap();
    assert(
        outputs.get_output(add1) == u384 { limb0: 10, limb1: 0, limb2: 0, limb3: 0 },
        'incorrect add1'
    );
    assert(
        outputs.get_output(add2) == u384 { limb0: 11, limb1: 0, limb2: 0, limb3: 0 },
        'incorrect add2'
    );
}

#[test]
#[available_gas(25000000)]
fn circuit_5x_mul() {
    let in1 = CircuitElement::<CircuitInput<0>> {};
    let in2 = CircuitElement::<CircuitInput<1>> {};
    let mul = circuit_mul(in1, in2);
    let mul = circuit_mul(in2, mul);
    let mul = circuit_mul(in2, mul);
    let mul1 = circuit_mul(in2, mul);
    let mul2 = circuit_mul(in2, mul1);

    let modulus = TryInto::<_, CircuitModulus>::try_into([0xfffff, 0, 0, 0]).unwrap();
    let outputs = (mul2,)
        .new_inputs()
        .next([5, 0, 0, 0])
        .next([2, 0, 0, 0])
        .done()
        .eval(modulus)
        .unwrap();
    assert(
        outputs.get_output(mul1) == u384 { limb0: 80, limb1: 0, limb2: 0, limb3: 0 },
        'incorrect mul1'
    );
    assert(
        outputs.get_output(mul2) == u384 { limb0: 160, limb1: 0, limb2: 0, limb3: 0 },
        'incorrect mul2'
    );
}
