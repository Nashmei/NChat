import Foundation

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case campaign = "Campaign"
    case skirmish = "Skirmish"
    case blitz = "Blitz"
    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .campaign: return "Progress through increasingly difficult AI sectors."
        case .skirmish: return "Classic offline battle against the tactical AI."
        case .blitz: return "Fast offline rounds with rapid energy recovery."
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

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "System"
    case english = "English"
    case arabic = "العربية"
    var id: String { rawValue }
}
