import Foundation

enum TradeDirection: String, Codable, CaseIterable { case up = "UP", down = "DOWN", skip = "SKIP" }

struct EOMarketSnapshot: Codable {
    var asset: String
    var visiblePrice: Double?
    var payoutPercent: Double?
    var expirySeconds: Int?
    var capturedAt = Date()
}

struct TradeDecision: Codable {
    var direction: TradeDirection
    var confidence: Double
    var reason: String
    var expirySeconds: Int
}

struct NVIDIAAdvice: Codable {
    var direction: TradeDirection
    var confidence: Double
    var reason: String
}
