import SwiftUI

struct BotView: View {
    @EnvironmentObject var model: AppModel
    @State private var executingTest = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Engine") {
                    Toggle("Bot enabled", isOn: $model.botEnabled)
                    LabeledContent("Asset", value: model.selectedAsset)
                    LabeledContent("Status", value: model.status)
                }

                Section("EO execution test") {
                    Text("Uses the currently open EO page. The test only clicks when exactly one visible UP/DOWN control is identified.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Button("Test UP") { runExecutionTest(.up) }
                            .buttonStyle(.borderedProminent)
                            .disabled(executingTest || !model.web.pageReady)

                        Button("Test DOWN") { runExecutionTest(.down) }
                            .buttonStyle(.bordered)
                            .disabled(executingTest || !model.web.pageReady)
                    }
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
            }
            .navigationTitle("EOBOTER")
        }
    }

    private func runExecutionTest(_ direction: TradeDirection) {
        executingTest = true
        model.status = "Testing EO \(direction.rawValue)…"
        Task {
            do {
                let message = try await model.web.testExecute(direction: direction)
                model.status = message
                model.log(message)
            } catch {
                let message = "EO test failed: \(error.localizedDescription)"
                model.status = message
                model.log(message)
            }
            executingTest = false
        }
    }
}
