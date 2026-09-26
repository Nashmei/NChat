import SwiftUI
import SwiftData
@main struct NChatApp:App {
 @Environment(\.scenePhase) private var scenePhase
 var body:some Scene {
  WindowGroup{RootView().preferredColorScheme(.dark).task{if !KeychainStore.read().isEmpty{await ModelCatalogStore.shared.refreshAndValidate()}}}
   .modelContainer(for:[Conversation.self,ChatMessage.self])
   .onChange(of:scenePhase){_,phase in if phase == .active,!KeychainStore.read().isEmpty{Task{await ModelCatalogStore.shared.refreshAndValidate()}}}
 }
}
