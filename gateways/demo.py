from gateways.base import TradingGateway


class DemoGateway(TradingGateway):
    name = "demo"

    def health(self) -> bool:
        return True
