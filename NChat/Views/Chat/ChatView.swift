import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var context
    @Bindable var conversation: Conversation
    @StateObject private var vm=ChatViewModel()

    var body: some View {
        VStack(spacing:0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing:18) {
                        ForEach(conversation.messages.sorted{$0.createdAt<$1.createdAt}) { m in
                            MessageBubble(message:m).id(m.id)
                        }
                    }.padding()
                }
                .onChange(of:conversation.messages.count) { _,_ in if let id=conversation.messages.last?.id { withAnimation { proxy.scrollTo(id,anchor:.bottom) } } }
            }
            Divider()
            HStack(alignment:.bottom,spacing:10) {
                TextField("Message NChat",text:$vm.draft,axis:.vertical).lineLimit(1...8).textFieldStyle(.plain).padding(12).background(.thinMaterial,in:RoundedRectangle(cornerRadius:20))
                Button { vm.isStreaming ? vm.stop() : vm.send(in:conversation,context:context) } label: {
                    Image(systemName:vm.isStreaming ? "stop.fill" : "arrow.up").font(.headline).frame(width:38,height:38).background(.primary,in:Circle()).foregroundStyle(.background)
                }.disabled(vm.draft.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && !vm.isStreaming)
            }.padding()
        }
        .navigationTitle(conversation.title).navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement:.principal) { ModelPicker(conversation:conversation) } }
        .alert("NChat",isPresented:Binding(get:{vm.errorMessage != nil},set:{if !$0{vm.errorMessage=nil}})) { Button("OK",role:.cancel){} } message:{Text(vm.errorMessage ?? "")}
    }
}
