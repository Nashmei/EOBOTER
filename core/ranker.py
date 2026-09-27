from dataclasses import dataclass
from core.models import Signal
@dataclass
class RankedSignal:
    signal: Signal
    score: float
def choose_best(signals):
    rows=[RankedSignal(s, round(s.confidence*100,2)) for s in signals if s]
    return max(rows,key=lambda x:x.score) if rows else None
