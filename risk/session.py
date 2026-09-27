from dataclasses import dataclass
@dataclass
class SessionRisk:
    start_balance: float
    pnl: float=0.0
    trades: int=0
    consecutive_losses: int=0
    def record(self,profit):
        self.pnl+=profit; self.trades+=1
        self.consecutive_losses=0 if profit>0 else self.consecutive_losses+1
    def loss_percent(self):
        return max(0.0,-self.pnl/self.start_balance*100) if self.start_balance>0 else 100.0
