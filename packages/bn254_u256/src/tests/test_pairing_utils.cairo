use ec_groups::ECOperations;
use bn254_u256::{Bn254FqOps, Bn254U256Curve, PtG1, PtG2, Fq2PartialEq};
use bn254_u256::{bn254_curve, fq2, g1, g2, AffineOpsBn};
use bn254_u256::print::{Fq2Display, FqDisplay, G2Display};
use pairing::{PPrecompute, LineFn};
use pairing::{PairingUtils, CubicScale};

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
#[available_gas(25000000)]
fn test_step_double() {
    let mut curve = bn254_curve();
    let (p, mut acc) = points();
    let pc = curve.p_precompute(p);

    let lines = curve.step_double(ref acc, @pc);
    // let lines = step_double(ref acc, @pc.ppc, p, pc.field_nz);

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

    assert(acc == expected, 'wrong dbl point');
    assert(lines.c3 == expected_c3, 'wrong dbl c3');
    assert(lines.c4 == expected_c4, 'wrong dbl c4');
}
#[test]
#[available_gas(25000000)]
fn test_step_dbl_add() {
    let mut self = bn254_curve();
    let (p, mut q) = points();
    let pc = self.p_precompute(p);

    let mut acc = g2(
        0x20101834550a7d15aa7a685d3f0095b689822cb568dfc9690e0cc58e9826d8fb,
        0x566eed2b6bb584ca75fbe0ca9ffc98eb586c25812617df7e01a2b6d8270f0bf,
        0x19ea09d089c848b2dee00082395883e0b405de1da65d4b4aeebd50c84e47349d,
        0xa66c012d8ebf11c9a9fc4ccfeeab0ace62b1c1fa744f6c6173f1994e9241db7,
    );

    let q = self.pt_neg(q);

    let (l1, l2) = self.step_dbl_add(ref acc, q, @pc);

    let expected = g2(
        0x13f6762080e4a32b0d11bf75b55989e08b3be57060b4bd2148e9be49fc1ca587,
        0x1ace10298838161fdd3a6bb5dd157a808c19d4dac316bb5c001f68ee586f30b,
        0x51d866c133978bdaf7b2ea418164cc0c60477b9364bf9acae265a87e861daf,
        0xbc83eb241f95b562bfabecd0c21f1b335bdfb10d49ade6efa26ccef5dd4b570,
    );

    let expected_l1c3 = fq2(
        0x2ea01bda18a3afa787515bde36c0b9790a4cc7f340e33d3471081586a790b90f,
        0x140af9a8d461561feab5421b3c72561c2464ea8320c72234743977e8e84ab5ab,
    );

    let expected_l1c4 = fq2(
        0xdfaab795680572ff828956d2039bc2c6a2df601a0831068958003c695687660,
        0x105c3bc2b4ae5a3df5a3b8b8fdd0acec204b83077aaace9fd7f927b39ea59547,
    );

    let expected_l2c3 = fq2(
        0x25891a7b883843168b2ed6ed8b42d4fdada5df85402f00d884d7937fae24e496,
        0x1dfb565c82eac32c96880b9b1da38241175076b36ae8abbb8379ebec2f907b81,
    );

    let expected_l2c4 = fq2(
        0x2558f709e26d6843da2ffd7122906325c7fd61e6efd90886e94177d2520a6a50,
        0x2a0a12744f9deeb8e3aa6a42ee95f27d9939cdd9e62904e1f65cb72b98e9dfd8,
    );

    assert(acc == expected, 'wrong dbl_add point');
    assert(l1.c3 == expected_l1c3, 'wrong dbl_add l1c3');
    assert(l1.c4 == expected_l1c4, 'wrong dbl_add l1c4');
    assert(l2.c3 == expected_l2c3, 'wrong dbl_add l2c3');
    assert(l2.c4 == expected_l2c4, 'wrong dbl_add l2c4');
}
// #[test]
// #[available_gas(250000000)]
// fn test_step_correction() {
//     let mut curve = bn254_curve();
//     let (p, q) = points();
//     let (pc, _): (PreCompute, AffineG2) = (p, q).precompute(get_field_nz());
//     let mut acc = g2(
//         0x235817357e89826e377fd16a7f1a2ff53e0df7e86895b1958bd95fb6560fa941,
//         0x22108c7158743b9927b624e1a61a4aa7ba9b2f717799e4e0c5424e8343de2884,
//         0x934368739662af976071d3e9152e3172a82cd6012bf0d605f67e735e3b3cdfe,
//         0x15484f6b2822b319e27f88795c1512a5bf6b1837e4749dffb7086239979f4d21,
//     );
//     let (l1, l2) = correction_step(ref acc, @pc.ppc, p, pc.q);

//     // We skip final point operation to save costs
//     // let expected = g2(
//     //     0x242898b9a67f64300e584ef995ba56d75a6a66b236ee16145e9b1308dc24e3ce,
//     //     0x290d75d7b30b60ea7a2809bb7fd095e5c4131719ff499b33ddc8c67d95a743c7,
//     //     0x275fc70fde9a73de316c4ba654097840197be9141f31d3567188a8de06525572,
//     //     0x1c79853dd0050acf0f1de573eed5b81d5e287994df2452eb560c6262746e07fc,
//     // );

//     let expected_l1c3 = fq2(
//         0xd238aea84f1c5f3cc252629ef407db0ad7b441dd6616b994e374fb8c0413383,
//         0x304554bb4d99a4cebabe260f60ef18d59e887078e74321d4fdba79a9eeab1ddb,
//     );

//     let expected_l1c4 = fq2(
//         0x907fba323881daa70e1c572f69e77964e70ba22fb812dd9abcf304140574def,
//         0x404c3e3275e836536af9a08a8dff1fe867efac4a34ca9a42e10706f4d811b8d,
//     );

//     let expected_l2c3 = fq2(
//         0xd06e75cebbc8df7fd2ee7b4afe5a42586c26a96c3fc205128dfd9184f131d92,
//         0x1a80e9ca6ed93b661603d4f1acc3c982065301e91154bf63203e815a11befb0f,
//     );

//     let expected_l2c4 = fq2(
//         0x1fe98cea2f6991fdf8d51c06b75b57ee944309336cb488c4c85e2966afaf5dba,
//         0x16d794265926a808f8ce74b6d4b31606c9b429603f4f522be6e2cb3fcb069dcd,
//     );

//     assert(l1.c3 == expected_l1c3, 'wrong correction l1c3');
//     assert(l1.c4 == expected_l1c4, 'wrong correction l1c4');
//     assert(l2.c3 == expected_l2c3, 'wrong correction l2c3');
//     assert(l2.c4 == expected_l2c4, 'wrong correction l2c4');
// // We skip final point operation to save costs
// // assert(q == expected, 'wrong correction point');
// }


