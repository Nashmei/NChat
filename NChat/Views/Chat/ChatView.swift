import SwiftUI
import SwiftData
import UniformTypeIdentifiers
struct ChatView:View {
 @Environment(\.modelContext) private var context
 @Bindable var conversation:Conversation
 @StateObject private var vm=ChatViewModel()
 @State private var importing=false
 var body:some View {
  ZStack {
   NChatTheme.background.ignoresSafeArea()
   VStack(spacing:0){
    ScrollViewReader{proxy in ScrollView{LazyVStack(spacing:22){ForEach(conversation.messages.sorted{$0.createdAt<$1.createdAt}){m in MessageBubble(message:m).id(m.id)}}.padding(.horizontal,18).padding(.vertical,22)}.scrollDismissesKeyboard(.interactively).onChange(of:conversation.messages.count){_,_ in if let id=conversation.messages.last?.id{withAnimation{proxy.scrollTo(id,anchor:.bottom)}}}}
    if !vm.attachments.isEmpty{ScrollView(.horizontal,showsIndicators:false){HStack{ForEach(vm.attachments){a in Label(a.name,systemImage:a.isImage ? "photo":"doc").font(.caption).foregroundStyle(.white).padding(.horizontal,12).padding(.vertical,8).background(NChatTheme.elevated,in:Capsule())}}.padding(.horizontal,18)}}
    HStack(alignment:.bottom,spacing:10){
     Button{importing=true}label:{Image(systemName:"plus").font(.headline).frame(width:40,height:40).background(NChatTheme.elevated,in:Circle()).foregroundStyle(.white)}
     TextField("Ask NChat anything…",text:$vm.draft,axis:.vertical).lineLimit(1...7).textFieldStyle(.plain).foregroundStyle(.white).padding(.horizontal,16).padding(.vertical,12).background(NChatTheme.surface,in:RoundedRectangle(cornerRadius:22,style:.continuous)).overlay(RoundedRectangle(cornerRadius:22).stroke(NChatTheme.border))
     Button{vm.isStreaming ? vm.stop():vm.send(in:conversation,context:context)}label:{Image(systemName:vm.isStreaming ? "stop.fill":"arrow.up").font(.headline).frame(width:42,height:42).background(NChatTheme.gradient,in:Circle()).foregroundStyle(.white)}.disabled(vm.draft.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && vm.attachments.isEmpty && !vm.isStreaming)
    }.padding(.horizontal,16).padding(.vertical,12).background(NChatTheme.background)
   }
  }
  .navigationBarTitleDisplayMode(.inline).toolbar{ToolbarItem(placement:.principal){ModelPicker(conversation:conversation)};ToolbarItem(placement:.topBarTrailing){Menu{Button("Regenerate"){vm.regenerate(in:conversation,context:context)};ShareLink(item:ExportService.markdown(for:conversation)){Label("Export chat",systemImage:"square.and.arrow.up")};Stepper("Context \(conversation.contextBudget/1000)K",value:$conversation.contextBudget,in:4000...128000,step:4000)}label:{Image(systemName:"ellipsis").frame(width:34,height:34).background(NChatTheme.elevated,in:Circle()).foregroundStyle(.white)}}}
  .fileImporter(isPresented:$importing,allowedContentTypes:[.image,.pdf,.plainText,.json,.commaSeparatedText],allowsMultipleSelection:true){result in if case .success(let urls)=result{for u in urls.prefix(5){let access=u.startAccessingSecurityScopedResource();defer{if access{u.stopAccessingSecurityScopedResource()}};if let d=try? Data(contentsOf:u),d.count<10_000_000{vm.attachments.append(.init(name:u.lastPathComponent,typeIdentifier:(try? u.resourceValues(forKeys:[.contentTypeKey]).contentType?.identifier) ?? UTType.data.identifier,data:d))}}}}
  .alert("NChat",isPresented:Binding(get:{vm.errorMessage != nil},set:{if !$0{vm.errorMessage=nil}})){Button("OK",role:.cancel){}}message:{Text(vm.errorMessage ?? "")}
 }
}
