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

# precompute r' and m''

r_inv = FQ(1) / FQ(r)
m_d_inv = FQ(1) / FQ(m_dash)

f = tower_to_direct(
    [
        0x1BF4E21820E6CC2B2DBC9453733A8D7C48F05E73F90ECC8BDD80505D2D3B1715,
        0x264F54F6B719920C4AC00AAFB3DF29CC8A9DDC25E264BDEE1ADE5E36077D58D7,
        0xDB269E3CD7ED27D825BCBAAEFB01023CF9B17BEED6092F7B96EAB87B571F3FE,
        0x25CE534442EE86A32C46B56D2BF289A0BE5F8703FB05C260B2CB820F2B253CF,
        0x33FC62C521F4FFDCB362B12220DB6C57F487906C0DAF4DC9BA736F882A420E1,
        0xE8B074995703E92A7B9568C90AE160E4D5B81AFFE628DC1D790241DE43D00D0,
        0x84E35BD0EEA3430B350041D235BB394E338E3A9ED2F0A9A1BA7FE786D391DE1,
        0x244D38253DA236F714CB763ABF68F7829EE631B4CC5EDE89B382E518D676D992,
        0x1EE0A098B62C76A9EBDF4D76C8DFC1586E3FCB6A01712CBDA8D10D07B32C5AF4,
        0xD23AEB23ACACF931F02ECA9ECEEE31EE9607EC003FF934694119A9C6CFFC4BD,
        0x16558217BB9B1BCDA995B123619808719CB8A282A190630E6D06D7D03E6333CA,
        0x14354C051802F8704939C9948EF91D89DB28FE9513AD7BBF58A4639AF347EA86,
    ]
)
f = FQ12(f)
print("")

# print("Should be one", f**h)

unity = FQ12([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
root_of_unity = FQ12([82, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0])
# assert f**h == unity, "f**h should be one"
# root_27th = root_of_unity ** ((q**12 - 1) // 27)
# print(
#     "\n\nroot_27th = \n",
#     root_27th,
#     "\n\n27th_root_to_27 be one\n",
#     root_27th**27,
# )



# Section 4.3.2 Finding c
# find some u a cubic non-residue and c such that f = c**λ * u.

# 1. Compute r-th root
# 2. Compute m′-th root
# 3. Compute cubic root

# Algorithm 5: Algorithm for computing λ residues over BN curve
# Input: Output of a Miller loop f and fixed 27-th root of unity w
# Output: (c, wi) such that c**λ = f · wi
# 1 s = 0
# 2 if f**(q**k−1)/3 = 1 then
# 3 continue
# 4 end
# 5 else if (f · w)**(q**k−1)/3 = 1 then
# 6 s = 1
# 7 f ← f · w
# 8 end
# 9 else
# 10 s = 2
# 11 f ← f · w**2
# 12 end
# 13 c ← f**r′
# 14 c ← c**m′′
# 15 c ← c**1/3 (by using modified Tonelli-Shanks 4)
# 16 return (c, ws)
