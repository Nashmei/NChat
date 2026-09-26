import SwiftUI
import SwiftData

@main
struct NChatApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(for: [Conversation.self, ChatMessage.self])
    }
}
