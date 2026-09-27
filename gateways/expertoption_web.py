from core.models import TradeRequest, TradeResult
from gateways.base import TradingGateway

class ExpertOptionWebGateway(TradingGateway):
    """Non-executing boundary until a supported integration is verified."""
    name = "expertoption-web-unconfigured"

    def health(self) -> bool:
        return False

    def get_balance(self) -> float:
        raise RuntimeError("ExpertOption Web gateway is not configured")

    def place_trade(self, request: TradeRequest) -> TradeResult:
        return TradeResult(accepted=False, reason="live ExpertOption execution is not configured")
