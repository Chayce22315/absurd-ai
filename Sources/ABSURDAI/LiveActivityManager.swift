import ActivityKit
import Foundation

@available(iOS 16.1, *)
enum LiveActivityManager {
    static func start(agent: Agent) {
        let attributes = AgentActivityAttributes(agentId: agent.id)
        let state = AgentActivityAttributes.ContentState(agentName: agent.name, task: agent.task, progress: agent.progress)
        do {
            _ = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil), pushType: nil)
        } catch {
            print("Failed to start live activity: \(error)")
        }
    }

    static func update(agent: Agent) {
        Task {
            for activity in Activity<AgentActivityAttributes>.activities {
                let state = AgentActivityAttributes.ContentState(agentName: agent.name, task: agent.task, progress: agent.progress)
                await activity.update(.init(state: state, staleDate: nil))
            }
        }
    }

    static func end() {
        Task {
            for activity in Activity<AgentActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}