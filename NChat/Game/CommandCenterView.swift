import SwiftUI

struct CommandCenterView: View {
    @EnvironmentObject private var game: GameStore
    let onBattle: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                PWTheme.background
                ScrollView {
                    VStack(spacing: 18) {
                        modeSelector
                        missions
                        leaderboard
                    }.padding()
                }
            }
            .navigationTitle("Command Center")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Label("\(game.progress.credits)", systemImage: "hexagon.fill")
                        .foregroundStyle(PWTheme.cyan)
                }
            }
        }
    }

    private var modeSelector: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("BATTLE MODE").font(.caption.bold()).foregroundStyle(.secondary)
                ForEach(GameMode.allCases) { mode in
                    Button {
                        game.selectedMode = mode
                        FeedbackService.shared.selection()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mode.rawValue).font(.headline)
                                Text(mode.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: game.selectedMode == mode ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(game.selectedMode == mode ? PWTheme.cyan : .secondary)
                        }
                    }.buttonStyle(.plain)
                    if mode != GameMode.allCases.last { Divider() }
                }
                Button {
                    Task {
                        if game.selectedMode == .training {
                            game.resetBattle(); game.startBattle(); onBattle()
                        } else {
                            await game.startMatchmaking()
                            if game.statusMessage.lowercased().contains("matched") { onBattle() }
                        }
                    }
                } label: {
                    HStack {
                        if game.matchmaking.searching { ProgressView().tint(.white) }
                        Text(game.selectedMode == .training ? "START TRAINING" : "FIND OPPONENT")
                            .font(.headline)
                    }.frame(maxWidth: .infinity).padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent).tint(PWTheme.accent)
            }
        }
    }

    private var missions: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("DAILY MISSIONS").font(.caption.bold()).foregroundStyle(.secondary)
                ForEach(game.missions) { mission in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(mission.title).font(.subheadline.bold())
                            Spacer()
                            Text("+\(mission.reward)").font(.caption.bold()).foregroundStyle(PWTheme.cyan)
                        }
                        ProgressView(value: Double(mission.progress), total: Double(mission.target)).tint(PWTheme.accent)
                        Text("\(mission.progress)/\(mission.target)").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var leaderboard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("LEADERBOARD").font(.caption.bold()).foregroundStyle(.secondary)
                ForEach(Array(game.leaderboard().enumerated()), id: \.element.id) { index, entry in
                    HStack {
                        Text("#\(index + 1)").font(.caption.bold()).foregroundStyle(.secondary).frame(width: 28)
                        Text(entry.name).font(.subheadline.bold())
                        Spacer()
                        Text("\(entry.rating)").font(.subheadline.monospacedDigit())
                            .foregroundStyle(entry.isPlayer ? PWTheme.cyan : .primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
