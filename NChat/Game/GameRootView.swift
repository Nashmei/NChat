import SwiftUI

struct GameRootView: View {
    @EnvironmentObject private var game: GameStore
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            HomeView(onPlay: { tab = 1 })
                .tabItem { Label("Command", systemImage: "hexagon.fill") }.tag(0)
            BattleView()
                .tabItem { Label("Battle", systemImage: "scope") }.tag(1)
            ArsenalView()
                .tabItem { Label("Arsenal", systemImage: "square.grid.2x2.fill") }.tag(2)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }.tag(3)
            GameSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }.tag(4)
        }
        .tint(PWTheme.accent)
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
        LinearGradient(colors: [bg, Color(red: 0.07, green: 0.04, blue: 0.14)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(16)
            .background(PWTheme.panel, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.08)))
    }
}
