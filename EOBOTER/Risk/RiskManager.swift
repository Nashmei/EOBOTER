import Foundation

struct RiskManager {
    func approve(advice: NVIDIAAdvice, payout: Double?, minimumConfidence: Double = 0.70, minimumPayout: Double = 0.70) -> TradeDecision {
        guard advice.direction != .skip,
              advice.confidence >= minimumConfidence,
              let payout, payout >= minimumPayout else {
            return TradeDecision(direction: .skip, confidence: advice.confidence, reason: "Risk gate rejected signal", expirySeconds: 60)
        }
        return TradeDecision(direction: advice.direction, confidence: advice.confidence, reason: advice.reason, expirySeconds: 60)
    }
}
