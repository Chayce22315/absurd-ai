import SwiftUI

struct AgentsView: View {
    @EnvironmentObject var state: AppState
    @State private var showCreate: Bool = false
    @State private var showTeam: Bool = false
    @State private var selectedAgent: Agent? = nil
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button("Create Agent") { showCreate = true }.buttonStyle(.borderedProminent)
                        Button("Create Team") { showTeam = true }.buttonStyle(.bordered)
                    }
                    HStack {
                        stat("Total", state.agents.count)
                        stat("Active", state.agents.filter { $0.status == "running" || $0.status == "idle" }.count)
                        stat("Running", state.agents.filter { $0.status == "running" }.count)
                        stat("Done", state.agents.filter { $0.status == "completed" }.count)
                    }
                    VStack(alignment: .leading) {
                        Text("Spawning Mode").font(.headline)
                        Picker("Mode", selection: $state.spawningMode) {
                            Text("Automatic").tag("auto")
                            Text("Manual").tag("manual")
                        }.pickerStyle(.segmented)
                        HStack {
                            Text("Nested limit")
                            Spacer()
                            Stepper("\(state.nestedLimit)", value: $state.nestedLimit, in: 1...10)
                        }
                        Text(state.spawningMode == "auto" ? "Main agent selects specialists, distributes tasks, tracks progress." : "You create agents, assign tasks, choose models, tools, permissions.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    Text("Agents").font(.headline)
                    ForEach(state.agents) { a in
                        VStack(alignment: .leading) {
                            HStack {
                                Circle().fill(color(for: a.status)).frame(width: 8, height: 8)
                                Text(a.name).bold()
                                Text(a.role).font(.caption).padding(4).background(.gray.opacity(0.2)).clipShape(Capsule())
                                if a.nested > 0 { Text("\(a.nested) nested").font(.caption).padding(4).background(.blue.opacity(0.15)).clipShape(Capsule()) }
                                Spacer()
                                Text(a.model).font(.caption).foregroundStyle(.secondary)
                            }
                            Text(a.task).font(.caption).foregroundStyle(.secondary)
                            ProgressView(value: a.progress)
                            Button("Details") { selectedAgent = a }.font(.caption)
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text("Activity Feed").font(.headline)
                    VStack(alignment: .leading) {
                        Text("• Planner-1 spawned Researcher subagent")
                        Text("• Coder-Alpha completed auth screens")
                        Text("• Tester finished unit tests")
                    }.font(.caption).foregroundStyle(.secondary)
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }.padding()
            }
            .navigationTitle("Agent HQ")
            .sheet(isPresented: $showCreate) { AgentCreateView() }
            .sheet(isPresented: $showTeam) { AgentTeamView() }
            .sheet(item: $selectedAgent) { a in AgentDetailView(agent: a) }
        }
    }
    func stat(_ title: String, _ value: Int) -> some View {
        VStack { Text("\(value)").bold(); Text(title).font(.caption).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity).padding(8).background(.gray.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 10))
    }
    func color(for status: String) -> Color {
        switch status { case "running": return .purple; case "completed": return .green; case "error": return .red; default: return .gray }
    }
}

struct AgentDetailView: View {
    @EnvironmentObject var state: AppState
    let agent: Agent
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(agent.name).font(.title2).bold()
                    Text("Role: \(agent.role)")
                    Text("Status: \(agent.status)")
                    Text("Model: \(agent.model)")
                    Text("Task: \(agent.task)")
                    ProgressView(value: agent.progress)
                    Text("Live Activity").font(.headline)
                    Text("• Analyzing task\n• Delegating\n• Collecting results").font(.caption).foregroundStyle(.secondary)
                    Text("Conversation History").font(.headline)
                    Text("Agent messages (simulated).").font(.caption).foregroundStyle(.secondary)
                    HStack {
                        Button("Spawn Subagent") {
                            state.agents.append(Agent(id: "a\(Date().timeIntervalSince1970)", name: "\(agent.name)-sub", role: "researcher", status: "running", task: "Subtask for \(agent.name)", model: agent.model, progress: 0))
                        }.buttonStyle(.borderedProminent)
                        Button("Configure") { }.buttonStyle(.bordered)
                    }
                }.padding()
            }
            .navigationTitle(agent.name)
        }
    }
}

struct AgentCreateView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var role: String = "planner"
    @State private var model: String = "auto"
    @State private var task: String = ""
    @State private var instructions: String = ""
    var body: some View {
        NavigationStack {
            Form {
                TextField("Agent name", text: $name)
                Picker("Role", selection: $role) {
                    ForEach(SampleData.agentRoles, id: \.self) { Text($0) }
                }
                Picker("Model", selection: $model) {
                    ForEach(SampleData.models) { Text($0.name).tag($0.id) }
                }
                TextField("Assigned task", text: $task)
                TextField("Instructions", text: $instructions, axis: .vertical)
                Button("Create Agent") {
                    guard !name.isEmpty else { return }
                    let modelName = SampleData.models.first(where: { $0.id == model })?.name ?? "Auto"
                    state.agents.append(Agent(id: "a\(Date().timeIntervalSince1970)", name: name, role: role, status: "idle", task: task.isEmpty ? "New task" : task, model: modelName, progress: 0))
                    dismiss()
                }.buttonStyle(.borderedProminent)
            }
            .navigationTitle("Create Agent")
        }
    }
}

struct AgentTeamView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name: String = "New Team"
    @State private var selected: Set<String> = ["planner","coder","reviewer"]
    var body: some View {
        NavigationStack {
            Form {
                TextField("Team name", text: $name)
                ForEach(SampleData.agentRoles, id: \.self) { r in
                    Toggle(r, isOn: Binding(get: { selected.contains(r) }, set: { if $0 { selected.insert(r) } else { selected.remove(r) } }))
                }
                Button("Create Team") {
                    for r in selected {
                        state.agents.append(Agent(id: "a\(Date().timeIntervalSince1970)\(r)", name: "\(name)-\(r)", role: r, status: "idle", task: "Team \(name)", model: "Violet-1", progress: 0))
                    }
                    dismiss()
                }.buttonStyle(.borderedProminent)
            }
            .navigationTitle("Create Team")
        }
    }
}

extension SampleData {
    static let agentRoles = ["planner","architect","researcher","designer","coder","debugger","tester","reviewer","optimizer"]
}