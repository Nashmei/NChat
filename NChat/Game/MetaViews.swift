import SwiftUI

struct ArsenalView: View {
    @EnvironmentObject private var game: GameStore
    var body: some View {
        NavigationStack {
            ZStack {
                PWTheme.background
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(UnitKind.allCases) { kind in
                            GlassCard {
                                HStack(spacing: 16) {
                                    Image(systemName: kind.icon).font(.title2).foregroundStyle(PWTheme.cyan)
                                        .frame(width: 48, height: 48).background(PWTheme.cyan.opacity(0.1), in: Circle())
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(kind.rawValue).font(.headline)
                                        Text("Base power \(kind.basePower) • Tactical unit").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.seal.fill").foregroundStyle(PWTheme.accent)
                                }
                            }
                        }
                    }.padding()
                }
            }.navigationTitle("Arsenal")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var game: GameStore
    var body: some View {
        NavigationStack {
            ZStack {
                PWTheme.background
                VStack(spacing: 18) {
                    ZStack {
                        Circle().fill(PWTheme.accent.opacity(0.18)).frame(width: 110, height: 110)
                        Image(systemName: "person.crop.circle.fill").font(.system(size: 76)).foregroundStyle(PWTheme.accent)
                    }
                    Text("COMMANDER").font(.title.bold())
                    Text("LEVEL \(game.progress.level)").font(.caption.bold()).tracking(2).foregroundStyle(PWTheme.cyan)
                    GlassCard {
                        VStack(spacing: 14) {
                            row("Rating", "\(game.progress.rating)", "chart.line.uptrend.xyaxis")
                            Divider()
                            row("Victories", "\(game.progress.wins)", "trophy.fill")
                            Divider()
                            row("Defeats", "\(game.progress.losses)", "shield.slash")
                            Divider()
                            row("XP", "\(game.progress.xp)", "sparkles")
                            Divider()
                            row("Credits", "\(game.progress.credits)", "hexagon.fill")
                        }
                    }
                    Spacer()
                }.padding()
            }.navigationTitle("Profile")
        }
    }

    private func row(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value).font(.headline.monospacedDigit()).foregroundStyle(PWTheme.cyan)
        }
    }
}

struct GameSettingsView: View {
    @EnvironmentObject private var game: GameStore
    var body: some View {
        NavigationStack {
            ZStack {
                PWTheme.background
                Form {
                    Section("TACTICAL AI") {
                        Toggle("Use NVIDIA tactical intelligence", isOn: $game.isAIEnabled)
                        TextField("Secure proxy URL", text: $game.proxyURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                        Text("The NVIDIA API key must stay on your backend. NChat sends only the player's tactical command to this proxy.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Section("ENGINE") {
                        LabeledContent("Rules", value: "Deterministic")
                        LabeledContent("AI authority", value: "Tactics only")
                        LabeledContent("Battle format", value: "3 lanes")
                    }
                    Section("DATA") {
                        Button("Reset current battle", role: .destructive) { game.resetBattle() }
                    }
                    Section {
                        Text("Prompt Wars • NChat Game Edition")
                            .frame(maxWidth: .infinity).font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }.navigationTitle("Settings")
        }
    }
}
