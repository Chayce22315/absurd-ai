import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @State private var darkMode: Bool = true
    @State private var selected: String? = nil
    let sections = ["Account","Appearance","Model Providers","API Connections","Agent Preferences","Subagent Spawning Limits","Permissions","Remote Computing","Notifications","Storage","About ABSURD AI"]
    var body: some View {
        NavigationStack {
            List(sections, id: \.self) { s in
                NavigationLink(s) { detail(s) }
            }
            .navigationTitle("Settings")
        }
    }
    func detail(_ title: String) -> some View {
        Form {
            if title == "Appearance" {
                Toggle("Dark mode", isOn: $darkMode)
            } else if title == "Subagent Spawning Limits" {
                Picker("Mode", selection: $state.spawningMode) {
                    Text("Automatic").tag("auto"); Text("Manual").tag("manual")
                }
                Stepper("Nested limit: \(state.nestedLimit)", value: $state.nestedLimit, in: 1...10)
            } else if title == "Model Providers" {
                ForEach(["ABSURD","OpenAI-like","Anthropic-like"], id: \.self) { p in Toggle(p, isOn: .constant(true)) }
            } else if title == "API Connections" {
                SecureField("API key", text: .constant(""))
                Button("Save") { }
            } else if title == "About ABSURD AI" {
                Text("ABSURD AI v0.1 prototype. Multi-model, modular, polyglot backend.")
            } else {
                Text("Configure \(title) here (simulated).")
            }
            Button("Save Changes") { }
        }
        .navigationTitle(title)
    }
}