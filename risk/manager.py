from dataclasses import dataclass
from core.models import Signal, TradeRequest


@dataclass(frozen=True)
class RiskConfig:
    stake_percent: float = 1.0
    max_stake_percent: float = 2.0
    min_confidence: float = 0.70
    min_payout: float = 0.70
    max_session_loss_percent: float = 5.0


class RiskManager:
    def __init__(self, config: RiskConfig | None = None) -> None:
        self.config = config or RiskConfig()

    def build_trade(self, signal: Signal, balance: float, payout: float) -> TradeRequest | None:
        if balance <= 0:
            return None
        if signal.confidence < self.config.min_confidence:
            return None
        if payout < self.config.min_payout:
            return None
        pct = min(self.config.stake_percent, self.config.max_stake_percent)
        stake = round(balance * (pct / 100.0), 2)
        if stake <= 0:
            return None
        return TradeRequest(
            asset=signal.asset,
            direction=signal.direction,
            stake=stake,
            expiry_seconds=signal.expiry_seconds,
            expected_payout=payout,
        )
