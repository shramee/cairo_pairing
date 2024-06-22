// [PASS] bn::fields::fq_12_direct::direct_tower_tests::tower_to_direct_to_tower_test (gas: ~12)
//         steps: 2422
// [PASS] bn::fields::fq_12_direct::direct_tower_tests::tower_to_direct_test (gas: ~6)
//         steps: 1246
// [PASS] bn::fields::fq_12_direct::direct_tower_tests::direct_to_tower_test (gas: ~7)
//         steps: 1307
// [PASS] bn::fields::fq_12_direct::direct_tower_tests::direct_to_tower_to_direct_test (gas: ~12)
//         steps: 2392

use bn::curve::{scale_9, FIELD};
use bn::fields::{
    FieldUtils, FieldOps, FieldShortcuts, fq, Fq, Fq2, Fq6, Fq12, fq12, FS01234, FS034, FS01
};
use bn::fields::print::{FqDisplay, Fq12Display};

#[inline(always)]
fn fq12_from_fq(
    a0: Fq, a1: Fq, a2: Fq, a3: Fq, a4: Fq, a5: Fq, b0: Fq, b1: Fq, b2: Fq, b3: Fq, b4: Fq, b5: Fq
) -> Fq12 {
    Fq12 {
        c0: Fq6 {
            c0: Fq2 { c0: a0, c1: a1 }, c1: Fq2 { c0: a2, c1: a3 }, c2: Fq2 { c0: a4, c1: a5 }
        },
        c1: Fq6 {
            c0: Fq2 { c0: b0, c1: b1 }, c1: Fq2 { c0: b2, c1: b3 }, c2: Fq2 { c0: b4, c1: b5 }
        },
    }
}

fn direct_to_tower(x: Fq12) -> Fq12 {
    let Fq12 { c0, c1 } = x;
    let Fq6 { c0: b0, c1: b1, c2: b2 } = c0;
    let Fq6 { c0: b3, c1: b4, c2: b5 } = c1; // This should be c1 instead of c0
    let Fq2 { c0: a0, c1: a1 } = b0;
    let Fq2 { c0: a2, c1: a3 } = b1;
    let Fq2 { c0: a4, c1: a5 } = b2;
    let Fq2 { c0: a6, c1: a7 } = b3;
    let Fq2 { c0: a8, c1: a9 } = b4;
    let Fq2 { c0: a10, c1: a11 } = b5;

    fq12_from_fq(
        a0 + scale_9(a6),
        a6,
        a2 + scale_9(a8),
        a8,
        a4 + scale_9(a10),
        a10,
        a1 + scale_9(a7),
        a7,
        a3 + scale_9(a9),
        a9,
        a5 + scale_9(a11),
        a11,
    )
}

type Fq12Direct = (Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq, Fq);
type FS01234Direct = ((Fq, Fq, Fq, Fq, Fq), (Fq, Fq, Fq, Fq, Fq));

impl Fq12IntoFq12Direct of Into<Fq12, Fq12Direct> {
    #[inline(always)]
    fn into(self: Fq12) -> Fq12Direct {
        let Fq12 { c0, c1 } = self;
        let Fq6 { c0: b0, c1: b1, c2: b2 } = c0;
        let Fq6 { c0: b3, c1: b4, c2: b5 } = c1; // This should be c1 instead of c0
        let Fq2 { c0: a0, c1: a1 } = b0;
        let Fq2 { c0: a2, c1: a3 } = b1;
        let Fq2 { c0: a4, c1: a5 } = b2;
        let Fq2 { c0: a6, c1: a7 } = b3;
        let Fq2 { c0: a8, c1: a9 } = b4;
        let Fq2 { c0: a10, c1: a11 } = b5;
        (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11)
    }
}

impl Fq12DirectIntoFq12 of Into<Fq12Direct, Fq12> {
    #[inline(always)]
    fn into(self: Fq12Direct) -> Fq12 {
        let (a0, a1, a2, a3, a4, a5, b0, b1, b2, b3, b4, b5) = self;
        fq12_from_fq(a0, a1, a2, a3, a4, a5, b0, b1, b2, b3, b4, b5)
    }
}

fn tower_to_direct(x: Fq12) -> Fq12Direct {
    let Fq12 { c0, c1 } = x;
    let Fq6 { c0: b0, c1: b1, c2: b2 } = c0;
    let Fq6 { c0: b3, c1: b4, c2: b5 } = c1; // This should be c1 instead of c0
    let Fq2 { c0: a0, c1: a1 } = b0;
    let Fq2 { c0: a2, c1: a3 } = b1;
    let Fq2 { c0: a4, c1: a5 } = b2;
    let Fq2 { c0: a6, c1: a7 } = b3;
    let Fq2 { c0: a8, c1: a9 } = b4;
    let Fq2 { c0: a10, c1: a11 } = b5;

    (
        a0 - scale_9(a1),
        a6 - scale_9(a7),
        a2 - scale_9(a3),
        a8 - scale_9(a9),
        a4 - scale_9(a5),
        a10 - scale_9(a11),
        a1,
        a7,
        a3,
        a9,
        a5,
        a11,
    )
}

fn tower01234_to_direct(x: FS01234) -> FS01234Direct {
    let FS01234 { c0, c1 } = x;
    let Fq6 { c0: b0, c1: b1, c2: b2 } = c0;
    let FS01 { c0: b3, c1: b4 } = c1; // This should be c1 instead of c0
    let Fq2 { c0: a0, c1: a1 } = b0;
    let Fq2 { c0: a2, c1: a3 } = b1;
    let Fq2 { c0: a4, c1: a5 } = b2;
    let Fq2 { c0: a6, c1: a7 } = b3;
    let Fq2 { c0: a8, c1: a9 } = b4;

    let a1x9 = scale_9(a1);
    let a7x9 = scale_9(a7);
    let a3x9 = scale_9(a3);
    let a9x9 = scale_9(a9);
    let a5x9 = scale_9(a5);
    ((a0 - a1x9, a6 - a7x9, a2 - a3x9, a8 - a9x9, a4 - a5x9,), (a1, a7, a3, a9, a5,),)
}

struct FS034Direct {
    c1: Fq,
    c3: Fq,
    c7: Fq,
    c9: Fq,
}

fn tower034_to_direct(x: FS034) -> FS034Direct {
    let FS034 { c3: Fq2 { c0: a6, c1: a7 }, c4: Fq2 { c0: a8, c1: a9 } } = x;

    FS034Direct { c1: a6 - scale_9(a7), c3: a8 - scale_9(a9), c7: a7, c9: a9, }
}

#[cfg(test)]
mod direct_tower_tests {
    use bn::fields::print::{FqDisplay, Fq12Display};
    use super::{Fq12, fq12, direct_to_tower, tower_to_direct, Fq12DirectIntoFq12};
    #[inline(always)]
    fn f() -> Fq12 {
        fq12(
            0x2014F7FF079B44C8B4DD9D0871F29507F55743B4A920F5E6442B0B74D59D0CB0,
            0x231EFD9C8C610DA016795AA966A226230D06208E5A8925D3EF51876084AF1234,
            0x1BFC0CB821527933A0E61C01B6596DB4FEAA27426BB9A7B1949A02533A55BE7D,
            0x1DEB79BDB1AC608BA40A9AF9618A6562970A107C3CD6FBCFAD1F70BAC45A7F9C,
            0x3019B8F426C7AD1AF2D55E269C0057B47879B37289ABD6CE94805EEAD92EFCA0,
            0x1C904803D1B3FE92B5B89D85EDBA3DC9D409900E65FD558A69B6777F8A3A992E,
            0x2E7CB94F95F5864929D6E5F0BF5B7319710CC07481B724A144036E80F184A6A8,
            0x208B48CB1E1E7C1148A91EBEED6E546803A2F936F19E4FC3916C921B89BB1D97,
            0x293CB44FBD347437D3790AE5FCE1B69EED50551100DFC9853F6FF71C9D1DD2B4,
            0x1323833FBE11F78B26BB6241C225E8F777F283FC294715AA8ED6EAA4F5D71442,
            0x4AFCF2D2F24105882AA596EAB39AFF31913C1D61D549ED93FEAC085D1AFAD70,
            0x2A632C21B06EE37511B98D88758FE1E6ABFF7083BE6FEAF89B4C909F918155D6,
        )
    }

    #[inline(always)]
    fn f_direct() -> Fq12 {
        fq12(
            2869167661462205888021881017626539283107077520460937637190805025790219212934,
            19875268584579957771626589842858342092627306224516383710032836041644965792771,
            300897465083869778189127960634247417386781876631894698379884938693705217124,
            6406604136895351884244650481077951662602652493221269035437810593363747214391,
            14920533874205402117237311212244493385320271140428851076447385255125200178277,
            4674563719964437354829330363532424973786523735413518122151170740595874042658,
            15885705474718739425286833754429658334514875235463732297895440603739749028404,
            14720105298446771604977500711738121011648033903034094882725771204807804788119,
            13533121894586714793858784434530882469184747108908016238013045981320111095708,
            8656689617614101023533294353549139415831364512064203823967225129508183413826,
            12919682766360669510802146873570312587982593772326876122485550849492774459694,
            19172362085008327379870080610463146783220848611195065404816082523318372095446
        )
    }

    #[test]
    fn direct_to_tower_to_direct_test() {
        assert(direct_to_tower(tower_to_direct(f()).into()) == f(), 'dir 2 tow 2 dir failed');
    }

    #[test]
    fn tower_to_direct_to_tower_test() {
        assert(tower_to_direct(direct_to_tower(f())).into() == f(), 'dir 2 tow 2 dir failed');
    }

    #[test]
    fn direct_to_tower_test() {
        assert(direct_to_tower(f_direct()) == f(), '');
    }

    #[test]
    fn tower_to_direct_test() {
        assert(tower_to_direct(f()).into() == f_direct(), '');
    }
}
