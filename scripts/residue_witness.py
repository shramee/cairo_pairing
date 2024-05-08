# This script follows paper 'On Proving Pairings' - https://eprint.iacr.org/2024/640
# to generate residue witness for the final exponentiation.
from py_ecc import bn128, fields
from py_ecc.bn128 import bn128_curve;
from py_ecc.fields import (
    bn128_FQ as FQ,
    bn128_FQ2 as FQ2,
    bn128_FQ12 as FQ12,
)

# Section 4.3 Computing Residue Witness for the BN254 curve

# bn254 curve properties from https://hackmd.io/@jpw/bn254
q = 21888242871839275222246405745257275088696311157297823662689037894645226208583
x = 4965661367192848881
r = 21888242871839275222246405745257275088548364400416034343698204186575808495617
# (q**12 - 1) is the exponent of the final exponentiation

# Section 4.3.1 Parameters
h = (q**12 - 1) // r # = 3^3 · l # where gcd(l, 3) = 1
l = h // (3**3)
λ = 6*x + 2 + q - q**2 + q**3
m = λ // r
d = 3 # = gcd(m, h)
m_dash = m // d # m' = m/d

# λ = 3rm′.
assert( 3*r*m_dash == λ, "incorrect parameters")

