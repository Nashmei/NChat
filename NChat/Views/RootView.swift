import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort:\Conversation.updatedAt,order:.reverse) private var conversations:[Conversation]
    @State private var selected: Conversation?
    @State private var showSettings=false

    var body: some View {
        NavigationSplitView {
            List(selection:$selected) {
                ForEach(conversations) { c in
                    VStack(alignment:.leading,spacing:4) {
                        Text(c.title).lineLimit(1)
                        Text(c.modelID).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    }.tag(c)
                }.onDelete { index in index.map{conversations[$0]}.forEach(context.delete) }
            }
            .navigationTitle("NChat")
            .toolbar {
                ToolbarItem(placement:.topBarLeading) { Button { showSettings=true } label:{ Image(systemName:"gearshape") } }
                ToolbarItem(placement:.topBarTrailing) { Button(action:newChat) { Image(systemName:"square.and.pencil") } }
            }
        } detail: {
            if let selected { ChatView(conversation:selected) }
            else { ContentUnavailableView("Start a conversation",systemImage:"bubble.left.and.bubble.right",description:Text("Choose a chat or create a new one.")) }
        }
        .sheet(isPresented:$showSettings) { SettingsView() }
        .onAppear { if selected == nil { selected=conversations.first } }
    }
    private func newChat() { let c=Conversation(); context.insert(c); selected=c }
}
