import Foundation

struct ChatMessage: Codable {
    let role: String
    let content: String
}

enum AIError: Error, LocalizedError {
    case invalidURL
    case httpError(Int)
    case decodingError
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpError(let code): return "HTTP error \(code)"
        case .decodingError: return "Decoding error"
        case .noData: return "No data"
        }
    }
}

final class OpenAICompatibleClient {
    let baseURL: String
    let apiKey: String?

    init(baseURL: String, apiKey: String?) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.apiKey = apiKey
    }

    func fetchModels() async throws -> [AIModel] {
        guard let url = URL(string: "\(baseURL)/models") else { throw AIError.invalidURL }
        var request = URLRequest(url: url)
        if let key = apiKey, !key.isEmpty {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        struct ModelsResponse: Codable {
            struct Model: Codable {
                let id: String
                let owned_by: String?
            }
            let data: [Model]
        }
        let decoded = try JSONDecoder().decode(ModelsResponse.self, from: data)
        return decoded.data.map { m in
            AIModel(id: m.id, name: m.id, provider: "Remote", desc: "Fetched model", caps: [], free: true)
        }
    }

    func streamChat(messages: [ChatMessage], model: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = URL(string: "\(baseURL)/chat/completions") else {
                        throw AIError.invalidURL
                    }
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    if let key = apiKey, !key.isEmpty {
                        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
                    }
                    let body: [String: Any] = [
                        "model": model,
                        "messages": messages.map { ["role": $0.role, "content": $0.content] },
                        "stream": true
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                        throw AIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
                    }
                    for try await line in bytes.lines {
                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.hasPrefix("data:") else { continue }
                        let payload = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
                        if payload == "[DONE]" { break }
                        guard let data = payload.data(using: .utf8) else { continue }
                        struct Chunk: Codable {
                            struct Choice: Codable {
                                struct Delta: Codable { let content: String? }
                                let delta: Delta
                            }
                            let choices: [Choice]
                        }
                        if let chunk = try? JSONDecoder().decode(Chunk.self, from: data),
                           let content = chunk.choices.first?.delta.content {
                            continuation.yield(content)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}