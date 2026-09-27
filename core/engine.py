from ai.advisor import AIAdvisor
from core.pipeline import SignalPipeline
from gateways.demo import DemoGateway
from risk.manager import RiskManager
from storage.audit import AuditLog

class EOBoterEngine:
    def __init__(self,settings,gateway=None):
        self.settings=settings; self.gateway=gateway or DemoGateway()
        self.pipeline=SignalPipeline(); self.risk=RiskManager(); self.ai=AIAdvisor(); self.audit=AuditLog()
    def start(self):
        print(f"EOBOTER mode={self.settings.mode} gateway={self.gateway.name} healthy={self.gateway.health()}")
    def analyze(self,asset,closes,payout=.80,expiry_seconds=60):
        ranked=self.pipeline.analyze(asset,closes,expiry_seconds)
        if not ranked: return None
        advice=self.ai.review(ranked.signal)
        trade=self.risk.build_trade(ranked.signal,self.gateway.get_balance(),payout)
        result={"signal":ranked.signal.model_dump(mode="json"),"score":ranked.score,"ai":advice.__dict__,"trade":trade.model_dump(mode="json") if trade else None}
        self.audit.write("decision",result); return result
