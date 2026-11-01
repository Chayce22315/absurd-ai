import Foundation

struct ProviderConfig: Codable, Identifiable {
    let id: String
    var name: String
    var baseURL: String
    var requiresKey: Bool
    var models: [AIModel]
    var selectedModel: String?
    var isFree: Bool { !requiresKey }
}

enum AIProviderPreset: String, CaseIterable {
    case absurd
    case ollama
    case custom

    var displayName: String {
        switch self {
        case .absurd: return "ABSURD"
        case .ollama: return "Ollama"
        case .custom: return "Custom"
        }
    }

    var defaultBaseURL: String {
        switch self {
        case .absurd: return "https://absurd.ai.free_server_hoster"
        case .ollama: return "http://localhost:11434/v1"
        case .custom: return "https://api.openai.com/v1"
        }
    }

    var requiresKey: Bool {
        switch self {
        case .absurd: return false
        case .ollama: return false
        case .custom: return true
        }
    }
}