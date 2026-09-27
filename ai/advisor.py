from dataclasses import dataclass
from core.models import Signal
@dataclass
class AIAdvice:
    action: str
    confidence: float
    reason: str
class AIAdvisor:
    """Optional bounded advisor. It never executes trades."""
    def review(self, signal: Signal) -> AIAdvice:
        return AIAdvice(action="accept",confidence=signal.confidence,reason="AI provider not configured; deterministic signal retained")
