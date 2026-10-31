import SwiftUI

struct RemoteView: View {
    @EnvironmentObject var state: AppState
    @State private var pairingState: String = "idle"
    @State private var showSession: Bool = false
    @State private var sessionMode: String = "desktop"
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Circle().fill(state.paired ? .green : .gray).frame(width: 10, height: 10)
                        VStack(alignment: .leading) {
                            Text(state.computers.first?.name ?? "No computer").bold()
                            Text(state.computers.first.map { "\($0.os) · \($0.status)" } ?? "Not connected").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if !state.paired {
                            Button("Add Computer") { startPairing() }.buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .background(.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    if state.paired {
                        HStack {
                            Button("Remote Desktop") { sessionMode = "desktop"; showSession = true }.buttonStyle(.borderedProminent)
                            Button("Developer Control") { sessionMode = "dev"; showSession = true }.buttonStyle(.bordered)
                        }
                        VStack(alignment: .leading) {
                            Text("Permissions").font(.headline)
                            Text("✓ Screen view\n✓ Mouse & keyboard\n✓ Terminal access\n✓ File access").font(.caption).foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading) {
                            Text("Session Controls").font(.headline)
                            HStack {
                                Button("Pause") { }.buttonStyle(.bordered)
                                Button("Disconnect") { state.paired = false }.buttonStyle(.bordered).tint(.red)
                            }
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    if pairingState != "idle" {
                        VStack(spacing: 12) {
                            Text("Status: \(pairingState)")
                            if pairingState == "done" {
                                Button("Continue") { pairingState = "idle" }.buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                        .background(.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }.padding()
            }
            .navigationTitle("Remote Computing")
            .sheet(isPresented: $showSession) { RemoteSessionView(mode: sessionMode) }
        }
    }
    func startPairing() {
        pairingState = "scanning"
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            pairingState = "connecting"
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            state.paired = true
            state.computers = [Computer(id: "pc1", name: "Dev Workstation", os: "Windows 11", status: "connected")]
            pairingState = "done"
        }
    }
}

struct RemoteSessionView: View {
    let mode: String
    @State private var tab: Int = 0
    @State private var cmd: String = ""
    @State private var output: [String] = ["C:\\> "]
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Tab", selection: $tab) {
                    Text("Desktop").tag(0); Text("Terminal").tag(1); Text("Files").tag(2); Text("Apps").tag(3)
                }.pickerStyle(.segmented).padding()
                if tab == 0 {
                    VStack {
                        Text("Live Desktop Preview (simulated)").font(.caption).foregroundStyle(.secondary)
                        Rectangle().fill(.black.opacity(0.3)).frame(height: 200).overlay(Text("Desktop"))
                        HStack {
                            Button("Click") { }
                            Button("Type") { }
                            Button("Scroll") { }
                        }.buttonStyle(.bordered)
                    }
                } else if tab == 1 {
                    VStack {
                        ScrollView { VStack(alignment: .leading) { ForEach(output, id: \.self) { Text($0).font(.system(.caption, design: .monospaced)) } } }
                            .frame(height: 200).background(.black.opacity(0.8)).foregroundStyle(.green)
                        HStack {
                            TextField("Command...", text: $cmd).textFieldStyle(.roundedBorder)
                            Button("Run") {
                                output.append("C:\\> \(cmd)")
                                output.append("Output for \(cmd) (simulated)")
                                cmd = ""
                            }.buttonStyle(.borderedProminent)
                        }
                    }
                } else if tab == 2 {
                    List(["C:\\Users\\Dev\\project","src","README.md","main.py"]) { Text("📁 \($0)") }
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(["VS Code","Terminal","Browser","Explorer","Settings"], id: \.self) { a in
                            Button(a) { }.buttonStyle(.bordered)
                        }
                    }.padding()
                }
            }
            .padding()
            .navigationTitle("Remote Session")
        }
    }
}