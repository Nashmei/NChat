import Foundation
import Combine

@MainActor
final class GameStore: ObservableObject {
    @Published var phase: BattlePhase = .briefing
    @Published var round = 1
    @Published var playerCore = 100
    @Published var enemyCore = 100
    @Published var energy = 100
    @Published var command = ""
    @Published var playerPlan = TacticalPlan.balanced
    @Published var enemyPlan = TacticalPlan.balanced
    @Published var playerUnits: [BattleUnit] = []
    @Published var enemyUnits: [BattleUnit] = []
    @Published var events: [BattleEvent] = []
    @Published var progress = PlayerProgress()
    @Published var isAIEnabled = false
    @Published var proxyURL = ""
    @Published var statusMessage = "Ready"

    private let progressKey = "promptwars.progress"

    init() {
        loadProgress()
        resetBattle()
    }

    func resetBattle() {
        phase = .briefing
        round = 1
        playerCore = 100
        enemyCore = 100
        energy = 100
        command = ""
        events = []
        playerPlan = .balanced
        enemyPlan = .balanced
        playerUnits = [
            BattleUnit(kind: .vanguard, lane: 0),
            BattleUnit(kind: .ranger, lane: 1),
            BattleUnit(kind: .guardian, lane: 1),
            BattleUnit(kind: .striker, lane: 2)
        ]
        enemyUnits = [
            BattleUnit(kind: .guardian, lane: 0),
            BattleUnit(kind: .ranger, lane: 1),
            BattleUnit(kind: .vanguard, lane: 1),
            BattleUnit(kind: .striker, lane: 2)
        ]
        statusMessage = "Arena ready"
    }

    func startBattle() {
        phase = .planning
        events.append(BattleEvent(round: 0, text: "Battle link established. Issue your first command.", isPositive: true))
    }

    func applyPreset(_ tactic: Tactic) {
        playerPlan.tactic = tactic
        playerPlan.aggression = tactic == .assault ? 0.9 : tactic == .defend ? 0.3 : 0.6
        playerPlan.holdPosition = tactic == .defend || tactic == .ambush
        playerPlan.summary = tactic.rawValue
    }

    func interpretLocally(_ text: String) -> TacticalPlan {
        let value = text.lowercased()
        var plan = playerPlan
        if value.contains("هجوم") || value.contains("attack") || value.contains("اندفع") { plan.tactic = .assault; plan.aggression = 0.9 }
        if value.contains("دفاع") || value.contains("defend") || value.contains("تراجع") { plan.tactic = .defend; plan.aggression = 0.3; plan.holdPosition = true }
        if value.contains("يمين") || value.contains("right") { plan.tactic = .flank; plan.focusLane = 2 }
        if value.contains("يسار") || value.contains("left") { plan.tactic = .flank; plan.focusLane = 0 }
        if value.contains("كمين") || value.contains("ambush") { plan.tactic = .ambush; plan.holdPosition = true }
        plan.summary = text.isEmpty ? plan.tactic.rawValue : text
        return plan
    }

    func executeCommand() async {
        guard phase == .planning, energy >= 20 else { return }
        phase = .resolving
        energy -= 20

        if isAIEnabled, let url = URL(string: proxyURL), !command.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                playerPlan = try await TacticalAIService.interpret(command: command, endpoint: url)
                statusMessage = "AI plan accepted"
            } catch {
                playerPlan = interpretLocally(command)
                statusMessage = "AI unavailable — local tactics used"
            }
        } else {
            playerPlan = interpretLocally(command)
        }

        enemyPlan = makeEnemyPlan()
        resolveRound()
        command = ""
        try? await Task.sleep(for: .milliseconds(650))

        if playerCore <= 0 {
            finish(win: false)
        } else if enemyCore <= 0 {
            finish(win: true)
        } else {
            round += 1
            energy = min(100, energy + 35)
            phase = .planning
        }
    }

    private func makeEnemyPlan() -> TacticalPlan {
        let tactic: Tactic
        if playerCore < 35 { tactic = .assault }
        else if enemyCore < 40 { tactic = .defend }
        else { tactic = Tactic.allCases.randomElement() ?? .balanced }
        return TacticalPlan(tactic: tactic, focusLane: Int.random(in: 0...2), aggression: tactic == .assault ? 0.85 : 0.55, holdPosition: tactic == .defend, summary: "Enemy (tactic.rawValue)")
    }

    private func resolveRound() {
        let playerScore = combatScore(plan: playerPlan, units: playerUnits)
        let enemyScore = combatScore(plan: enemyPlan, units: enemyUnits)
        let advantage = matchup(playerPlan.tactic, enemyPlan.tactic)

        let damageToEnemy = max(5, Int(Double(playerScore) * 0.12) + advantage + Int.random(in: 0...8))
        let damageToPlayer = max(4, Int(Double(enemyScore) * 0.11) - advantage / 2 + Int.random(in: 0...7))

        enemyCore = max(0, enemyCore - damageToEnemy)
        playerCore = max(0, playerCore - damageToPlayer)
        damageUnits(&enemyUnits, amount: max(4, damageToEnemy / 2), lane: playerPlan.focusLane)
        damageUnits(&playerUnits, amount: max(4, damageToPlayer / 2), lane: enemyPlan.focusLane)

        events.insert(BattleEvent(
            round: round,
            text: "R(round) • (playerPlan.tactic.rawValue) vs (enemyPlan.tactic.rawValue) • Enemy -(damageToEnemy) / You -(damageToPlayer)",
            isPositive: damageToEnemy >= damageToPlayer
        ), at: 0)
    }

    private func combatScore(plan: TacticalPlan, units: [BattleUnit]) -> Int {
        let alive = units.filter(\.alive)
        let base = alive.reduce(0) { $0 + $1.kind.basePower }
        let focus = alive.filter { $0.lane == plan.focusLane }.count * 6
        let modifier = plan.tactic == .assault ? 1.18 : plan.tactic == .defend ? 0.92 : 1.0
        return Int(Double(base + focus) * modifier)
    }

    private func matchup(_ a: Tactic, _ b: Tactic) -> Int {
        switch (a, b) {
        case (.flank, .defend), (.ambush, .assault), (.assault, .balanced): return 10
        case (.defend, .flank), (.assault, .ambush), (.balanced, .assault): return -8
        default: return 0
        }
    }

    private func damageUnits(_ units: inout [BattleUnit], amount: Int, lane: Int) {
        guard let index = units.indices.filter({ units[$0].alive && units[$0].lane == lane }).randomElement()
                ?? units.indices.filter({ units[$0].alive }).randomElement() else { return }
        units[index].health = max(0, units[index].health - amount)
    }

    private func finish(win: Bool) {
        phase = win ? .victory : .defeat
        progress.record(win: win)
        saveProgress()
        statusMessage = win ? "Victory" : "Defeat"
    }

    private func saveProgress() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let saved = try? JSONDecoder().decode(PlayerProgress.self, from: data) else { return }
        progress = saved
    }
}
