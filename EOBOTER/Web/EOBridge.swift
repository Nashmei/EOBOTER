import Foundation
import WebKit

@MainActor
final class EOBridge: NSObject, ObservableObject, WKNavigationDelegate {
    let webView: WKWebView
    @Published var pageReady = false
    @Published var currentURL = ""
    @Published var snapshot = EOMarketSnapshot(asset: "Unknown")

    override init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        webView.navigationDelegate = self
    }

    func loadEO() {
        guard let url = URL(string: "https://expertoption.com/") else { return }
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageReady = true
        currentURL = webView.url?.absoluteString ?? ""
    }

    func readVisibleMarketState() async throws -> EOMarketSnapshot {
        let js = """
        (() => {
          const text = document.body?.innerText || '';
          return JSON.stringify({ title: document.title, text: text.slice(0, 20000) });
        })()
        """
        _ = try await webView.evaluateJavaScript(js)
        return snapshot
    }

    /// Test-only EO UI execution. It only clicks a unique, visible button-like
    /// element whose accessible label/text exactly identifies UP or DOWN.
    func testExecute(direction: TradeDirection) async throws -> String {
        guard direction == .up || direction == .down else {
            throw NSError(domain: "EOBOTER", code: 400, userInfo: [NSLocalizedDescriptionKey: "Test execution requires UP or DOWN"])
        }
        guard pageReady else {
            throw NSError(domain: "EOBOTER", code: 409, userInfo: [NSLocalizedDescriptionKey: "EO page is not ready"])
        }

        let wanted = direction.rawValue
        let js = """
        (() => {
          const wanted = \(String(reflecting: wanted));
          const visible = (el) => {
            const r = el.getBoundingClientRect();
            const s = getComputedStyle(el);
            return r.width > 20 && r.height > 20 &&
                   s.display !== 'none' && s.visibility !== 'hidden' &&
                   Number(s.opacity || 1) > 0;
          };
          const label = (el) => [
            el.innerText,
            el.textContent,
            el.getAttribute('aria-label'),
            el.getAttribute('title'),
            el.getAttribute('data-direction')
          ].filter(Boolean).join(' ').trim().toUpperCase();

          const aliases = wanted === 'UP'
            ? ['UP', 'CALL', 'BUY UP']
            : ['DOWN', 'PUT', 'BUY DOWN'];

          const candidates = Array.from(document.querySelectorAll(
            'button,[role="button"],input[type="button"],input[type="submit"]'
          )).filter(visible).filter(el => {
            const value = label(el);
            return aliases.some(a => value === a || value.split(/\\s+/).includes(a));
          });

          if (candidates.length !== 1) {
            return JSON.stringify({
              ok: false,
              reason: candidates.length === 0 ? 'no_unique_visible_match' : 'ambiguous_match',
              matches: candidates.length
            });
          }

          candidates[0].click();
          return JSON.stringify({ ok: true, direction: wanted });
        })()
        """

        guard let raw = try await webView.evaluateJavaScript(js) as? String,
              let data = raw.data(using: .utf8),
              let result = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "EOBOTER", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid EO execution result"])
        }

        guard result["ok"] as? Bool == true else {
            let reason = result["reason"] as? String ?? "unknown"
            let matches = result["matches"] as? Int ?? 0
            throw NSError(domain: "EOBOTER", code: 422, userInfo: [NSLocalizedDescriptionKey: "EO button not safely identified (\(reason), matches: \(matches))"])
        }
        return "EO \(wanted) click dispatched"
    }
}
