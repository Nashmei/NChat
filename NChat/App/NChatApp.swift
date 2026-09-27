import SwiftUI

@main
struct NChatApp: App {
    @StateObject private var game = GameStore()

    var body: some Scene {
        WindowGroup {
            GameRootView()
                .environmentObject(game)
                .preferredColorScheme(.dark)
        }
    }
}
