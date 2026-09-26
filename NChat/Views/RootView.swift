import SwiftUI
import SwiftData

struct RootView:View {
 @Environment(\.modelContext) private var context
 @Query(sort:\Conversation.updatedAt,order:.reverse) private var conversations:[Conversation]
 @ObservedObject private var catalog=ModelCatalogStore.shared
 @State private var selected:Conversation?
 @State private var showSettings=false
 @State private var search=""
 @State private var rename:Conversation?
 @State private var renameText=""

 private var visible:[Conversation] {
  conversations
   .filter{search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)}
   .sorted{if $0.isPinned != $1.isPinned{return $0.isPinned};return $0.updatedAt>$1.updatedAt}
 }

 var body:some View {
  NavigationSplitView {
   ZStack {
    NChatPageBackground()
    VStack(spacing:0) {
     catalogBanner
     if conversations.isEmpty {
      sidebarEmptyState
     } else {
      conversationList
     }
    }
   }
   .searchable(text:$search,prompt:"Search conversations")
   .navigationTitle("NChat")
   .toolbar {
    ToolbarItem(placement:.topBarLeading){settingsButton}
    ToolbarItem(placement:.topBarTrailing){newChatButton}
   }
  } detail:{
   if let selected {
    ChatView(conversation:selected)
   } else {
    detailEmptyState
   }
  }
  .tint(NChatTheme.pink)
  .sheet(isPresented:$showSettings){SettingsView().preferredColorScheme(.dark)}
  .alert("Rename chat",isPresented:Binding(get:{rename != nil},set:{if !$0{rename=nil}})) {
   TextField("Name",text:$renameText)
   Button("Save"){let value=renameText.trimmingCharacters(in:.whitespacesAndNewlines);if !value.isEmpty{rename?.title=value};rename=nil}
   Button("Cancel",role:.cancel){rename=nil}
  }
  .onAppear{if selected==nil{selected=conversations.first}}
 }

 @ViewBuilder private var catalogBanner:some View {
  if catalog.isLoading {
   VStack(alignment:.leading,spacing:7) {
    HStack{ProgressView().tint(NChatTheme.pink);Text("Checking NVIDIA models").font(.caption.weight(.semibold));Spacer();Text("\(catalog.testedCount)/\(catalog.totalToTest)").font(.caption2).foregroundStyle(NChatTheme.secondary)}
    ProgressView(value:catalog.progress).tint(NChatTheme.pink)
   }
   .padding(12).background(NChatTheme.surface.opacity(0.96))
  } else if let error=catalog.error,!KeychainStore.read().isEmpty {
   HStack(spacing:9) {
    Image(systemName:"exclamationmark.triangle.fill").foregroundStyle(.orange)
    Text(error).font(.caption).foregroundStyle(NChatTheme.secondary).lineLimit(2)
    Spacer()
    Button("Retry"){Task{await catalog.refreshAndValidate(force:true)}}.font(.caption.weight(.semibold))
   }.padding(12).background(NChatTheme.surface.opacity(0.96))
  }
 }

 private var conversationList:some View {
  List(selection:$selected) {
   ForEach(visible) { conversation in
    HStack(spacing:12) {
     ZStack {
      RoundedRectangle(cornerRadius:11,style:.continuous).fill(conversation.isPinned ? NChatTheme.gradient:LinearGradient(colors:[NChatTheme.elevated,NChatTheme.elevated],startPoint:.top,endPoint:.bottom))
      Image(systemName:conversation.isPinned ? "pin.fill":"bubble.left.fill").font(.caption).foregroundStyle(.white)
     }.frame(width:36,height:36)
     VStack(alignment:.leading,spacing:4) {
      Text(conversation.title).font(.subheadline.weight(.medium)).foregroundStyle(.white).lineLimit(1)
      Text(conversation.modelID.split(separator:"/").last.map(String.init) ?? conversation.modelID).font(.caption2).foregroundStyle(NChatTheme.secondary).lineLimit(1)
     }
    }
    .listRowBackground(Color.clear)
    .tag(conversation)
    .contextMenu {
     Button(conversation.isPinned ? "Unpin":"Pin"){conversation.isPinned.toggle()}
     Button("Rename"){rename=conversation;renameText=conversation.title}
     ShareLink(item:ExportService.markdown(for:conversation)){Label("Export",systemImage:"square.and.arrow.up")}
     Button("Delete",role:.destructive){context.delete(conversation)}
    }
   }
   .onDelete{indices in indices.map{visible[$0]}.forEach(context.delete)}
  }
  .listStyle(.plain)
  .scrollContentBackground(.hidden)
 }

 private var sidebarEmptyState:some View {
  VStack(spacing:14) {
   Spacer()
   Image(systemName:KeychainStore.read().isEmpty ? "key.horizontal.fill":"bubble.left.and.bubble.right.fill")
    .font(.system(size:30)).foregroundStyle(NChatTheme.pink)
   Text(KeychainStore.read().isEmpty ? "Connect NVIDIA":"Start your first chat").font(.headline).foregroundStyle(.white)
   Text(KeychainStore.read().isEmpty ? "Add your NVIDIA API key to discover and verify available models.":"Your verified models are ready.")
    .font(.caption).foregroundStyle(NChatTheme.secondary).multilineTextAlignment(.center).padding(.horizontal,28)
   Button(KeychainStore.read().isEmpty ? "Open Settings":"New Chat"){if KeychainStore.read().isEmpty{showSettings=true}else{newChat()}}
    .buttonStyle(.borderedProminent).tint(NChatTheme.purple)
   Spacer()
  }
 }

 private var detailEmptyState:some View {
  ZStack {
   NChatPageBackground()
   VStack(spacing:18) {
    ZStack{Circle().fill(NChatTheme.gradient).frame(width:78,height:78);Image(systemName:"sparkles").font(.title).foregroundStyle(.white)}
     .shadow(color:NChatTheme.purple.opacity(0.35),radius:30,y:12)
    Text("Your AI workspace").font(.title2.bold()).foregroundStyle(.white)
    Text("Select a conversation or create a new one.").foregroundStyle(NChatTheme.secondary)
   }
  }
 }

 private var settingsButton:some View {
  Button{showSettings=true}label:{Image(systemName:"slider.horizontal.3").foregroundStyle(.white)}.accessibilityLabel("Settings")
 }
 private var newChatButton:some View {
  Button(action:newChat){Image(systemName:"square.and.pencil").foregroundStyle(.white)}.accessibilityLabel("New chat")
 }

 private func newChat() {
  guard !catalog.passedModels.isEmpty else{showSettings=true;return}
  let saved=UserDefaults.standard.string(forKey:"lastWorkingModel")
  let model=catalog.passedModels.first(where:{$0.id==saved})?.id ?? catalog.passedModels[0].id
  let conversation=Conversation(modelID:model,systemPrompt:UserDefaults.standard.string(forKey:"defaultSystemPrompt") ?? "")
  context.insert(conversation)
  selected=conversation
 }
}
