// Fields
use bn::fields::{fq_12::Fq12FrobeniusTrait, fq_12_direct};

// Field tower
use bn::fields::{Fq, Fq6, fq, Fq12, FS034, FS01234};
use bn::fields::{FqSparseTrait, Fq12Utils, Fq12Exponentiation, Fq12Sparse034, Fq12Sparse01234};
use bn::fields::fq_12_exponentiation::PairingExponentiationTrait;

// Field direct
use fq_12_direct::{FS034Direct, Fq12DirectIntoFq12, Fq12Direct, FS01234Direct, Fq12IntoFq12Direct};
use fq_12_direct::{
    direct_to_tower, direct_tuple_to_tower, tower_to_direct, tower01234_to_direct,
    tower034_to_direct,
};

// Math
use bn::curve::m::{sqr_nz, mul_nz, mul_u, u512_add, u512_add_u256, u512_reduce, add_u};
use bn::curve::{u512, U512BnAdd, U512Ops, scale_9 as x9, groups::ECOperations};

#[generate_trait]
impl SchZipEval of SchZipEvalTrait {
    #[inline(always)]
    fn eval_01234(a: FS01234, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>) -> Fq {
        SchZipEval::eval_01234_direct(tower01234_to_direct(a), fiat_shamir_pow, f_nz,)
    }

    fn eval_01234_direct(
        a: FS01234Direct, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> Fq { //
        // a tower_to_direct
        let ((c0, c1, c2, c3, c4), (c6, c7, c8, c9, c10)) = a;

        // evaluate FS01234 polynomial at fiat_shamir with precomputed powers
        let term_1 = mul_u((*fiat_shamir_pow[1]), c1.c0);
        let term_2 = mul_u((*fiat_shamir_pow[2]), c2.c0);
        let term_3 = mul_u((*fiat_shamir_pow[3]), c3.c0);
        let term_4 = mul_u((*fiat_shamir_pow[4]), c4.c0);
        let term_6 = mul_u((*fiat_shamir_pow[6]), c6.c0);
        let term_7 = mul_u((*fiat_shamir_pow[7]), c7.c0);
        let term_8 = mul_u((*fiat_shamir_pow[8]), c8.c0);
        let term_9 = mul_u((*fiat_shamir_pow[9]), c9.c0);
        let term_10 = mul_u((*fiat_shamir_pow[10]), c10.c0);

        // return the reduced sum of the terms
        let eval = u512_add_u256(term_1, c0.c0) // term x^1 + x^0
            .u_add(term_2) // term x^2
            .u_add(term_3) // term x^3
            .u_add(term_4) // term x^4
            .u_add(term_6) // term x^6
            .u_add(term_7) // term x^7
            .u_add(term_8) // term x^8
            .u_add(term_9) // term x^9
            .u_add(term_10); // term x^10
        fq(u512_reduce(eval, f_nz))
    }

    fn eval_fq12_direct_u(
        a: Fq12Direct, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> u512 { //
        let (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11) = a;
        // evaluate FS01234 polynomial at fiat_shamir with precomputed powers
        let term_0 = a0.c0;
        let term_1 = mul_u((*fiat_shamir_pow[1]), a1.c0);
        let term_2 = mul_u((*fiat_shamir_pow[2]), a2.c0);
        let term_3 = mul_u((*fiat_shamir_pow[3]), a3.c0);
        let term_4 = mul_u((*fiat_shamir_pow[4]), a4.c0);
        let term_5 = mul_u((*fiat_shamir_pow[5]), a5.c0);
        let term_6 = mul_u((*fiat_shamir_pow[6]), a6.c0);
        let term_7 = mul_u((*fiat_shamir_pow[7]), a7.c0);
        let term_8 = mul_u((*fiat_shamir_pow[8]), a8.c0);
        let term_9 = mul_u((*fiat_shamir_pow[9]), a9.c0);
        let term_10 = mul_u((*fiat_shamir_pow[10]), a10.c0);
        let term_11 = mul_u((*fiat_shamir_pow[11]), a11.c0);

        // return the reduced sum of the terms
        u512_add_u256(term_1, term_0) // term x^1 + x^0
            .u_add(term_2) // term x^2
            .u_add(term_3) // term x^3
            .u_add(term_4) // term x^4
            .u_add(term_5) // term x^5
            .u_add(term_6) // term x^6
            .u_add(term_7) // term x^7
            .u_add(term_8) // term x^8
            .u_add(term_9) // term x^9
            .u_add(term_10) // term x^10
            .u_add(term_11) // term x^11
    }

    fn eval_fq12_direct(
        a: Fq12Direct, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> Fq { //
        fq(u512_reduce(SchZipEval::eval_fq12_direct_u(a, fiat_shamir_pow, f_nz), f_nz))
    }

    fn eval_fq12(a: Fq12, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>) -> Fq { //
        SchZipEval::eval_fq12_direct(tower_to_direct(a), fiat_shamir_pow, f_nz)
    }

    fn eval_034(a: FS034, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>) -> Fq { //
        // a tower_to_direct
        let FS034Direct { c1, c3, c7, c9 } = tower034_to_direct(a);
        // evaluate FS01234 polynomial at fiat_shamir with precomputed powers
        let term_1 = mul_u(*fiat_shamir_pow[1], c1.c0);
        let term_3 = mul_u(*fiat_shamir_pow[3], c3.c0);
        let term_7 = mul_u(*fiat_shamir_pow[7], c7.c0);
        let term_9 = mul_u(*fiat_shamir_pow[9], c9.c0);
        // return the reduced sum of the terms
        let eval = u512_add_u256(term_1, 1) // term x^1 + x^0
            .u_add(term_3) // term x^3
            .u_add(term_7) // term x^7
            .u_add(term_9); // term x^9
        fq(u512_reduce(eval, f_nz))
    }

    #[inline(always)]
    fn eval_poly_30(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> u256 {
        u512_reduce(SchZipEval::eval_poly_30_u(polynomial, i, fiat_shamir_pow, f_nz), f_nz)
    }

    fn eval_poly_30_u(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> u512 {
        core::internal::revoke_ap_tracking();
        // We can do 16 additions without overflow
        // term 1 * x ^ 1 + term 0
        let mut acc1 = u512_add_u256(
            mul_u(*fiat_shamir_pow[1], *polynomial[i + 1]), *polynomial[i]
        );
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[2], *polynomial[i + 2]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[3], *polynomial[i + 3]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[4], *polynomial[i + 4]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[5], *polynomial[i + 5]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[6], *polynomial[i + 6]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[7], *polynomial[i + 7]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[8], *polynomial[i + 8]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[9], *polynomial[i + 9]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[10], *polynomial[i + 10]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[11], *polynomial[i + 11]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[12], *polynomial[i + 12]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[13], *polynomial[i + 13]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[14], *polynomial[i + 14]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[15], *polynomial[i + 15]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[16], *polynomial[i + 16]));

        // After next 16 additions we do U512BnAdd to reduce if needed

        let mut acc2 = mul_u(*fiat_shamir_pow[17], *polynomial[i + 17]);
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[18], *polynomial[i + 18]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[19], *polynomial[i + 19]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[20], *polynomial[i + 20]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[21], *polynomial[i + 21]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[22], *polynomial[i + 22]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[23], *polynomial[i + 23]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[24], *polynomial[i + 24]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[25], *polynomial[i + 25]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[26], *polynomial[i + 26]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[27], *polynomial[i + 27]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[28], *polynomial[i + 28]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[29], *polynomial[i + 29]));

        acc1 + acc2
    }

    fn eval_poly_11(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> u256 {
        let mut acc1 = u512_add_u256(
            mul_u(*fiat_shamir_pow[1], *polynomial[i + 1]), // term x^1
             *polynomial[i] // term x^0
        );
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[2], *polynomial[i + 2]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[3], *polynomial[i + 3]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[4], *polynomial[i + 4]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[5], *polynomial[i + 5]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[6], *polynomial[i + 6]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[7], *polynomial[i + 7]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[8], *polynomial[i + 8]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[9], *polynomial[i + 9]));
        acc1 = u512_add(acc1, mul_u(*fiat_shamir_pow[10], *polynomial[i + 10]));
        u512_reduce(acc1, f_nz)
    }

    fn eval_poly_51(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> u256 { //
        let (acc1, acc2, acc3) = SchZipEval::eval_poly_51_u(polynomial, i, fiat_shamir_pow, f_nz);
        u512_reduce(acc1 + acc2 + acc3, f_nz)
    }

    fn eval_poly_52(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> u256 { //
        let (acc1, acc2, acc3) = SchZipEval::eval_poly_51_u(polynomial, i, fiat_shamir_pow, f_nz);

        u512_reduce(acc1 + acc2 + acc3, f_nz)
    }

    fn eval_poly_51_u(
        polynomial: @Array<u256>, i: u32, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> (u512, u512, u512) { //
        core::internal::revoke_ap_tracking();

        // Process first 30 terms
        let acc1 = SchZipEval::eval_poly_30_u(polynomial, i, fiat_shamir_pow, f_nz);

        // let mut ci = 0;
        // println!("q_0_29 = poly(");
        // while ci != 30 {
        //     println!("#term{}({}){},", ci, i + ci, fq(*polynomial[i + ci]));
        //     ci += 1;
        // };
        // println!(")");
        // println!("q_x_0_29 = {}", fq(u512_reduce(acc1, f_nz)));

        // Process next 16 terms, i 30 - 45
        let mut acc2 = mul_u(*fiat_shamir_pow[30], *polynomial[i + 30]);
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[31], *polynomial[i + 31]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[32], *polynomial[i + 32]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[33], *polynomial[i + 33]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[34], *polynomial[i + 34]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[35], *polynomial[i + 35]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[36], *polynomial[i + 36]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[37], *polynomial[i + 37]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[38], *polynomial[i + 38]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[39], *polynomial[i + 39]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[40], *polynomial[i + 40]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[41], *polynomial[i + 41]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[42], *polynomial[i + 42]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[43], *polynomial[i + 43]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[44], *polynomial[i + 44]));
        acc2 = u512_add(acc2, mul_u(*fiat_shamir_pow[45], *polynomial[i + 45]));

        // Process las batch of terms, i 46 - 51
        let mut acc3 = mul_u(*fiat_shamir_pow[46], *polynomial[i + 46]);
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[47], *polynomial[i + 47]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[48], *polynomial[i + 48]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[49], *polynomial[i + 49]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[50], *polynomial[i + 50]));
        acc3 = u512_add(acc3, mul_u(*fiat_shamir_pow[51], *polynomial[i + 51]));

        (acc1, acc2, acc3)
    }

    fn eval_polynomial_u(
        mut polynomial: Span<u256>, fiat_shamir_pow: @Array<u256>, f_nz: NonZero<u256>
    ) -> u512 { //
        let c0 = polynomial.pop_front().unwrap();
        let mut acc = u512 { limb0: *c0.low, limb1: *c0.high, limb2: 0, limb3: 0 };
        let mut term_i = 0;
        let poly_len = polynomial.len();
        loop {
            term_i += 1;
            if poly_len == term_i {
                break;
            }
            acc = u512_add(acc, mul_u(*fiat_shamir_pow[term_i], *polynomial[term_i]));
        };

        acc
    }
}
