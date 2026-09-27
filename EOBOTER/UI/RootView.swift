import SwiftUI

struct RootView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        TabView {
            TradingView().tabItem { Label("EO", systemImage: "chart.xyaxis.line") }
            BotView().tabItem { Label("Bot", systemImage: "cpu") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
            LogsView().tabItem { Label("Logs", systemImage: "list.bullet.rectangle") }
        }
    }
}
