import SwiftUI

struct AutomationView: View {
    @EnvironmentObject var state: AppState
    @State private var building: Bool = false
    @State private var history: [String] = ["Build & Test Pipeline — success (2m ago)"]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Automation Lab").font(.title2).bold()
                        Spacer()
                        Button(building ? "Close Builder" : "New Workflow") { building.toggle() }.buttonStyle(.borderedProminent)
                    }
                    if building {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Workflow Builder").font(.headline)
                            Text("Trigger → Actions → Conditions").font(.caption).foregroundStyle(.secondary)
                            HStack {
                                ForEach(["Trigger","Research","Plan","Create","Test","Report"], id: \.self) { Text($0).font(.caption).padding(6).background(.gray.opacity(0.2)).clipShape(Capsule()) }
                            }
                            Button("Save Workflow") {
                                state.automations.insert(Automation(id: "w\(Date().timeIntervalSince1970)", name: "New Workflow", enabled: true, trigger: "Manual", steps: ["receive task","research","plan","create","test","report"], runs: 0), at: 0)
                                building = false
                            }.buttonStyle(.bordered)
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text("Automations").font(.headline)
                    ForEach(state.automations) { a in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(a.name).bold()
                                Spacer()
                                Toggle("", isOn: Binding(get: { a.enabled }, set: { v in
                                    if let idx = state.automations.firstIndex(where: { $0.id == a.id }) { state.automations[idx].enabled = v }
                                })).labelsHidden()
                            }
                            Text("Trigger: \(a.trigger) · Runs: \(a.runs)").font(.caption).foregroundStyle(.secondary)
                            HStack { ForEach(a.steps, id: \.self) { Text($0).font(.caption2).padding(4).background(.gray.opacity(0.2)).clipShape(Capsule()) } }
                            HStack {
                                Button("Run Now") { history.insert("\(a.name) — success (now)", at: 0) }.buttonStyle(.bordered)
                                Button("History") { }.buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text("Execution History").font(.headline)
                    VStack(alignment: .leading) {
                        ForEach(history, id: \.self) { Text("• \($0)") }
                    }.font(.caption).foregroundStyle(.secondary)
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }.padding()
            }
            .navigationTitle("Automation")
        }
    }
}