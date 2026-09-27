import Foundation

protocol ExecutionGateway {
    func execute(_ decision: TradeDecision) async throws
}

/// Safe default. Real EO UI execution remains disabled until the on-device
/// page structure and allowed interaction path are explicitly verified.
struct DisabledEOExecutionGateway: ExecutionGateway {
    func execute(_ decision: TradeDecision) async throws {
        throw NSError(domain: "EOBOTER", code: 403, userInfo: [NSLocalizedDescriptionKey: "EO automatic execution is not enabled"])
    }
}
