import SwiftUI

final class AppState: ObservableObject {
    @Published var selectedModel: String {
        didSet { UserDefaults.standard.set(selectedModel, forKey: "selectedModel") }
    }
    @Published var agents: [Agent]
    @Published var projects: [Project]
    @Published var conversations: [Conversation]
    @Published var computers: [Computer]
    @Published var automations: [Automation]
    @Published var paired: Bool {
        didSet { UserDefaults.standard.set(paired, forKey: "paired") }
    }
    @Published var spawningMode: String {
        didSet { UserDefaults.standard.set(spawningMode, forKey: "spawningMode") }
    }
    @Published var nestedLimit: Int {
        didSet { UserDefaults.standard.set(nestedLimit, forKey: "nestedLimit") }
    }
    @Published var darkMode: Bool {
        didSet { UserDefaults.standard.set(darkMode, forKey: "darkMode") }
    }

    init() {
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? "auto"
        self.agents = SampleData.agents
        self.projects = SampleData.projects
        self.conversations = SampleData.conversations
        self.computers = SampleData.computers
        self.automations = SampleData.automations
        self.paired = UserDefaults.standard.bool(forKey: "paired")
        self.spawningMode = UserDefaults.standard.string(forKey: "spawningMode") ?? "auto"
        let nl = UserDefaults.standard.integer(forKey: "nestedLimit")
        self.nestedLimit = nl == 0 ? 3 : nl
        self.darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? true
    }
}