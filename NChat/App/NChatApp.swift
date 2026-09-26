import SwiftUI
import SwiftData

@main struct NChatApp:App {
 var body:some Scene {
  WindowGroup {
   RootView()
    .preferredColorScheme(.dark)
    .task {
     if !KeychainStore.read().isEmpty {
      await ModelCatalogStore.shared.refreshAndValidate()
     }
    }
  }
  .modelContainer(for:[Conversation.self,ChatMessage.self])
 }
}
