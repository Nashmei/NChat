import Foundation

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case training = "Training"
    case ranked = "Ranked"
    case blitz = "Blitz"
    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .training: return "Practice tactics without rating pressure."
        case .ranked: return "Competitive command battle."
        case .blitz: return "Fast rounds with aggressive energy recovery."
        }
    }
}

struct DailyMission: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let target: Int
    var progress: Int
    let reward: Int
    var completed: Bool { progress >= target }

    static let defaults = [
        DailyMission(id: "battle3", title: "Complete 3 battles", target: 3, progress: 0, reward: 120),
        DailyMission(id: "win1", title: "Win a battle", target: 1, progress: 0, reward: 180),
        DailyMission(id: "flank2", title: "Use Flank twice", target: 2, progress: 0, reward: 90)
    ]
}

struct LeaderboardEntry: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let rating: Int
    let wins: Int
    let isPlayer: Bool
}

struct Loadout: Codable, Hashable {
    var name = "Alpha"
    var units: [UnitKind] = [.vanguard, .ranger, .guardian, .striker]
}

struct MatchmakingState: Equatable {
    var searching = false
    var elapsed = 0
    var region = "Auto"
    var estimatedPing = 0
}

struct OnlineConfiguration: Codable {
    var backendURL = ""
    var playerToken = ""
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "System"
    case english = "English"
    case arabic = "العربية"
    var id: String { rawValue }
}
