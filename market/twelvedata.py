import json,os,urllib.parse,urllib.request
from market.base import MarketDataGateway
class TwelveDataMarketData(MarketDataGateway):
    BASE="https://api.twelvedata.com/time_series"
    def __init__(self,api_key=None): self.api_key=api_key or os.getenv("TWELVE_DATA_API_KEY","")
    def closes(self,symbol,interval="1min",limit=100):
        if not self.api_key: raise RuntimeError("TWELVE_DATA_API_KEY is not configured")
        q=urllib.parse.urlencode({"symbol":symbol,"interval":interval,"outputsize":limit,"apikey":self.api_key})
        with urllib.request.urlopen(f"{self.BASE}?{q}",timeout=10) as r: data=json.load(r)
        if data.get("status")=="error": raise RuntimeError(data.get("message","Twelve Data error"))
        return [float(x["close"]) for x in reversed(data.get("values",[]))]
