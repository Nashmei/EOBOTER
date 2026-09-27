import SwiftUI

struct LogsView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        NavigationStack {
            List(model.logs, id: \.self) { Text($0).font(.caption.monospaced()) }
                .navigationTitle("Logs")
        }
    }
}
