import SwiftUI
import SwiftData
struct RootView:View {
 @Environment(\.modelContext) private var context
 @Query(sort:\Conversation.updatedAt,order:.reverse) private var conversations:[Conversation]
 @ObservedObject private var catalog=ModelCatalogStore.shared
 @State private var selected:Conversation?;@State private var showSettings=false;@State private var search="";@State private var rename:Conversation?;@State private var renameText=""
 var visible:[Conversation]{conversations.filter{search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)}.sorted{if $0.isPinned != $1.isPinned{return $0.isPinned};return $0.updatedAt>$1.updatedAt}}
 var body:some View {
  NavigationSplitView {
   ZStack {
    NChatTheme.background.ignoresSafeArea()
    VStack(spacing:0){
     if catalog.isLoading{HStack(spacing:10){ProgressView().tint(NChatTheme.pink);VStack(alignment:.leading){Text("Optimizing models").font(.caption.weight(.semibold));Text("\(catalog.testedCount) / \(catalog.totalToTest)").font(.caption2).foregroundStyle(NChatTheme.secondary)};Spacer()}.padding(12).background(NChatTheme.surface)}
     List(selection:$selected){ForEach(visible){c in HStack(spacing:12){ZStack{RoundedRectangle(cornerRadius:10).fill(NChatTheme.violet.opacity(0.65));Image(systemName:c.isPinned ? "pin.fill":"bubble.left.fill").font(.caption).foregroundStyle(.white)}.frame(width:34,height:34);VStack(alignment:.leading,spacing:4){Text(c.title).foregroundStyle(.white).lineLimit(1);Text(c.modelID.split(separator:"/").last.map(String.init) ?? c.modelID).font(.caption2).foregroundStyle(NChatTheme.secondary).lineLimit(1)}}.listRowBackground(NChatTheme.background).tag(c).contextMenu{Button(c.isPinned ? "Unpin":"Pin"){c.isPinned.toggle()};Button("Rename"){rename=c;renameText=c.title};ShareLink(item:ExportService.markdown(for:c)){Label("Export",systemImage:"square.and.arrow.up")};Button("Delete",role:.destructive){context.delete(c)}}}.onDelete{index in index.map{visible[$0]}.forEach(context.delete)}}.scrollContentBackground(.hidden)
    }
   }.searchable(text:$search,prompt:"Search conversations").navigationTitle("NChat").toolbar{ToolbarItem(placement:.topBarLeading){Button{showSettings=true}label:{Image(systemName:"slider.horizontal.3").foregroundStyle(.white)}};ToolbarItem(placement:.topBarTrailing){Button(action:newChat){Image(systemName:"square.and.pencil").foregroundStyle(.white)}}}
  } detail: {
   if let selected{ChatView(conversation:selected)}else{ZStack{NChatTheme.background.ignoresSafeArea();VStack(spacing:18){ZStack{Circle().fill(NChatTheme.gradient).frame(width:76,height:76);Image(systemName:"sparkles").font(.title).foregroundStyle(.white)};Text("How can I help you?").font(.title2.bold()).foregroundStyle(.white);Text("Choose a conversation or start a new one.").foregroundStyle(NChatTheme.secondary)}}}
  }
  .tint(NChatTheme.pink).sheet(isPresented:$showSettings){SettingsView().preferredColorScheme(.dark)}
  .alert("Rename chat",isPresented:Binding(get:{rename != nil},set:{if !$0{rename=nil}})){TextField("Name",text:$renameText);Button("Save"){rename?.title=renameText;rename=nil};Button("Cancel",role:.cancel){rename=nil}}
  .onAppear{if selected==nil{selected=conversations.first}}
 }
 private func newChat(){guard !catalog.passedModels.isEmpty else{showSettings=true;return};let saved=UserDefaults.standard.string(forKey:"lastWorkingModel");let model=catalog.passedModels.contains(where:{$0.id==saved}) ? saved! : catalog.passedModels[0].id;let c=Conversation(modelID:model,systemPrompt:UserDefaults.standard.string(forKey:"defaultSystemPrompt") ?? "");context.insert(c);selected=c}
}
