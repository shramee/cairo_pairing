# This script follows paper 'On Proving Pairings' - https://eprint.iacr.org/2024/640
# to generate residue witness for the final exponentiation.

# From 2.1 Eliminating the Final Exponentiation,
# Two elements x, y ∈ F are equivalent if there exists some c such that  x * c**r = y
# Our optimization avoids this cost by instead providing c as auxiliary input and
# directly checking xcr = y. In this way we replace an exponentiation by (q**k − 1)/r
# with an exponentiation by r, which in general is much cheaper.


# from py_ecc import bn128, fields
# from py_ecc.bn128 import bn128_curve;
from py_ecc.fields import (
    bn128_FQ as FQ,
    bn128_FQ12 as FQ12,
)


# The library we use here, py_ecc uses direct field extensions
# But Cairo implementation uses tower field extensions
# Utils for direct extension and tower extension conversions
# https://gist.github.com/feltroidprime/bd31ab8e0cbc0bf8cd952c8b8ed55bf5
def tower_to_direct(x: list):
    p = q
    res = 12 * [0]
    res[0] = (x[0] - 9 * x[1]) % p
    res[1] = (x[6] - 9 * x[7]) % p
    res[2] = (x[2] - 9 * x[3]) % p
    res[3] = (x[8] - 9 * x[9]) % p
    res[4] = (x[4] - 9 * x[5]) % p
    res[5] = (x[10] - 9 * x[11]) % p
    res[6] = x[1]
    res[7] = x[7]
    res[8] = x[3]
    res[9] = x[9]
    res[10] = x[5]
    res[11] = x[11]
    return res


def direct_to_tower(x: list):
    res = 12 * [0]
    res[0] = (x[0] + 9 * x[6]) % p
    res[1] = x[6]
    res[2] = (x[2] + 9 * x[8]) % p
    res[3] = x[8]
    res[4] = (x[4] + 9 * x[10]) % p
    res[5] = x[10]
    res[6] = (x[1] + 9 * x[7]) % p
    res[7] = x[7]
    res[8] = (x[3] + 9 * x[9]) % p
    res[9] = x[9]
    res[10] = (x[5] + 9 * x[11]) % p
    res[11] = x[11]
    return res


# Section 4.3 Computing Residue Witness for the BN254 curve

# bn254 curve properties from https://hackmd.io/@jpw/bn254
q = 21888242871839275222246405745257275088696311157297823662689037894645226208583
x = 4965661367192848881
r = 21888242871839275222246405745257275088548364400416034343698204186575808495617
# (q**12 - 1) is the exponent of the final exponentiation

# Section 4.3.1 Parameters
h = (q**12 - 1) // r  # = 3^3 · l # where gcd(l, 3) = 1
l = h // (3**3)
λ = 6 * x + 2 + q - q**2 + q**3
m = λ // r
d = 3  # = gcd(m, h)
m_dash = m // d  # m' = m/d

# equivalently, λ = 3rm′.
assert 3 * r * m_dash == λ, "incorrect parameters"  # sanity check



