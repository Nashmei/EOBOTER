import SwiftUI

struct BotView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        NavigationStack {
            Form {
                Section("Engine") {
                    Toggle("Bot enabled", isOn: $model.botEnabled)
                    LabeledContent("Asset", value: model.selectedAsset)
                    LabeledContent("Status", value: model.status)
                }
                Section("Risk") {
                    HStack { Text("Stake %"); Spacer(); Text(model.stakePercent, format: .number.precision(.fractionLength(1))) }
                    HStack { Text("Max session loss %"); Spacer(); Text(model.maxSessionLossPercent, format: .number.precision(.fractionLength(1))) }
                }
                if let d = model.lastDecision {
                    Section("Last decision") {
                        LabeledContent("Direction", value: d.direction.rawValue)
                        LabeledContent("Confidence", value: d.confidence, format: .percent)
                        Text(d.reason)
                    }
                }
            }.navigationTitle("EOBOTER")
        }
    }
}
