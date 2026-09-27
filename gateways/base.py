from abc import ABC, abstractmethod
from core.models import TradeRequest, TradeResult

class TradingGateway(ABC):
    name = "base"

    @abstractmethod
    def health(self) -> bool:
        raise NotImplementedError

    @abstractmethod
    def get_balance(self) -> float:
        raise NotImplementedError

    @abstractmethod
    def place_trade(self, request: TradeRequest) -> TradeResult:
        raise NotImplementedError
