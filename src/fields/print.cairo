use core::to_byte_array::AppendFormattedToByteArray;
use core::traits::TryInto;
use bn::fields::{Fq, Fq2, Fq6, Fq12, fq12};
use debug::PrintTrait;
use core::fmt::{Display, Formatter, Error};
use core::result::Result;

impl DisplayFq of Display<Fq> {
    fn fmt(self: @Fq, ref f: Formatter) -> Result<(), Error> {
        let base = 16_u256;
        write!(f, "\n0x");
        self.c0.append_formatted_to_byte_array(ref f.buffer, base.try_into().unwrap());
        Result::Ok(())
    }
}

impl DisplayFq2 of Display<Fq2> {
    fn fmt(self: @Fq2, ref f: Formatter) -> Result<(), Error> {
        write!(f, "{}{}", *self.c0, *self.c1)
    }
}

impl DisplayFq6 of Display<Fq6> {
    fn fmt(self: @Fq6, ref f: Formatter) -> Result<(), Error> {
        write!(f, "{}{}{}", *self.c0, *self.c1, *self.c2)
    }
}

impl DisplayFq12 of Display<Fq12> {
    fn fmt(self: @Fq12, ref f: Formatter) -> Result<(), Error> {
        write!(f, "{}{}", *self.c0, *self.c1)
    }
}

#[cfg(test)]
mod test {
    use super::{fq12, DisplayFq12};
    #[test]
    #[available_gas(200000000)]
    fn print_fq12() {
        let f = fq12(
            0x1025124034fecc32ba2c3bbbcdb356c5bd84a787f0a9c5e1f9a34d5b87dae85a,
            0x1aafb1f7de052c1c1187f7d294d2204bf4e854a05965817e51014a355d917f96,
            0x26c79392cd82f5f15f1366f8c70f618837fe6ccc10c10815369bc8e1412caae,
            0x1d65be11b6b500a55c3c53ca4c033319626a9bc82fa79316bfb14bcd86f0aca5,
            0x8bd3e1971621469e271e9b18016edbc3517c94001240a1e5ef3b07c10860383,
            0xe5327ccc2114231fcd953aa29ccc1fd04ec1bced962c7f9534b9a001dd41a75,
            0x2b7c8e0abca6a7476f0936f535c5e6469ad4b94f8f24c6f437f6d6686a1b381b,
            0x29679b4f134ab2b2e02d2c82a385b12d2ee2272a7e350fba6f80588c0e0afa13,
            0x29163531c4ea85c647a9cd25e2de1433f12569f772eb83fcd8a997f3ca309cee,
            0x23bc9fb95fcf761320a0a287addd92dfaeb1ffc8bf8a943e703fc39f1e9d3085,
            0x236942b30ace732d8b186b0702ea748b375e4405799aa59cf2ae5459f99216f4,
            0x10fc55420be890b138082d746e66bf86f4efe8190cc83313a792dd156bc76e1f,
        );
        println!("Test fq12: {}", f);
    }
}

#[cfg(test)]
impl FqPrintImpl of PrintTrait<Fq> {
    fn print(self: Fq) {
        self.c0.print();
    }
}

#[cfg(test)]
impl Fq2PrintImpl of PrintTrait<Fq2> {
    fn print(self: Fq2) {
        self.c0.print();
        self.c1.print();
    }
}

#[cfg(test)]
impl Fq6PrintImpl of PrintTrait<Fq6> {
    fn print(self: Fq6) {
        self.c0.print();
        self.c1.print();
        self.c2.print();
    }
}

#[cfg(test)]
impl Fq12PrintImpl of PrintTrait<Fq12> {
    fn print(self: Fq12) {
        self.c0.print();
        self.c1.print();
    }
}
