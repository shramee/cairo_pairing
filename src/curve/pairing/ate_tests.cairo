use core::traits::TryInto;
use super::optimal_ate_utils::{step_double, step_dbl_add, PtG1, PtG2};
use super::optimal_ate_impls::{SingleMillerPrecompute, SingleMillerSteps};
use bn::curve::FIELD;
use bn::curve::groups::{g1, g2};
use bn::fields::{fq2};

fn points() -> (PtG1, PtG2) {
    (
        // g1 * 3
        g1(
            0x769bf9ac56bea3ff40232bcb1b6bd159315d84715b8e679f2d355961915abf0,
            0x2ab799bee0489429554fdb7c8d086475319e63b40b9c5b57cdf1ff3dd9fe2261,
        ),
        // g2 * 5
        g2(
            0x2e539c423b302d13f4e5773c603948eaf5db5df8ae8a9a9113708390a06410d8,
            0xa09ccf561b55fd99d1c1208dee1162457b57ac5af3759d50671e510e428b2a1,
            0x2f8d9f9ab83727c77a2fec063cb7b6e5eb23044ccf535ad49d46d394fb6f6bf6,
            0x19b763513924a736e4eebd0d78c91c1bc1d657fee4214057d21414011cfcc763,
        )
    )
}

#[test]
#[available_gas(2000000)]
fn test_step_double() {
    let (p, mut q) = points();
    let (pc, _) = (p, q).precompute(FIELD.try_into().unwrap());

    let lines = step_double(ref q, @pc.ppc, p, pc.field_nz);

    let expected = g2(
        0x20101834550a7d15aa7a685d3f0095b689822cb568dfc9690e0cc58e9826d8fb,
        0x566eed2b6bb584ca75fbe0ca9ffc98eb586c25812617df7e01a2b6d8270f0bf,
        0x19ea09d089c848b2dee00082395883e0b405de1da65d4b4aeebd50c84e47349d,
        0xa66c012d8ebf11c9a9fc4ccfeeab0ace62b1c1fa744f6c6173f1994e9241db7,
    );

    let expected_c3 = fq2(
        0x1c43298c88df08230fee9d84ac09ee48d34a29e278e8d58cb18769030ec4438,
        0x1c5954ca0cd04a09cd9b039b450f0241731c800e47aaa858c7e7142df032479c,
    );

    let expected_c4 = fq2(
        0x2269a2f98ab148f9c027b04961479c312d53748fc7eeba24a6a08850431486e7,
        0x200812b02c8345ebc2ac8cfd83b0ab717735e789edc6fbed6427646339d76800,
    );

    assert(lines.c3 == expected_c3, 'wrong dbl c3');
    assert(lines.c4 == expected_c4, 'wrong dbl c4');
    assert(q == expected, 'wrong dbl point');
}
