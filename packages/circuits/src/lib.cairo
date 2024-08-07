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
