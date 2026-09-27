from core.models import Direction, Signal
from risk.manager import RiskManager

def test_risk_manager_builds_one_percent_demo_trade() -> None:
    signal = Signal(asset="TEST", direction=Direction.UP, confidence=0.8, expiry_seconds=60)
    trade = RiskManager().build_trade(signal, balance=10_000, payout=0.8)
    assert trade is not None
    assert trade.stake == 100.0

def test_risk_manager_rejects_low_confidence() -> None:
    signal = Signal(asset="TEST", direction=Direction.DOWN, confidence=0.5, expiry_seconds=60)
    assert RiskManager().build_trade(signal, balance=10_000, payout=0.8) is None
