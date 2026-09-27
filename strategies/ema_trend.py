from core.indicators import ema
from core.models import Direction,Signal
def analyze(asset,closes,expiry_seconds=60):
    fast,slow=ema(closes,5),ema(closes,13)
    if fast is None or slow is None or slow==0: return None
    gap=abs(fast-slow)/abs(slow)
    if gap<0.00005: return None
    return Signal(asset=asset,direction=Direction.UP if fast>slow else Direction.DOWN,confidence=min(.90,.70+gap*100),expiry_seconds=expiry_seconds,reason="EMA 5/13 trend")
