import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var input: String = ""
    @Published var isStreaming: Bool = false
    @Published var errorMessage: String?

    private var client: OpenAICompatibleClient?
    private var streamTask: Task<Void, Never>?

    func configure(baseURL: String, apiKey: String?) {
        client = OpenAICompatibleClient(baseURL: baseURL, apiKey: apiKey)
    }

    func send(state: AppState) {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        messages.append(Message(role: "user", text: text))
        startStream(state: state, prompt: nil)
    }

    func regenerate(state: AppState) {
        if let idx = messages.lastIndex(where: { $0.role == "assistant" }) {
            messages.remove(at: idx)
        }
        startStream(state: state, prompt: nil)
    }

    private func startStream(state: AppState, prompt: String?) {
        guard let client else { errorMessage = "Provider not configured"; return }
        isStreaming = true
        errorMessage = nil
        messages.append(Message(role: "assistant", text: ""))
        let idx = messages.count - 1
        let chatMessages = messages.dropLast().map { ChatMessage(role: $0.role, content: $0.text) }
        streamTask = Task {
            do {
                let stream = client.streamChat(messages: chatMessages, model: state.selectedModel)
                for try await token in stream {
                    messages[idx].text += token
                }
                isStreaming = false
            } catch {
                errorMessage = error.localizedDescription
                isStreaming = false
            }
        }
    }

    func cancel() {
        streamTask?.cancel()
        isStreaming = false
    }
}