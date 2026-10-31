import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var query: String = ""
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("ABSURD AI").font(.caption).foregroundStyle(.secondary)
                            Text("Good evening, Operator").font(.title2).bold()
                            Text(Date().formatted(date: .complete, time: .omitted)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Circle().fill(.purple.opacity(0.3)).frame(width: 36, height: 36).overlay(Text("A").foregroundStyle(.purple))
                    }
                    HStack {
                        TextField("Ask ABSURD AI anything...", text: $query).textFieldStyle(.roundedBorder)
                        Button("Send") {
                            if !query.isEmpty {
                                path.append("chat")
                                query = ""
                            }
                        }.buttonStyle(.borderedProminent)
                    }
                    Text("Quick Actions").font(.headline)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                        QuickAction(icon: "message", label: "Chat") { path.append("chat") }
                        QuickAction(icon: "hammer", label: "Create") { path.append("create") }
                        QuickAction(icon: "cpu", label: "Agent") { path.append("agents") }
                        QuickAction(icon: "desktopcomputer", label: "Connect") { path.append("remote") }
                        QuickAction(icon: "bolt", label: "Automate") { path.append("automation") }
                    }
                    if let m = SampleData.models.first(where: { $0.id == state.selectedModel }) {
                        VStack(alignment: .leading) {
                            Text("Model").font(.headline)
                            HStack {
                                Circle().fill(.green).frame(width: 8, height: 8)
                                VStack(alignment: .leading) {
                                    Text(m.name).bold()
                                    Text(m.desc).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(m.auto ? "Auto" : "Manual").font(.caption).padding(6).background(.purple.opacity(0.2)).clipShape(Capsule())
                            }
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text("Recent Conversations").font(.headline)
                    ForEach(state.conversations.prefix(3)) { c in
                        VStack(alignment: .leading) {
                            Text(c.title).font(.subheadline).bold()
                            Text(c.preview).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text("Recent Projects").font(.headline)
                    ForEach(state.projects) { p in
                        VStack(alignment: .leading) {
                            HStack { Text(p.name).bold(); Spacer(); Text("\(Int(p.progress*100))%").font(.caption) }
                            ProgressView(value: p.progress)
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text("Agent Activity").font(.headline)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Total \(state.agents.count)")
                            Spacer()
                            Text("Active \(state.agents.filter { $0.status == "running" || $0.status == "idle" }.count)")
                            Spacer()
                            Text("Done \(state.agents.filter { $0.status == "completed" }.count)")
                        }.font(.caption)
                        ForEach(state.agents.filter { $0.status == "running" }) { a in
                            HStack {
                                Circle().fill(.purple).frame(width: 6, height: 6)
                                Text("\(a.name) · \(a.task)").font(.caption)
                                Spacer()
                                Text("\(Int(a.progress*100))%").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    Text("Connected Computer").font(.headline)
                    HStack {
                        Circle().fill(state.paired ? .green : .gray).frame(width: 8, height: 8)
                        VStack(alignment: .leading) {
                            Text(state.computers.first?.name ?? "None").bold()
                            Text(state.computers.first.map { "\($0.os) · \($0.status)" } ?? "Not connected").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(state.paired ? "Open" : "Connect") { path.append("remote") }.buttonStyle(.bordered)
                    }
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Home")
            .navigationDestination(for: String.self) { value in
                // @ViewBuilder
                switch value {
                case "chat": ChatView()
                case "create": CreateView()
                case "agents": AgentsView()
                case "remote": RemoteView()
                case "automation": AutomationView()
                case "models": ModelsView()
                default: EmptyView()
                }
            }
        }
    }
}

struct QuickAction: View {
    let icon: String
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                Text(label).font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}