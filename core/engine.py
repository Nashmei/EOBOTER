from core.settings import Settings
from gateways.base import TradingGateway
from gateways.demo import DemoGateway


class EOBoterEngine:
    def __init__(self, settings: Settings, gateway: TradingGateway | None = None) -> None:
        self.settings = settings
        self.gateway = gateway or DemoGateway()

    def start(self) -> None:
        print(f"EOBOTER started | mode={self.settings.mode} | gateway={self.gateway.name}")
