use bn254_u256::{bn254_curve, fq12, fq12_frobenius_map, Bn254U256Curve, FrobFq12};

#[test]
fn frobenius() {
    let mut curve = bn254_curve();
    let map = fq12_frobenius_map();
    let a = fq12(
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
    );
    let b = fq12(
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
    );

    let (fr1, fr2, fr3) = (
        fq12(
            0x5B9A079BC26832A0F6C91A8C3D52F0696E128C4DC02C2E7ECCD6750879DB37F,
            0x20EEF5CC5E42D307E50692C958066CA5A3A8ED6FEE3160F6ABC64438080D40A,
            0x22B901CC05A276A352A5B2E4CDB0801F1090D7C3C00D2AEE133E58FA9A08166F,
            0x21EF1182C5982045BE5086E98B702B8E0A020B05DA08615B4C56898BBE7AD627,
            0x166EAB18F982D529D9716951CA8C8E8CF7B4D6C2A33842B1EFD2E91C51974C9C,
            0x8C971EE7EA3190056BBC580A3E30D71EF9CF0F366E413B66A934308B1886943,
            0x962D2942749B2BEE17E3DD2A4A816798AB7526991EF4468A2D609EFF8E3243E,
            0x1AE755CAD670294BAE38E1E0872ED365362CE44BF436B195C74307B1E70F8EB0,
            0x28686F32DCB94F6A1BEF9B430E2CE391AA94642EF1B5E3E17D9C550BA13CF604,
            0x1FCA3FF372CF4F024EDC0012FE4421C27DE8EA9E57B7B41E56B90F17253042A1,
            0x1FD2DA899094D7186E11DBBCE1945254ACCD99C25A18496E63C82D8575E53835,
            0x10EF17E4EB1A799E6520665B6E568135518530CF27E473403FE4DAE5B3ABB359,
        ),
        fq12(
            0x1BAF2A84EB47CE42094FD98972BC4BB0F2936EF400AEA71EAFF2C663E3A0FC4D,
            0x1386BA1F43D9BFA49764547C97CCE737F86A88B32D9129370BDD1C3AACEAE690,
            0x18DD43EA981DFD93157DBCEEDAF779FE595DC591D7B55399BBC5E47F5774B57A,
            0x1F537ED6F41E14535DBD02F9A5AF0AFC9C78DA96DD0D5D7484B839007937E68,
            0x4BA271695233F366E472A1C648D0510041758D9480D7FE6F6A4E44DF153A37,
            0x1F90E59A7A3D55FE7985237FEE00013683931CD744B16D404B5768484ABA36,
            0x62D7AC8EE4A4E5489932505F2885972FA3FD80858C41DDBE7BCEFD9314FB68D,
            0x20E7B3EC5432216AF93B6D014DECEE713B348509C387B2C5928E23CE9222EF13,
            0x2B341214025B845522176C00365DC13E7DBC5ECD0353014F4A32875061ADA1D0,
            0x1D58A967F3CF6D852FF56C9797E30DE26B7404AC75A2F23F590187CD2B77333D,
            0x1F3E350F37FAAABA1D67362947B40D26255F0E14B41CFE18990D23ED58B27918,
            0xCA343F03A5AAD483087E7C6F5826CB3E93CF2D4C93DA1A9C833CABFDB03D201,
        ),
        fq12(
            0x5B9A079BC26832A0F6C91A8C3D52F0696E128C4DC02C2E7ECCD6750879DB37F,
            0x20EEF5CC5E42D307E50692C958066CA5A3A8ED6FEE3160F6ABC64438080D40A,
            0x2EFA89E47856A8F39D582FDE1312FF29A7AAE4AD63655041E01CF6D457345DEB,
            0x19CF56ADBFF74C0AD339512436BC207ADBE3B43F6CE4EF20576B1D0850ACDCF8,
            0x1D3542951E75687996BD1D838717C3CB9691CB50E26751389E7BA1FF5EF22C5A,
            0x20D75AA79FEBE682EF974AE30FC5549BA7C2F59ED89BF28421C1419E1776E408,
            0x2E8AF76D1B428356E369E25853B8DE1BB216E0D36375AD58B7BDB88E309DFEEA,
            0x24D25C217E024DBDA4702D65A478A50E480D73C92B391C6584715863E7F043D4,
            0x7FBDF40047850BF9C60AA73735474CBECED066276BBE6ABBE84370B37400743,
            0x109A0E7F6E625127697445A3833D369B19987FF310BA166EE5677CFFB34CBAA6,
            0x38804B1BD6745B6A9D6C78C0C99126A0ED3A44EBD22083E6C7EA8A5C05A0127,
            0x88A86135288468A418988363D1908045E6E8F5B15068DA601BA68E41384F5F2,
        ),
    );
    assert(fr1 == curve.frob1(a, @map), '');
    assert(fr2 == curve.frob2(b, @map), '');
    assert(fr3 == curve.frob3(a, @map), '');
}
