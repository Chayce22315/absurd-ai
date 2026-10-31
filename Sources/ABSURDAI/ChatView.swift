import SwiftUI
import UIKit

struct ChatView: View {
    @EnvironmentObject var state: AppState
    @State private var messages: [Message] = []
    @State private var input: String = ""
    @State private var isStreaming: Bool = false
    @State private var showHistory: Bool = false
    @State private var showModel: Bool = false
    var selectedModelName: String {
        SampleData.models.first(where: { $0.id == state.selectedModel })?.name ?? "Auto"
    }
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button("←") { }.buttonStyle(.plain)
                    Spacer()
                    Button(selectedModelName + " ▾") { showModel = true }.buttonStyle(.plain).foregroundStyle(.purple)
                    Spacer()
                    Button("History") { showHistory = true }.buttonStyle(.plain)
                    Button("New") { messages = [] }.buttonStyle(.plain)
                }.padding(.horizontal)
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if messages.isEmpty {
                            Text("Start a conversation.").foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.top, 80)
                        }
                        ForEach(messages) { m in
                            HStack {
                                if m.role == "user" { Spacer() }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(m.text)
                                    if m.role == "assistant" && !isStreaming {
                                        HStack(spacing: 12) {
                                            Button("Copy") { UIPasteboard.general.string = m.text }
                                            Button("Regenerate") { regenerate() }
                                            Button("Branch") { branch() }
                                        }.font(.caption2).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(10)
                                .background(m.role == "user" ? Color.purple : Color.gray.opacity(0.2))
                                .foregroundStyle(m.role == "user" ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                if m.role != "user" { Spacer() }
                            }
                        }
                    }.padding()
                }
                HStack {
                    Button("📎") { }.buttonStyle(.plain)
                    Button("🎤") { }.buttonStyle(.plain)
                    TextField("Message...", text: $input).textFieldStyle(.roundedBorder)
                    Button("Send") { send() }.buttonStyle(.borderedProminent)
                }.padding()
            }
            .navigationTitle("Chat")
            .sheet(isPresented: $showHistory) {
                List(state.conversations) { c in
                    Button(c.title) { messages = c.messages; showHistory = false }
                }
            }
            .sheet(isPresented: $showModel) {
                ModelsView()
            }
        }
    }
    func send() {
        let text = input
        guard !text.isEmpty else { return }
        input = ""
        messages.append(Message(role: "user", text: text))
        Task {
            isStreaming = true
            try? await Task.sleep(nanoseconds: 600_000_000)
            messages.append(Message(role: "assistant", text: "Here is a simulated response from \(selectedModelName)."))
            isStreaming = false
        }
    }
    func regenerate() {
        if let idx = messages.lastIndex(where: { $0.role == "assistant" }) {
            messages.remove(at: idx)
        }
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            messages.append(Message(role: "assistant", text: "Regenerated response with alternative emphasis."))
        }
    }
    func branch() {
        state.conversations.append(Conversation(id: "c\(Date().timeIntervalSince1970)", title: "Branched conversation", preview: "Branch...", time: "now", model: selectedModelName, messages: messages))
    }
}