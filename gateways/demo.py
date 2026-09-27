from uuid import uuid4
from core.models import TradeRequest, TradeResult
from gateways.base import TradingGateway

class DemoGateway(TradingGateway):
    name = "demo"

    def __init__(self, balance: float = 10_000.0) -> None:
        self._balance = balance

    def health(self) -> bool:
        return True

    def get_balance(self) -> float:
        return self._balance

    def place_trade(self, request: TradeRequest) -> TradeResult:
        if request.stake > self._balance:
            return TradeResult(accepted=False, reason="insufficient demo balance")
        self._balance = round(self._balance - request.stake, 2)
        return TradeResult(accepted=True, trade_id=f"demo-{uuid4().hex[:12]}")
