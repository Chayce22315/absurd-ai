import ActivityKit
import Foundation

struct AgentActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var agentName: String
        var task: String
        var progress: Double
    }
    var agentId: String
}