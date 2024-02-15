# Cairo BN

## Contents

* Mod arithmetics
* Fq Field element arithmetics
* Fq2 Field extension arithmetics
* Fq6 Field extension arithmetics
* Fq12 Field extension arithmetics
* G1: (x, y) = (Fq, Fq)
* G2: (x, y) = (Fq2, Fq2)
* Pairing: Line functions
* Pairing: Miller loop

## Refrence material

### Point operations
[Pairings for Beginners](https://static1.squarespace.com/static/5fdbb09f31d71c1227082339/t/5ff394720493bd28278889c6/1609798774687/PairingsForBeginners.pdf)

### Field extensions
[Multiplication and Squaring on Pairing-Friendly Fields](https://eprint.iacr.org/2006/471.pdf)

## Todo

We are probably already doing a bunch of these, but room for thought.

* Speeding scalar multiplication
> K.  Eisentrger, K. Lauter  and P. L. Montgomery,  “Fast Elliptic Curve  Arithmetic  and  Improved Weil Pairing Evaluation”, LNCS, Springer, vol. 2612, (2003), pp. 343-354.
* Reducing the loop length in Miller's algorithm
> D.  Lubicz  and  D.  Robert,  “A  generalisation  of  Miller's  algorithm  and  applications  to  pairing computations on abelian varieties”, IACR Cryptology ePrint Archive, (2013), pp. 192.
* Performing the computing over the field Fqk/d instead of the field Fqk using the twists
> C.  Costello,  T.  Lange  and  M.  Naehrig,  “Faster  pairing  computations  on  curves  with  high-degree twists”, In Public Key Cryptography: 13th International Conference on Practice and Theory in Public Key Cryptography, Proceedings, Springer Verlag, Paris, (2010), pp. 224-242.
* Using other variant of Miller's formula
> J.  Boxall,  N.  El  Mrabet,  F.  Laguillaumie  and  P.  Le  Duc,  “A  Variant  of  Miller's  Formula  and Algorithm”, The 4th International Conference on Pairing Based Cryptography, Pairing, (2010).
* Deleting the computing for the denominator
> P. S. L. M. Barreto, H. Y. Kim  and M. Scott, “e_cient algorithms for  pairing based cryptosystems”, CRYPTO, LNCS, Springer, Heidelberg, vol. 2442, (2002), pp. 354-369. 
* Optimisations of Miller's loop
> https://www.researchgate.net/publication/288646605_Optimizing_the_computing_of_pairing_with_Miller's_algorithm
