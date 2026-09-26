import Foundation

struct AgentConfiguration: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var icon: String
    var modelID: String
    var instructions: String
    var isEnabled = true
}

struct OrchestrationSettings: Codable {
    var enabled = false
    var coordinatorModelID = AppSettings.defaultModel
    var agents: [AgentConfiguration] = [
        .init(name:"Code",icon:"chevron.left.forwardslash.chevron.right",modelID:AppSettings.defaultModel,instructions:"You are a senior software engineering agent. Return precise implementation-focused work."),
        .init(name:"Research",icon:"magnifyingglass",modelID:AppSettings.defaultModel,instructions:"You are a research agent. Analyze evidence, uncertainty, and sources supplied in context."),
        .init(name:"Analysis",icon:"chart.xyaxis.line",modelID:AppSettings.defaultModel,instructions:"You are an analytical agent. Break complex problems down and verify assumptions."),
        .init(name:"Writer",icon:"text.quote",modelID:AppSettings.defaultModel,instructions:"You are a writing agent. Produce polished, audience-appropriate text.")
    ]
}

enum OrchestrationStore {
    private static let key="orchestration-settings-v1"
    static func load() -> OrchestrationSettings {
        guard let d=UserDefaults.standard.data(forKey:key),let x=try? JSONDecoder().decode(OrchestrationSettings.self,from:d) else { return .init() }
        return x
    }
    static func save(_ value:OrchestrationSettings) {
        if let d=try? JSONEncoder().encode(value) { UserDefaults.standard.set(d,forKey:key) }
    }
}
