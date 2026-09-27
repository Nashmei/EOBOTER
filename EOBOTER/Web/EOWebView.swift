import SwiftUI
import WebKit

struct EOWebView: UIViewRepresentable {
    @ObservedObject var bridge: EOBridge
    func makeUIView(context: Context) -> WKWebView {
        bridge.loadEO()
        return bridge.webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
