import json
from pathlib import Path
class TradeStore:
    def __init__(self,path="data/trades.jsonl"): self.path=Path(path)
    def append(self,row):
        self.path.parent.mkdir(parents=True,exist_ok=True)
        with self.path.open("a",encoding="utf-8") as f: f.write(json.dumps(row,ensure_ascii=False,default=str)+"\n")
