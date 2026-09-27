import SwiftUI

struct GameRootView: View {
    @EnvironmentObject private var game: GameStore
    @AppStorage("promptwars.onboarding.completed") private var onboardingCompleted = false
    @State private var tab = 0

    var body: some View {
        Group {
            if onboardingCompleted {
                TabView(selection: $tab) {
                    HomeView(onPlay: { tab = 1 })
                        .tabItem { Label("Home", systemImage: "hexagon.fill") }.tag(0)
                    BattleView()
                        .tabItem { Label("Battle", systemImage: "scope") }.tag(1)
                    CommandCenterView(onBattle: { tab = 1 })
                        .tabItem { Label("Play", systemImage: "bolt.horizontal.circle.fill") }.tag(2)
                    LoadoutView()
                        .tabItem { Label("Squad", systemImage: "square.grid.2x2.fill") }.tag(3)
                    GameSettingsView()
                        .tabItem { Label("Settings", systemImage: "gearshape.fill") }.tag(4)
                }
                .tint(PWTheme.accent)
            } else {
                OnboardingView(completed: $onboardingCompleted)
            }
        }
    }
}

enum PWTheme {
    static let bg = Color(red: 0.025, green: 0.03, blue: 0.055)
    static let panel = Color.white.opacity(0.065)
    static let panelStrong = Color.white.opacity(0.11)
    static let accent = Color(red: 0.48, green: 0.38, blue: 1)
    static let cyan = Color(red: 0.2, green: 0.82, blue: 1)
    static let danger = Color(red: 1, green: 0.28, blue: 0.4)

    static var background: some View {
        ZStack {
            LinearGradient(
                colors: [bg, Color(red: 0.07, green: 0.04, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [accent.opacity(0.16), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 360
            )
        }.ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(16)
            .background(.ultraThinMaterial.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.08)))
    }
}
