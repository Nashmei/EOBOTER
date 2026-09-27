import argparse,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from core.engine import EOBoterEngine
from core.settings import Settings
from market.binance import BinanceMarketData
from market.twelvedata import TwelveDataMarketData

def main():
    p=argparse.ArgumentParser(); p.add_argument("symbol"); p.add_argument("--source",choices=["binance","twelve"],default="binance"); p.add_argument("--interval",default=None); p.add_argument("--limit",type=int,default=100); p.add_argument("--expiry",type=int,default=60); p.add_argument("--payout",type=float,default=.80); a=p.parse_args()
    market=BinanceMarketData() if a.source=="binance" else TwelveDataMarketData()
    interval=a.interval or ("1m" if a.source=="binance" else "1min")
    closes=market.closes(a.symbol,interval,a.limit)
    result=EOBoterEngine(Settings()).analyze(a.symbol,closes,a.payout,a.expiry)
    print(result if result else "SKIP")

if __name__=="__main__": main()
