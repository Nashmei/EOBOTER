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

    /// Reads only text already rendered in the user's EO page.
    /// Selectors are deliberately not hard-coded until verified on-device.
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
}
