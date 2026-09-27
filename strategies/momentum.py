from core.models import Direction, Signal


def momentum_signal(asset: str, closes: list[float], expiry_seconds: int = 60) -> Signal | None:
    if len(closes) < 6:
        return None
    recent = closes[-6:]
    deltas = [b - a for a, b in zip(recent, recent[1:])]
    positive = sum(d > 0 for d in deltas)
    negative = sum(d < 0 for d in deltas)
    if positive == negative:
        return None
    direction = Direction.UP if positive > negative else Direction.DOWN
    confidence = max(positive, negative) / len(deltas)
    return Signal(
        asset=asset,
        direction=direction,
        confidence=confidence,
        expiry_seconds=expiry_seconds,
        reason="short-window momentum",
    )
