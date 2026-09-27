from core.indicators import rsi,ema
def test_indicators():
    v=[float(i) for i in range(1,31)]
    assert ema(v,5) is not None
    assert rsi(v)==100.0
