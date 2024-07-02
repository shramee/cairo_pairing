import galois

# Define the prime number q
field = 21888242871839275222246405745257275088696311157297823662689037894645226208583

r = 21888242871839275222246405745257275088548364400416034343698204186575808495617
FQ = galois.GF(field)

# Define the polynomial P
P12 = galois.Poly([1, 0, 0, 0, 0, 0, -18, 0, 0, 0, 0, 0, 82], field=FQ)


def tower_to_direct(x: list):
    p = field
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
    n = 12
    fill = [0] * n
    if len(x) < 12:
        x = x + fill[len(x) :]
    p = field
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


def mul_qr(*polynomials):
    # Compute the product of all input polynomials
    product = polynomials[0]
    for poly in polynomials[1:]:
        product *= poly
    # Perform polynomial division of product by P
    Q, R = divmod(product, P12)
    return Q, R


def poly(*coefficients) -> galois.Poly:
    return galois.Poly(coefficients, order="asc", field=FQ)


def fq12(*coefficients) -> galois.Poly:
    return poly(*tower_to_direct(coefficients))


def f034(a1, a2, b1, b2) -> galois.Poly:
    return fq12(1, 0, 0, 0, 0, 0, a1, a2, b1, b2, 0, 0)


def f01234(*coefficients) -> galois.Poly:
    assert len(coefficients) == 10
    return fq12(*coefficients, 0, 0)


def to_tower(f: galois.Poly):
    return direct_to_tower([int(c) for c in f.coefficients(order="asc")])


def evaluate_poly(f: galois.Poly, x: int, field=field):
    coeffs = [int(c) for c in f.coefficients(order="asc")]
    sum = coeffs[0]
    term_x_pow = x
    for element in coeffs[1:]:
        if isinstance(element, int):
            sum = (sum + term_x_pow * element) % field
            term_x_pow = (term_x_pow * x) % field
    return sum


def print_poly_tower(name: str, f: galois.Poly):
    fq_hex = [hex(c) for c in to_tower(f)]
    print("\n{} fq12(\n\t{}\n)\n".format(name, ",\n\t".join(fq_hex)))


def print_poly(name: str, f: galois.Poly, compress: bool = False):
    fq_hex = [hex(int(c)) for c in f.coefficients(order="asc")]
    coeffs_glue = ",\n\t\t"
    if compress:
        coeffs_glue = ", "
    print(
        "\n{} Polynomial{{\n\tdegree: {},\n\tcoefficients: array![\n\t\t{}\n], }}\n".format(
            name, len(fq_hex), coeffs_glue.join(fq_hex)
        )
    )


def test_case(name: str, qr: tuple[galois.Poly, galois.Poly]):
    (q, r) = qr
    print(
        "----------------",
        name,
        "--",
        len(q.coefficients()) + len(r.coefficients()),
        "coeffs ---",
    )
    print_poly("quotient =", q, True)
    print_poly("result =", r, True)
    print("//--------------", name, "//\n\n")


def test_mul(name: str, qr: tuple[galois.Poly, galois.Poly], expected: galois.Poly):
    (q, r) = qr
    assert r == expected, "incorrect " + name + " result"
    print("correct " + name + " result")
    # print_poly_tower("----------- " + name + " -- " + str( len(q.coefficients()) + len(r.coefficients()) ) + " coeffs\n", r)
    # print("//--------------", name, "//\n\n")


# Schwartz Zippel steps


def schzip_op(*polynomials, acc: list):
    (q, r) = mul_qr(*polynomials)
    # qc = [hex(int(coeff)) for coeff in q.coefficients(order="asc")]
    # rc = [hex(int(coeff)) for coeff in r.coefficients(order="asc")]
    qc = [int(coeff) for coeff in q.coefficients(order="asc")]
    rc = [int(coeff) for coeff in r.coefficients(order="asc")]
    acc.extend(rc)
    acc.extend(qc)
    return q, r


all_coeffs = []


# f12: Fq12 sqr multiplied with lines l1_2: F01234 and l_3: F034
def sz_zero_bit(f12, l1_2, l3):
    return schzip_op(f12, f12, l1_2, l3, acc=all_coeffs)


# f12: Fq12 sqr multiplied with lines l1, l2, l3: F01234
def sz_nz_bit(f12, l1, l2, l3, witness):
    return schzip_op(f12, f12, l1, l2, l3, witness, acc=all_coeffs)


# f12 multiplied with lines l1, l2, l3: F01234
def sz_last_step(f12, l1, l2, l3):
    return schzip_op(f12, l1, l2, l3, acc=all_coeffs)


def sz_post_miller(f12, l1, l2, l3):
    return sz_last_step(f12, l1, l2, l3)


def sz_residue_inv_verify(f12, f12_inv):
    return sz_last_step(f12, f12_inv)


def sz_print_coeffs():
    print("\n\t" + ",\n\t".join(all_coeffs))


if __name__ == "__main__":
    # Define the polynomials
    last_len = len(all_coeffs)
    sz_zero_bit(
        fq12(
            0x5B9A079BC26832A0F6C91A8C3D52F0696E128C4DC02C2E7ECCD6750879DB37F,
            0x2E555F161B4D72F939FFDC89EC00F1933D46DBBA698EB47DD16427D357FC293D,
            0x1B137F9BF629C0DBCDD8087034E1F3557CE533998E4E2566B9961515FE3E8874,
            0x9D878A403981D9DC63F4987D88DF92F797412464F26753411B8E7500D316487,
            0x14E05EB80B6F7E23ECFA04A410CFA1CF8036F3161C7D586802B485FBA82FA9E9,
            0x35039DC8C011DB7EB2C0E91709001BA13C91C6B2A06F5ED32005C4990ED64CB,
            0xB67955A9EED460C7FE5F21790CB806E1A6FAA832E5ED9751F4C769B94F233D4,
            0x1A87D2B49B7FE718A8AAED495061C6C7AB0F83010AA102BADCE3B5F057717586,
            0x1426DBE6A25C91A8D3AC59A34C4EA7D7E0075EF206A5DD08A33D1998B58651C1,
            0x27ACB2E47242C471014D129C1A37D0FB662480C13480796CDC381735384A6C5A,
            0x7459382FD7B5F159E32AE6EB1F5A1AC9ADDE6E0E347011855CC9F8B5BC89021,
            0x2884F79CD78DBEF6B64FD2A8AF7ABBB9CB36D280C0C63074E74F0287D3B2EB2D,
        ),
        f01234(
            0x93B29143F057F125C8B5E8D11986A4EC5C7CFEAC89B8580AE9A9D5830A19D4C,
            0x516B755FE3311C2B90AFCFCD0AB1FACB18C3CC8CDD0DDBFD6A2E685D16682F1,
            0x2E473DDCCED3F5A780549F16B4A7CB4652E9C772ED985C0A32118E83DE37389E,
            0x118CAFDEBCD59151735610932C49F81451723124F3523811E7641958D79007A,
            0x825DC9BF97BF4E6BFB4C02AFC096E5103490AFDE25B7278DFF3518AC1E0CDD0,
            0x2D46D338E907A3D3000BD23703B22114DAC7DCF262F53E65BBB9EC6D9538183D,
            0x18D61A2D2F1463E84E308689805E18E35B683FF6B590E69412A01FBD32E0C059,
            0x202944D77C6438D408678579A5A20FF5747F9EE8810FDF22C22B54B4B6487B10,
            0x1E323BC97AAE1789EF90B65D67DFA09EB495D53664A1E36B777AF4F53FFBED22,
            0x11F0E69D23129D28D5B870DB1751D6D8210ED4F05C5C4DE29C53F05D97E92A6C,
        ),
        f034(
            0x17B07937DB1F72B2B29E2DCF434668F0E938DBE0119C93EA7D4F109C1A0F45C4,
            0x25B8FA21453F00D01133A94A381FA8E2E438E5E4B6581DE60BD897964B732ECE,
            0x262FA9C6CF2C4599A834A0AB9941F0B3CD2FF6AC62B560E9D26033B238E10BA7,
            0x8D5574056E7E5A2567BE6A4004C39ABEF57222DDD94DF6BF514B8FD81AA0440,
        ),
    )
    print("sz_zero_bit", len(all_coeffs) - last_len)
    sz_z_f = all_coeffs[::12]
    print("\n  " + "\n  ".join(sz_z_f))

    last_len = len(all_coeffs)
    sz_nz_bit(
        fq12(
            0x17B6F07867B2D8811B94054CB20E02D69E8696FBD8DFC30FC4DCC16AC3582B2B,
            0x1AD3085832F02DB30DAD3A38CF967C8948FABF90895BF5D0A407D0AA584BD32E,
            0xD2CAA0C3E9B8D955D6724E67DBAA7E9AB77879B818540303A5A5111C84D37E3,
            0x566102CDB5869B6F0B0C3342806346613FAC9CCE8B781A7307CDB9E672F312A,
            0xDD420D0FA4C4D927384E73BA7EE4A1B29ED49093C7EC79F97D82AF03C4BEF19,
            0x11A1A49C01D86EEAB6189B48BFBD9D9265E6A00C3C426FBCD88394692CBBB70C,
            0x27EAB2E8253C9DC314236D5CCE23FB4432CA392392996634F4BBA295475D0E41,
            0x7A161D713740C29CB8751DFDB0356B683840F804C630E626286C406E7FDCF3D,
            0x1DEFEA8B95AC737E4CD6B7DFBF81FA06BDFE78FA9D0F81310ADDE1230219DAC6,
            0x83A69098DE2B18EED6BD8EACBE4643EF5992E7C106E160425BE05E9D27C91E5,
            0x27A45554C37CDA23DB4D69FA803E87E97DFF43000C1C3142E2900EC51F71191F,
            0x2281F657560C385B4B012BC66C195B4EE12E7EAD34AF187701A56A60B1810BDE,
        ),
        f01234(
            0x222A977AA4FFA65D9C2EBC4A5FE2570A728EE4F9449F646813B7BE7D98C84DA2,
            0x1326C02005E2C7B7B0FBCA21A8CBA9D9B16CE7BF5E81D95CA2876F14049AB725,
            0x2BF3C77FCE69A8D248404B54D89B009E21E3121811D9F5EBFB4F17BCF35A7C,
            0x2F42EB9A435788F1E15C33CD75F178E59523F83CB7AA2C5579FDF489B8A67123,
            0x167A0706B99282449F6A66682740EBD01753ACC06BA06872CE823A70F6887EDF,
            0xCECF82AB7D6C7C0298CEB4F604AB94E210A40642D9C97A990377946A6C9275E,
            0x2519D8C37853E243809F854B29498B50CCB2F980393E0A950FB1CBF28FAD8069,
            0x70B275B879A44AB0632A2E013E4D0B546BB7B69B2642824DEEB07E675B2F00A,
            0x19EE31E0524CF51959A5DEFD812C2AAFBDBAE4B77266BACC6303EB16B64F2442,
            0x265A6DE3A0CBDF0DA331D43A013FBCB13E4E941769F2A8A1B8854588329549E8,
        ),
        f01234(
            0x4E5B09D9F4292665E16176AA067E2AC6314F5EE79AE6980E2EDCC951148CC0C,
            0xC27543DEBAC89C088F304429D31120D4B6BBC864390DFDBD50CCF4A3770661,
            0x14CF9ECB7A77BD64B08034EE2D3E616C572CFDEB0E1DE220AF8A0F92C31F3494,
            0x334D335A567E7CDED065DB12B5F45C705EE0D5F9184FEFBEE4F921E1AF668CB,
            0x2826A23E0B1CAC698575D38F2A1D79E6C500762A65615FEB0D041FEE6AA429DD,
            0x18F7727B98A1F6C8CD46B748FDBD69037E93B2DD49777A0260802E1563DF9C17,
            0x1ED91C464D54BFBC17E6680B057B7428BD9027FD1C98A5B113D347126E7B0C45,
            0x2839CE5EB72DF677A6E93C6CE86FFAE65272EE60D408562A03BCB6DB931B2DC3,
            0x23BBBD1F71FA0168651C042AD0074DDC2C398B44B80A3BCCF4EA902CBBC4D76F,
            0x1F43F6A87F038259260C4CBC14BF83675D973601C00507E37B283ECDF2F45F91,
        ),
        f01234(
            0x2084A503B31430C051A6B15C6979941A555AA90918120C701C2242594BE11763,
            0x48FBFF86C4C40B20CD67E253DABF168B96DB7C2DD401779F46964C720F6CFA3,
            0x1393A3287B1E7ED23EF75FE9D4ED92BFEB1746AFC652C476B53A4E09F8F533,
            0x1F001533923D64935DB3C6B2614A670BB5F9AAAA20E3C278A7663227B81F7599,
            0x27C02BF0115CAAAC8757CC7A2AF350F61C0D2E4042AD96E710FF278A3DF1EB2E,
            0x19C2F0012E9756C8FD43E14CEE1EFFF2B7E4C1E62AB267285422ABC3166FBBDC,
            0x1049D88F2A5D7476D01AF11A564D04F5F48EC9D3A4DE84701EFE36D1933A0897,
            0x2327863ACF38241771E114E5C1A0053815F974AE5F37432A32E7ED82950F6A89,
            0x22CCEAC6484622E8F8572901926BF3DD343AB0C09EC2BB913F28F86F014CE60B,
            0xAE45A230BE8239F4C73DACAD60F20CC3D099EA2A8FCB4E2042F0B16AE926580,
        ),
        fq12(
            0x1BAF2A84EB47CE42094FD98972BC4BB0F2936EF400AEA71EAFF2C663E3A0FC4D,
            0x1386BA1F43D9BFA49764547C97CCE737F86A88B32D9129370BDD1C3AACEAE690,
            0x19CA8ADFE0165968C479453CEAC5D78D54BEEC199FD30AF10476E46A7DA56127,
            0x8C68AD81FEFA3678A4C488228F6EC2E68FAB44F5FC386A71EDF490D13165BAF,
            0xAA529AD6ED3D0A32AA2ABD113EF97605F58EEA5ACE47A9A946899FAEFCB3895,
            0x1EEED7320D8C8646893377A138B1A265F171E37E7F73A58C52D4EC94E6BC0529,
            0x1E46A4AB1EFE63CC304F321E79B74B5E52728DF2FC3F3043DCDFCF9F816C568C,
            0x2C12B2472CFFC96EF1CD313AEAE8462296F4AD7B8E6B06073C97B7F0EBF0AD31,
            0x5303C5EDED61BD49638D9B64B23971F19C50BC4651EC93DF1EE04C676CF5B77,
            0x130BA50AED6232A4885AD91EE99E4A7B2C0D65E4F2CED84DE31F0449AD05CA0A,
            0xA5AEC882CA48F7ED31209C6EA95B0CD055CBD8C184715CE59C40CCF95C566CD,
            0x40837988D67F97256BB7E5E121802B523F460B3713E079588A5FF10659CFE2D,
        ),
    )
    print("sz_nz_bit", len(all_coeffs) - last_len)
