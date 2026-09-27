import Foundation

final class NVIDIAClient {
    private let endpoint = URL(string: "https://integrate.api.nvidia.com/v1/chat/completions")!

    func analyze(snapshot: EOMarketSnapshot, model: String) async throws -> NVIDIAAdvice {
        guard let key = KeychainStore.read(account: "NVIDIA_API_KEY"), !key.isEmpty else {
            throw NSError(domain: "EOBOTER", code: 401, userInfo: [NSLocalizedDescriptionKey: "NVIDIA API key is not configured"])
        }

        let system = "You are a bounded market-analysis component. Return JSON only with direction UP, DOWN, or SKIP; confidence 0...1; and a concise reason. Never invent missing market data."
        let user = "Asset: \(snapshot.asset); price: \(snapshot.visiblePrice.map(String.init) ?? "missing"); payout: \(snapshot.payoutPercent.map(String.init) ?? "missing"); expiry: \(snapshot.expirySeconds.map(String.init) ?? "missing")."

        let payload: [String: Any] = [
            "model": model,
            "temperature": 0.1,
            "max_tokens": 180,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ]
        ]
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw NSError(domain: "EOBOTER", code: 502, userInfo: [NSLocalizedDescriptionKey: "NVIDIA request failed"])
        }
        let root = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = root?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        guard let content = message?["content"] as? String,
              let json = content.data(using: .utf8) else {
            throw NSError(domain: "EOBOTER", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid NVIDIA response"])
        }
        return try JSONDecoder().decode(NVIDIAAdvice.self, from: json)
    }
}
