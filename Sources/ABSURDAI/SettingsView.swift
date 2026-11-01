import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @State private var darkMode: Bool = true
    @State private var apiKeyInput: String = ""
    @State private var testStatus: String = ""
    @State private var isTesting: Bool = false
    let sections = ["Account","Appearance","Model Providers","API Connections","Agent Preferences","Subagent Spawning Limits","Permissions","Remote Computing","Notifications","Storage","About ABSURDAI"]

    var body: some View {
        NavigationStack {
            List(sections, id: \.self) { s in
                NavigationLink(s) { detail(s) }
            }
            .navigationTitle("Settings")
        }
    }

    @ViewBuilder func detail(_ title: String) -> some View {
        Form {
            if title == "Appearance" {
                Toggle("Dark mode", isOn: $state.darkMode)
            } else if title == "Model Providers" || title == "API Connections" {
                Picker("Provider", selection: $state.providerPresetRaw) {
                    ForEach(AIProviderPreset.allCases, id: \.rawValue) { p in
                        Text(p.displayName).tag(p.rawValue)
                    }
                }
                .onChange(of: state.providerPresetRaw) { _, _ in
                    state.providerBaseURL = state.providerPreset.defaultBaseURL
                }
                TextField("Base URL", text: $state.providerBaseURL)
                    .autocapitalization(.none)
                if state.providerPreset.requiresKey || true {
                    SecureField("API key (optional)", text: $apiKeyInput)
                        .onAppear { apiKeyInput = state.apiKey ?? "" }
                        .onChange(of: apiKeyInput) { _, newValue in
                            state.apiKey = newValue.isEmpty ? nil : newValue
                        }
                }
                Button(isTesting ? "Testing..." : "Test Connection") {
                    testConnection()
                }
                if !testStatus.isEmpty {
                    Text(testStatus).font(.caption).foregroundStyle(testStatus.contains("Success") ? .green : .red)
                }
            } else if title == "Subagent Spawning Limits" {
                Picker("Mode", selection: $state.spawningMode) {
                    Text("Automatic").tag("auto"); Text("Manual").tag("manual")
                }
                Stepper("Nested limit: \(state.nestedLimit)", value: $state.nestedLimit, in: 1...10)
            } else if title == "About ABSURD AI" {
                Text("ABSURD AI v0.1 prototype. Multi-model, modular, polyglot backend.")
            } else {
                Text("Configure \(title) here (simulated).")
            }
            Button("Save Changes") { }
        }
        .navigationTitle(title)
    }

    func testConnection() {
        isTesting = true
        testStatus = ""
        Task {
            let client = OpenAICompatibleClient(baseURL: state.providerBaseURL, apiKey: state.apiKey)
            do {
                let models = try await client.fetchModels()
                await MainActor.run {
                    state.providerModels = models
                    testStatus = "Success: \(models.count) models"
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testStatus = "Failed: \(error.localizedDescription)"
                    isTesting = false
                }
            }
        }
    }
}