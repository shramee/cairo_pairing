use core::to_byte_array::AppendFormattedToByteArray;
use core::traits::TryInto;
use bn::fields::{Fq, Fq2, Fq6, Fq12, fq12, FS034, FS01234};
use integer::u512;
use debug::PrintTrait;
use core::fmt::{Display, Formatter, Error};
use core::result::Result;
use bn::fast_mod::u512Display;

impl FqDisplay of Display<Fq> {
    fn fmt(self: @Fq, ref f: Formatter) -> Result<(), Error> {
        let base = 16_u256;
        write!(f, "\n0x").unwrap();
        self.c0.append_formatted_to_byte_array(ref f.buffer, base.try_into().unwrap());
        Result::Ok(())
    }
}

impl Fq2Display of Display<Fq2> {
    fn fmt(self: @Fq2, ref f: Formatter) -> Result<(), Error> {
        write!(f, "fq2({},{}\n),", *self.c0, *self.c1)
    }
}

impl F034Display of Display<FS034> {
    fn fmt(self: @FS034, ref f: Formatter) -> Result<(), Error> {
        write!(f, "f034({},{},{},{}\n),", self.c3.c0, self.c3.c1, self.c4.c0, self.c4.c1,)
    }
}

impl F01234Display of Display<FS01234> {
    fn fmt(self: @FS01234, ref f: Formatter) -> Result<(), Error> {
        let FS01234 { c0, c1, } = *self;
        write!(
            f,
            "f01234({},{},{},{},{},{},{},{},{},{}\n),",
            c0.c0.c0,
            c0.c0.c1,
            c0.c1.c0,
            c0.c1.c1,
            c0.c2.c0,
            c0.c2.c1,
            c1.c0.c0,
            c1.c0.c1,
            c1.c1.c0,
            c1.c1.c1,
        )
    }
}

impl Fq6Display of Display<Fq6> {
    fn fmt(self: @Fq6, ref f: Formatter) -> Result<(), Error> {
        write!(
            f,
            "fq6({},{},{},{},{},{}\n),",
            self.c0.c0,
            self.c0.c1,
            self.c1.c0,
            self.c1.c1,
            self.c2.c0,
            self.c2.c1
        )
    }
}

impl Fq12Display of Display<Fq12> {
    fn fmt(self: @Fq12, ref f: Formatter) -> Result<(), Error> {
        write!(
            f,
            "fq12({},{},{},{},{},{},{},{},{},{},{},{}\n),",
            self.c0.c0.c0,
            self.c0.c0.c1,
            self.c0.c1.c0,
            self.c0.c1.c1,
            self.c0.c2.c0,
            self.c0.c2.c1,
            self.c1.c0.c0,
            self.c1.c0.c1,
            self.c1.c1.c0,
            self.c1.c1.c1,
            self.c1.c2.c0,
            self.c1.c2.c1
        )
    }
}

impl FqPrintImpl of PrintTrait<Fq> {
    fn print(self: Fq) {
        self.c0.print();
    }
}

impl Fq2PrintImpl of PrintTrait<Fq2> {
    fn print(self: Fq2) {
        self.c0.print();
        self.c1.print();
    }
}

impl Fq6PrintImpl of PrintTrait<Fq6> {
    fn print(self: Fq6) {
        self.c0.print();
        self.c1.print();
        self.c2.print();
    }
}

impl Fq12PrintImpl of PrintTrait<Fq12> {
    fn print(self: Fq12) {
        self.c0.print();
        self.c1.print();
    }
}
