import Foundation

enum UnitKind: String, CaseIterable, Codable, Identifiable {
    case vanguard = "Vanguard"
    case ranger = "Ranger"
    case striker = "Striker"
    case guardian = "Guardian"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .vanguard: return "shield.lefthalf.filled"
        case .ranger: return "scope"
        case .striker: return "bolt.fill"
        case .guardian: return "shield.fill"
        }
    }
    var basePower: Int {
        switch self {
        case .vanguard: return 24
        case .ranger: return 20
        case .striker: return 29
        case .guardian: return 17
        }
    }
}

struct BattleUnit: Identifiable, Codable, Hashable {
    let id: UUID
    var kind: UnitKind
    var health: Int
    var maxHealth: Int
    var lane: Int

    init(kind: UnitKind, lane: Int) {
        id = UUID()
        self.kind = kind
        health = 100
        maxHealth = 100
        self.lane = lane
    }

    var alive: Bool { health > 0 }
}

enum Tactic: String, CaseIterable, Codable, Identifiable {
    case balanced = "Balanced"
    case assault = "Assault"
    case defend = "Defend"
    case flank = "Flank"
    case ambush = "Ambush"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .balanced: return "circle.grid.cross"
        case .assault: return "flame.fill"
        case .defend: return "shield.fill"
        case .flank: return "arrow.turn.up.right"
        case .ambush: return "eye.slash.fill"
        }
    }
}

struct TacticalPlan: Codable, Hashable {
    var tactic: Tactic
    var focusLane: Int
    var aggression: Double
    var holdPosition: Bool
    var summary: String

    static let balanced = TacticalPlan(
        tactic: .balanced, focusLane: 1, aggression: 0.55,
        holdPosition: false, summary: "Balanced pressure across the arena."
    )
}

struct BattleEvent: Identifiable, Hashable {
    let id = UUID()
    let round: Int
    let text: String
    let isPositive: Bool
}

enum BattlePhase: Equatable {
    case briefing, planning, resolving, victory, defeat
}

struct PlayerProgress: Codable {
    var level = 1
    var xp = 0
    var wins = 0
    var losses = 0
    var rating = 1000
    var credits = 500

    mutating func record(win: Bool) {
        if win {
            wins += 1; xp += 120; rating += 24; credits += 90
        } else {
            losses += 1; xp += 45; rating = max(0, rating - 14); credits += 25
        }
        level = max(1, 1 + xp / 500)
    }
}
