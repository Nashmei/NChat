import SwiftUI

struct BattleView: View {
    @EnvironmentObject private var game: GameStore

    var body: some View {
        ZStack {
            PWTheme.background
            VStack(spacing: 12) {
                battleHeader
                arena
                if game.phase == .planning { commandPanel }
                else if game.phase == .resolving { resolving }
                else if game.phase == .victory || game.phase == .defeat { resultPanel }
                else { readyPanel }
                eventFeed
            }
            .padding()
        }
    }

    private var battleHeader: some View {
        HStack {
            CoreMeter(title: "YOU", value: game.playerCore, color: PWTheme.cyan)
            VStack(spacing: 2) {
                Text("ROUND").font(.caption2.bold()).foregroundStyle(.secondary)
                Text("\(game.round)").font(.title2.bold().monospacedDigit())
            }.frame(width: 64)
            CoreMeter(title: "ENEMY", value: game.enemyCore, color: PWTheme.danger)
        }
    }

    private var arena: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Label(game.playerPlan.tactic.rawValue, systemImage: game.playerPlan.tactic.icon)
                        .foregroundStyle(PWTheme.cyan)
                    Spacer()
                    Text("VS").font(.caption.bold()).foregroundStyle(.secondary)
                    Spacer()
                    Label(game.enemyPlan.tactic.rawValue, systemImage: game.enemyPlan.tactic.icon)
                        .foregroundStyle(PWTheme.danger)
                }
                Divider().overlay(.white.opacity(0.12))
                ForEach(0..<3, id: \.self) { lane in
                    HStack {
                        UnitStrip(units: game.playerUnits.filter { $0.lane == lane }, friendly: true)
                        Spacer()
                        Text(["L","C","R"][lane]).font(.caption2.bold()).foregroundStyle(.secondary)
                        Spacer()
                        UnitStrip(units: game.enemyUnits.filter { $0.lane == lane }, friendly: false)
                    }
                    .frame(height: 44)
                }
            }
        }
    }

    private var commandPanel: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(Tactic.allCases) { tactic in
                    Button { game.applyPreset(tactic) } label: {
                        Image(systemName: tactic.icon).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(game.playerPlan.tactic == tactic ? PWTheme.accent : .secondary)
                }
            }
            HStack(spacing: 10) {
                TextField("مثال: هاجم من اليمين ولا تطارد المنسحب", text: $game.command, axis: .vertical)
                    .lineLimit(1...3).textFieldStyle(.plain).padding(13)
                    .background(PWTheme.panelStrong, in: RoundedRectangle(cornerRadius: 16))
                Button {
                    Task { await game.executeCommand() }
                } label: {
                    Image(systemName: "arrow.up").font(.headline).frame(width: 46, height: 46)
                }
                .buttonStyle(.borderedProminent).tint(PWTheme.accent)
                .disabled(game.energy < 20)
            }
            HStack {
                Label("ENERGY \(game.energy)", systemImage: "bolt.fill").foregroundStyle(PWTheme.cyan)
                Spacer()
                Text(game.statusMessage).foregroundStyle(.secondary)
            }.font(.caption.bold())
        }
    }

    private var resolving: some View {
        ProgressView("Resolving tactical simulation…").tint(PWTheme.accent).padding()
    }

    private var readyPanel: some View {
        Button("START BATTLE") { game.startBattle() }
            .buttonStyle(.borderedProminent).tint(PWTheme.accent)
    }

    private var resultPanel: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: game.phase == .victory ? "trophy.fill" : "shield.slash.fill")
                    .font(.system(size: 38)).foregroundStyle(game.phase == .victory ? .yellow : PWTheme.danger)
                Text(game.phase == .victory ? "VICTORY" : "DEFEAT").font(.largeTitle.bold())
                Button("NEW BATTLE") { game.resetBattle(); game.startBattle() }
                    .buttonStyle(.borderedProminent).tint(PWTheme.accent)
            }.frame(maxWidth: .infinity)
        }
    }

    private var eventFeed: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(game.events.prefix(4)) { event in
                    Text(event.text).font(.caption.monospaced())
                        .foregroundStyle(event.isPositive ? PWTheme.cyan : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }.frame(maxHeight: 90)
    }
}

private struct CoreMeter: View {
    let title: String
    let value: Int
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack { Text(title).font(.caption.bold()); Spacer(); Text("\(value)").font(.caption.monospacedDigit()) }
            ProgressView(value: Double(value), total: 100).tint(color)
        }
    }
}

private struct UnitStrip: View {
    let units: [BattleUnit]
    let friendly: Bool
    var body: some View {
        HStack(spacing: 4) {
            ForEach(units) { unit in
                VStack(spacing: 2) {
                    Image(systemName: unit.kind.icon)
                    Capsule().fill(unit.alive ? (friendly ? PWTheme.cyan : PWTheme.danger) : Color.gray)
                        .frame(width: 22, height: 3).opacity(Double(unit.health) / 100)
                }.opacity(unit.alive ? 1 : 0.25)
            }
        }
    }
}
