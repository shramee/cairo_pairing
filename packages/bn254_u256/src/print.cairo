use bn254_u256::{Fq, Fq2, Fq12, F034, PtG1, PtG2};

use core::to_byte_array::AppendFormattedToByteArray;
use core::fmt::{Display, Formatter, Error};
pub impl F034Display of core::fmt::Display<F034> {
    fn fmt(self: @F034, ref f: Formatter) -> Result<(), Error> {
        write!(f, "f034({},{},{},{}\n),", *self.c3.c0, *self.c3.c1, *self.c4.c0, *self.c4.c1)
    }
}

pub impl Fq12Display of core::fmt::Display<Fq12> {
    fn fmt(self: @Fq12, ref f: Formatter) -> Result<(), Error> {
        write!(
            f,
            "fq12({},{},{},{},{},{},{},{},{},{},{},{}\n),",
            *self.c0.c0.c0,
            *self.c0.c0.c1,
            *self.c0.c1.c0,
            *self.c0.c1.c1,
            *self.c0.c2.c0,
            *self.c0.c2.c1,
            *self.c1.c0.c0,
            *self.c1.c0.c1,
            *self.c1.c1.c0,
            *self.c1.c1.c1,
            *self.c1.c2.c0,
            *self.c1.c2.c1,
        )
    }
}

pub impl FqDisplay of core::fmt::Display<Fq> {
    fn fmt(self: @Fq, ref f: Formatter) -> Result<(), Error> {
        let base = 16_u256;
        write!(f, "\n 0x").unwrap();
        self.c0.append_formatted_to_byte_array(ref f.buffer, base.try_into().unwrap());
        Result::Ok(())
    }
}

pub impl Fq2Display of Display<Fq2> {
    fn fmt(self: @Fq2, ref f: Formatter) -> Result<(), Error> {
        write!(f, "fq2({},{}\n),", *self.c0, *self.c1)
    }
}

pub impl G1Display of Display<PtG1> {
    fn fmt(self: @PtG1, ref f: Formatter) -> Result<(), Error> {
        write!(f, "g2({},{}\n),", self.x, self.y)
    }
}

pub impl G2Display of Display<PtG2> {
    fn fmt(self: @PtG2, ref f: Formatter) -> Result<(), Error> {
        write!(f, "g2({},{},{},{}\n),", self.x.c0, self.x.c1, self.y.c0, self.y.c1,)
    }
}
