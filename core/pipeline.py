from core.ranker import choose_best
from strategies.ema_trend import analyze as ema_trend
from strategies.rsi_reversal import analyze as rsi_reversal
from strategies.momentum import momentum_signal
class SignalPipeline:
    def analyze(self,asset,closes,expiry_seconds=60):
        signals=[momentum_signal(asset,closes,expiry_seconds),ema_trend(asset,closes,expiry_seconds),rsi_reversal(asset,closes,expiry_seconds)]
        return choose_best(signals)
