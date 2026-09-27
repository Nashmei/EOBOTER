from unittest.mock import patch
from market.binance import BinanceMarketData
def test_binance_parser():
    class R:
        def __enter__(self): return self
        def __exit__(self,*a): pass
        def read(self): return b'[[0,"1","2","0.5","1.5"],[1,"1.5","2","1","1.8"]]'
    with patch("urllib.request.urlopen",return_value=R()):
        assert BinanceMarketData().closes("BTCUSDT",limit=20)==[1.5,1.8]
