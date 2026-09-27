from abc import ABC, abstractmethod


class TradingGateway(ABC):
    name = "base"

    @abstractmethod
    def health(self) -> bool:
        raise NotImplementedError
