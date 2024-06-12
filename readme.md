# Cairo Pairing

## Contents

1. [Base implementation](#Base-implementation)
2. [Residue witness](#Residue-witness)
3. [Extension field operations](#Extension-field-operations)


## Base implementation

Base implementation follows from these papers,

1. Field extensions arithmetic
	- Multiplication and Squaring on Pairing-Friendly Fields
	- https://ia.cr/2006/471
	- Augusto Jun Devegili, Colm O hEigeartaigh, Michael Scott, and Ricardo Dahab
2. Lazy reduction
	- Faster Explicit Formulas for Computing Pairings over Ordinary Curves
	- https://ia.cr/2010/526
	- Diego F. Aranha, Koray Karabina, Patrick Longa, Catherine H. Gebotys, and Julio López
3. Miller loop for fixed Q
	- Fixed point pairings
	- https://ia.cr/2010/342
	- Craig Costello and Douglas Stebila
4. Pairing implementation
    - Realms of pairing
    - https://eprint.iacr.org/2013/722.pdf
    - Diego F. Aranha, Paulo S. L. M. Barreto, Patrick Longa, and Jefferson E. Ricardini
5. Final exponentiation squarings
    - SQUARING IN CYCLOTOMIC SUBGROUPS
    - https://ia.cr/2010/542
    - Koray Karabina
6. Efficient miller loop steps and final exponentiation
	- Pairings in Rank-1 Constraint Systems
	- https://ia.cr/2022/1162
	- Youssef El Housni, École Polytechnique, ConsenSyS R&D


## Residue witness
* On Proving Pairings
  - https://ia.cr/2024/640
  - by Andrija Novakovic (Geometry Research) and Liam Eagen (Alpen Labs, Zeta Function Technologies)

Section 4 Eliminating the Final Exponentiation

Here's a rough outline of what we are implementing from the paper,

Two elements A and B ∈ Fq12 are equivalent if there exists some C such that,

```
x . c ^ r = y
```

Witness `c` allows replacing the whole final exponentiation with just checking for above equivalence.
Exponentiation by `r` can be replaced with `rt` for some `t` which allows embedding the exponentiation into the main miller loop.

For BN254 curve,
Section 4.3 shows we can use,
`λ = 6x + 2 + q − q^2 + q^3` where `λ = 3rm′`

And check,

```
x . c ^ λ = y
```

Exponentiation by `λ` can be broken like this, `6x + 2` + `q` − `q^2` + `q^3`

`6x + 2` can happen within the Miller loop.
And `q` − `q^2` + `q^3` can use Frobenius mappings.

## Extension field operations
* Faster Extension Field multiplications for Emulated Pairing Circuits
  - https://hackmd.io/@feltroidprime/B1eyHHXNT
  - Feltroid Prime (Garaga)

Taking an FQ12 direct extension as a polynomial of degree 11, product of polynomials can be used to verify the committed coefficients with Schwartz Zippel lemma.
As described in https://hackmd.io/@feltroidprime/B1eyHHXNT,
For A and B element of Fq12 represented as direct extensions,
```A(x) * B(x) = R(x) + Q(x) * P12(x)```
where `R(x)` is a polynomial of degree 11 or less.

### Expanding this to include the whole bit operation inside the miller loop,

#### Schwartz Zippel verification for zero `O` bits,
* Commitment contains 64 coefficients
* F ∈ Fq12, miller loop aggregation
* L1_L2 ∈ Sparse01234, Loop step lines L1 and L2 multiplied for lower degree
* L3 ∈ Sparse034, Last L3 line
* ```F(x) * F(x) * L1_L2(x) * L3(x) = R(x) + Q(x) * P12(x)```

#### Schwartz Zippel verification for non-zero `P`/`N` bits,
* Commitment contains 42 coefficients
* F ∈ Fq12, miller loop aggregation
* L1, L2, L3 ∈ Sparse01234, Loop step lines
* Witness ∈ Fq12, Residue witness (or it's inverse based on the bit value)
* ```F(x) * F(x) * L1(x) * L2(x) * L3(x) * Witness(x) = R(x) + Q(x) * P12(x)```

#### Schwartz Zippel verification for miller loop correction step,
* Commitment contains 42 coefficients
* F ∈ Fq12, miller loop aggregation
* L1, L2, L3 ∈ Sparse01234, Correction step lines
* ```F(x) * L1(x) * L2(x) * L3(x) = R(x) + Q(x) * P12(x)```