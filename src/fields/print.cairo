use super::{Fq, Fq2, Fq6, Fq12};
use debug::PrintTrait;
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
