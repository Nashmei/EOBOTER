import SwiftUI

struct SettingsView: View {
    @State private var apiKey = ""
    @State private var model = "nvidia/nemotron-3-super-120b-a12b"
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Form {
                Section("NVIDIA NIM") {
                    SecureField("API key", text: $apiKey)
                    TextField("Model", text: $model)
                    Button("Save API key to Keychain") {
                        do { try KeychainStore.save(apiKey, account: "NVIDIA_API_KEY"); apiKey = ""; saved = true }
                        catch { saved = false }
                    }
                    if saved { Text("Saved on this iPhone").foregroundStyle(.secondary) }
                }
                Section("Security") {
                    Text("Secrets are stored in iOS Keychain and are never committed to GitHub.")
                }
            }.navigationTitle("Settings")
        }
    }
}
