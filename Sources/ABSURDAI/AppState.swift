import SwiftUI

final class AppState: ObservableObject {
    @Published var selectedModel: String = "auto"
    @Published var agents: [Agent] = SampleData.agents
    @Published var projects: [Project] = SampleData.projects
    @Published var conversations: [Conversation] = SampleData.conversations
    @Published var computers: [Computer] = SampleData.computers
    @Published var automations: [Automation] = SampleData.automations
    @Published var paired: Bool = false
    @Published var spawningMode: String = "auto"
    @Published var nestedLimit: Int = 3
}