import SwiftUI

struct TradingView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        NavigationStack {
            EOWebView(bridge: model.web)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("EO")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
