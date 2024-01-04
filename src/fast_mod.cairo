// These mod functions are heavily optimised for < 255 bit numbers
// and may break for full 256 bit numbers

#[inline(always)]
fn add_mod(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    // Doesn't overflow coz we have at least one bit to spare
    (a + b) % modulo
}

#[inline(always)]
fn sub_mod(mut a: u256, mut b: u256, modulo: u256) -> u256 {
    // reduce values
    if (a >= b) {
        return a - b;
    }
    (modulo - b) + a
}
