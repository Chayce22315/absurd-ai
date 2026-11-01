import Foundation

struct AIModel: Identifiable, Codable {
    let id: String
    let name: String
    let provider: String
    let desc: String
    let caps: [String]
    var recent: Bool = false
    var auto: Bool = false
    var free: Bool = false
    var contextWindow: Int? = nil
}

struct Conversation: Identifiable {
    let id: String
    var title: String
    var preview: String
    var time: String
    var model: String
    var messages: [Message]
}

struct Message: Identifiable {
    let id: UUID = UUID()
    var role: String
    var text: String
}

struct Project: Identifiable {
    let id: String
    var name: String
    var category: String
    var updated: String
    var progress: Double
    var files: Int
}

struct Agent: Identifiable {
    let id: String
    var name: String
    var role: String
    var status: String
    var task: String
    var model: String
    var progress: Double
    var nested: Int = 0
}

struct Computer: Identifiable {
    let id: String
    var name: String
    var os: String
    var status: String
}

struct Automation: Identifiable {
    let id: String
    var name: String
    var enabled: Bool
    var trigger: String
    var steps: [String]
    var runs: Int
}

enum SampleData {
    static let models: [AIModel] = [
        AIModel(id: "auto", name: "Auto", provider: "ABSURD", desc: "Automatically selects the best model.", caps: ["routing","planning"], recent: true, auto: true),
        AIModel(id: "violet-1", name: "Violet-1", provider: "ABSURD", desc: "Flagship reasoning model.", caps: ["reasoning","code","vision"], recent: true),
        AIModel(id: "gpt-x", name: "GPT-X", provider: "OpenAI-like", desc: "General purpose chat and code.", caps: ["chat","code"], recent: true),
        AIModel(id: "claude-ish", name: "Claude-ish", provider: "Anthropic-like", desc: "Long context analysis.", caps: ["analysis","writing"]),
    ]
    static let conversations: [Conversation] = [
        Conversation(id: "c1", title: "Design a productivity app", preview: "Component breakdown...", time: "2m ago", model: "Violet-1", messages: [
            Message(role: "user", text: "Design a productivity app for iOS."),
            Message(role: "assistant", text: "Use a tab-based layout with Today, Tasks, Projects, Settings.")
        ])
    ]
    static let projects: [Project] = [
        Project(id: "p1", name: "AbsurdTodo iOS", category: "iOS applications", updated: "3h ago", progress: 0.62, files: 48)
    ]
    static let agents: [Agent] = [
        Agent(id: "a1", name: "Planner-1", role: "planner", status: "running", task: "Break down app feature set", model: "Violet-1", progress: 0.45, nested: 2),
        Agent(id: "a2", name: "Coder-Alpha", role: "coder", status: "running", task: "Implement auth screens", model: "GPT-X", progress: 0.70)
    ]
    static let computers: [Computer] = [
        Computer(id: "pc1", name: "Dev Workstation", os: "Windows 11", status: "connected")
    ]
    static let automations: [Automation] = [
        Automation(id: "w1", name: "Build & Test Pipeline", enabled: true, trigger: "On commit", steps: ["receive task","research","plan","create","test","report"], runs: 12)
    ]
}