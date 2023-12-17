import test



def test_calc_entropy():
    assert test.calc_entropy(0,0,4,4) == 2
    assert test.calc_entropy(1,0,4,4) == 3
    assert test.calc_entropy(3,3,4,4) == 2
    assert test.calc_entropy(0,3,4,4) == 2
    assert test.calc_entropy(3,0,4,4) == 2
    assert test.calc_entropy(2,2,4,4) == 4





