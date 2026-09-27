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
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 82)).foregroundStyle(PWTheme.accent)
                    Text("COMMANDER").font(.title.bold())
                    Text("LEVEL \(game.progress.level)").font(.caption.bold()).tracking(2).foregroundStyle(PWTheme.cyan)
                    GlassCard {
                        VStack(spacing: 14) {
                            row("Rating", "\(game.progress.rating)", "chart.line.uptrend.xyaxis")
                            Divider(); row("Victories", "\(game.progress.wins)", "trophy.fill")
                            Divider(); row("Defeats", "\(game.progress.losses)", "shield.slash")
                            Divider(); row("XP", "\(game.progress.xp)", "sparkles")
                            Divider(); row("Credits", "\(game.progress.credits)", "hexagon.fill")
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
    @AppStorage("promptwars.onboarding.completed") private var onboardingCompleted = true

    var body: some View {
        NavigationStack {
            ZStack {
                PWTheme.background
                Form {
                    Section("EXPERIENCE") {
                        Toggle("Haptics", isOn: $game.hapticsEnabled)
                        Toggle("Sound effects", isOn: $game.soundEnabled)
                        Picker("Language", selection: $game.language) {
                            ForEach(AppLanguage.allCases) { Text($0.rawValue).tag($0) }
                        }
                    }

                    Section("NVIDIA TACTICAL AI") {
                        Toggle("Enable tactical AI", isOn: $game.isAIEnabled)
                        TextField("Secure AI proxy URL", text: $game.proxyURL)
                            .textInputAutocapitalization(.never).keyboardType(.URL)
                        Text("Never place an NVIDIA API key in the IPA. The proxy should validate the model output and return only tactic, lane, aggression, holdPosition and summary.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
\n\n                    Section("ENGINE") {
                        LabeledContent("Rules", value: "Deterministic")
                        LabeledContent("AI authority", value: "Tactics only")
                        LabeledContent("Battle format", value: "3 lanes")
                        LabeledContent("Version", value: "3.0.0 (30)")
                    }

                    Section("RESET") {
                        Button("Replay onboarding") { onboardingCompleted = false }
                        Button("Reset current battle", role: .destructive) { game.resetBattle() }
                    }

                    Section("OPEN SOURCE") {
                        Text("Built with Apple SwiftUI/UIKit/AVFoundation. Optional visual asset direction: Kenney CC0 Sci-Fi/UI packs. No third-party runtime dependency is required by the current target.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }.navigationTitle("Settings")
        }
    }
}
