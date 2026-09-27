import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var botEnabled = false
    @Published var selectedAsset = "Smarty"
    @Published var expirySeconds = 60
    @Published var stakePercent = 1.0
    @Published var maxSessionLossPercent = 5.0
    @Published var lastDecision: TradeDecision?
    @Published var status = "Ready"
    @Published var logs: [String] = []

    let web = EOBridge()
    let nvidia = NVIDIAClient()
    let risk = RiskManager()

    func log(_ text: String) {
        logs.insert("[\(Date().formatted(date: .omitted, time: .standard))] \(text)", at: 0)
        logs = Array(logs.prefix(200))
    }
}
