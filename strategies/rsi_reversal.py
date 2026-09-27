from core.indicators import rsi
from core.models import Direction,Signal
def analyze(asset,closes,expiry_seconds=60):
    x=rsi(closes)
    if x is None or 35<=x<=65: return None
    direction=Direction.UP if x<35 else Direction.DOWN
    confidence=min(.90,.70+abs(x-(35 if x<35 else 65))/100)
    return Signal(asset=asset,direction=direction,confidence=confidence,expiry_seconds=expiry_seconds,reason=f"RSI {x:.1f}")
