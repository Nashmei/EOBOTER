import json,urllib.parse,urllib.request
from market.base import MarketDataGateway
class BinanceMarketData(MarketDataGateway):
    BASE="https://api.binance.com/api/v3/klines"
    def closes(self,symbol,interval="1m",limit=100):
        q=urllib.parse.urlencode({"symbol":symbol.upper(),"interval":interval,"limit":max(20,min(limit,1000))})
        req=urllib.request.Request(f"{self.BASE}?{q}",headers={"User-Agent":"EOBOTER/1.0"})
        with urllib.request.urlopen(req,timeout=10) as r: rows=json.load(r)
        return [float(x[4]) for x in rows]
