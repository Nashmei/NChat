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
   NChatPageBackground()
   VStack(spacing:0) {
    messages
    statusArea
    composer
   }
  }
  .navigationBarTitleDisplayMode(.inline)
  .toolbar {
   ToolbarItem(placement:.principal){ModelPicker(conversation:conversation)}
   ToolbarItem(placement:.topBarTrailing){chatMenu}
  }
  .fileImporter(
   isPresented:$importing,
   allowedContentTypes:[.image,.plainText,.json,.commaSeparatedText],
   allowsMultipleSelection:true,
   onCompletion:handleImport
  )
  .alert("NChat",isPresented:Binding(get:{vm.errorMessage != nil},set:{if !$0{vm.errorMessage=nil}})) {
   Button("OK",role:.cancel){}
  } message:{Text(vm.errorMessage ?? "")}
 }

 private var messages:some View {
  ScrollViewReader { proxy in
   ScrollView {
    if conversation.messages.isEmpty {
     emptyState.padding(.top,80)
    } else {
     LazyVStack(spacing:24) {
      ForEach(conversation.messages.sorted{$0.createdAt<$1.createdAt}) { message in
       MessageBubble(message:message).id(message.id)
      }
     }
     .padding(.horizontal,18)
     .padding(.top,22)
     .padding(.bottom,16)
    }
   }
   .scrollDismissesKeyboard(.interactively)
   .onChange(of:conversation.messages.count){_,_ in scrollToBottom(proxy)}
   .onChange(of:conversation.messages.last?.content){_,_ in
    if vm.isStreaming{scrollToBottom(proxy,animated:false)}
   }
  }
 }

 private var emptyState:some View {
  VStack(spacing:18) {
   ZStack {
    Circle().fill(NChatTheme.gradient).frame(width:72,height:72)
    Circle().stroke(.white.opacity(0.18),lineWidth:1).frame(width:72,height:72)
    Image(systemName:"sparkles").font(.system(size:27,weight:.semibold)).foregroundStyle(.white)
   }
   .shadow(color:NChatTheme.purple.opacity(0.35),radius:28,y:12)
   Text("NChat").font(.largeTitle.bold()).foregroundStyle(.white)
   Text("Your NVIDIA-powered AI workspace")
    .font(.subheadline)
    .foregroundStyle(NChatTheme.secondary)
   Text("Ask a question, attach an image or text file, or let your specialist agents help.")
    .font(.callout)
    .foregroundStyle(NChatTheme.secondary)
    .multilineTextAlignment(.center)
    .frame(maxWidth:330)
  }
 }

 @ViewBuilder private var statusArea:some View {
  if let agent=vm.activeAgent {
   HStack(spacing:9) {
    ProgressView().controlSize(.small).tint(NChatTheme.pink)
    Text("\(agent) is assisting").font(.caption.weight(.medium)).foregroundStyle(NChatTheme.secondary)
    Spacer()
   }
   .padding(.horizontal,18).padding(.vertical,8)
  }
  if !vm.attachments.isEmpty {
   ScrollView(.horizontal,showsIndicators:false) {
    HStack(spacing:8) {
     ForEach(vm.attachments) { attachment in
      HStack(spacing:8) {
       Image(systemName:attachment.isImage ? "photo":"doc.text")
       VStack(alignment:.leading,spacing:1) {
        Text(attachment.name).lineLimit(1)
        Text(attachment.sizeDescription).font(.caption2).foregroundStyle(NChatTheme.secondary)
       }
       Button{vm.attachments.removeAll{$0.id==attachment.id}}label:{
        Image(systemName:"xmark.circle.fill").foregroundStyle(NChatTheme.tertiary)
       }.buttonStyle(.plain)
      }
      .font(.caption)
      .foregroundStyle(.white)
      .padding(.horizontal,11).padding(.vertical,8)
      .background(NChatTheme.elevated,in:RoundedRectangle(cornerRadius:14,style:.continuous))
      .overlay(RoundedRectangle(cornerRadius:14).stroke(NChatTheme.border))
      .frame(maxWidth:220)
     }
    }.padding(.horizontal,16)
   }.padding(.bottom,7)
  }
 }

 private var composer:some View {
  HStack(alignment:.bottom,spacing:9) {
   Button{importing=true}label:{
    Image(systemName:"plus").font(.headline)
     .frame(width:42,height:42)
     .background(NChatTheme.elevated,in:Circle())
     .overlay(Circle().stroke(NChatTheme.border))
   }
   .foregroundStyle(.white)
   .accessibilityLabel("Attach file")

   TextField("Message NChat",text:$vm.draft,axis:.vertical)
    .lineLimit(1...7)
    .textFieldStyle(.plain)
    .foregroundStyle(.white)
    .padding(.horizontal,15).padding(.vertical,12)
    .background(NChatTheme.surface.opacity(0.96),in:RoundedRectangle(cornerRadius:21,style:.continuous))
    .overlay(RoundedRectangle(cornerRadius:21).stroke(NChatTheme.strongBorder))

   Button {
    if vm.isStreaming{vm.stop()}else{vm.send(in:conversation,context:context)}
   } label:{
    Image(systemName:vm.isStreaming ? "stop.fill":"arrow.up")
     .font(.headline)
     .frame(width:42,height:42)
     .background(vm.isStreaming ? AnyShapeStyle(NChatTheme.elevated):AnyShapeStyle(NChatTheme.gradient),in:Circle())
     .overlay(Circle().stroke(NChatTheme.border))
   }
   .foregroundStyle(.white)
   .disabled(vm.draft.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && vm.attachments.isEmpty && !vm.isStreaming)
   .accessibilityLabel(vm.isStreaming ? "Stop response":"Send message")
  }
  .padding(.horizontal,14).padding(.top,9).padding(.bottom,10)
  .background(.ultraThinMaterial)
 }

 private var chatMenu:some View {
  Menu {
   Button{vm.regenerate(in:conversation,context:context)}label:{Label("Regenerate",systemImage:"arrow.clockwise")}
   ShareLink(item:ExportService.markdown(for:conversation)){Label("Export chat",systemImage:"square.and.arrow.up")}
   Divider()
   Stepper("Context \(conversation.contextBudget/1000)K",value:$conversation.contextBudget,in:4000...128000,step:4000)
  } label:{
   Image(systemName:"ellipsis")
    .frame(width:34,height:34)
    .background(NChatTheme.elevated,in:Circle())
    .foregroundStyle(.white)
  }
 }

 private func scrollToBottom(_ proxy:ScrollViewProxy,animated:Bool=true) {
  guard let id=conversation.messages.sorted(by:{$0.createdAt<$1.createdAt}).last?.id else{return}
  if animated{withAnimation(.easeOut(duration:0.22)){proxy.scrollTo(id,anchor:.bottom)}}
  else{proxy.scrollTo(id,anchor:.bottom)}
 }

 private func handleImport(_ result:Result<[URL],Error>) {
  guard case .success(let urls)=result else{return}
  for url in urls.prefix(5) {
   let access=url.startAccessingSecurityScopedResource()
   defer{if access{url.stopAccessingSecurityScopedResource()}}
   guard let data=try? Data(contentsOf:url),data.count<=10_000_000 else{continue}
   let type=(try? url.resourceValues(forKeys:[.contentTypeKey]).contentType?.identifier) ?? UTType.data.identifier
   vm.attachments.append(.init(name:url.lastPathComponent,typeIdentifier:type,data:data))
  }
 }
}
