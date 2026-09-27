import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var game: GameStore
    let onPlay: () -> Void

    var body: some View {
        ZStack {
            PWTheme.background
            ScrollView {
                VStack(spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("PROMPT WARS").font(.caption.bold()).tracking(3).foregroundStyle(PWTheme.cyan)
                            Text("Command the impossible.").font(.title.bold())
                        }
                        Spacer()
                        ZStack {
                            Circle().fill(PWTheme.accent.opacity(0.2)).frame(width: 52, height: 52)
                            Image(systemName: "brain.head.profile.fill").foregroundStyle(PWTheme.accent)
                        }
                    }

                    GlassCard {
                        VStack(spacing: 18) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("RANKED ARENA").font(.caption.bold()).foregroundStyle(.secondary)
                                    Text("Sector Zero").font(.title2.bold())
                                }
                                Spacer()
                                Text("#\(game.progress.rating)").font(.headline.monospacedDigit()).foregroundStyle(PWTheme.cyan)
                            }
                            HStack(spacing: 12) {
                                Stat(title: "LEVEL", value: "\(game.progress.level)")
                                Stat(title: "WINS", value: "\(game.progress.wins)")
                                Stat(title: "CREDITS", value: "\(game.progress.credits)")
                            }
                            Button {
                                game.resetBattle()
                                game.startBattle()
                                onPlay()
                            } label: {
                                Label("ENTER BATTLE", systemImage: "bolt.fill")
                                    .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 15)
                            }
                            .buttonStyle(.borderedProminent).tint(PWTheme.accent)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("HOW IT WORKS", systemImage: "command").font(.headline)
                            Text("Write your battle order in natural language. The tactical interpreter converts intent into a plan; the deterministic game engine decides damage, rules and victory.")
                                .foregroundStyle(.secondary)
                            Label(game.isAIEnabled ? "AI tactical link enabled" : "Local tactical interpreter active",
                                  systemImage: game.isAIEnabled ? "sparkles" : "iphone")
                                .font(.footnote.bold()).foregroundStyle(game.isAIEnabled ? PWTheme.cyan : .secondary)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

private struct Stat: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title3.bold().monospacedDigit())
            Text(title).font(.caption2.bold()).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
    }
}
