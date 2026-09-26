import SwiftUI
import SwiftData
struct RootView:View {
 @Environment(\.modelContext) private var context
 @Query(sort:\Conversation.updatedAt,order:.reverse) private var conversations:[Conversation]
 @State private var selected:Conversation?;@State private var showSettings=false;@State private var search="";@State private var rename:Conversation?;@State private var renameText=""
 var visible:[Conversation]{conversations.filter{search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)}.sorted{if $0.isPinned != $1.isPinned{return $0.isPinned};return $0.updatedAt>$1.updatedAt}}
 var body:some View{
  NavigationSplitView{
   List(selection:$selected){ForEach(visible){c in HStack{if c.isPinned{Image(systemName:"pin.fill").font(.caption)};VStack(alignment:.leading,spacing:4){Text(c.title).lineLimit(1);Text(c.modelID).font(.caption2).foregroundStyle(.secondary).lineLimit(1)}}.tag(c).contextMenu{Button(c.isPinned ? "Unpin":"Pin"){c.isPinned.toggle()};Button("Rename"){rename=c;renameText=c.title};ShareLink(item:ExportService.markdown(for:c)){Label("Export",systemImage:"square.and.arrow.up")};Button("Delete",role:.destructive){context.delete(c)}}}.onDelete{index in index.map{visible[$0]}.forEach(context.delete)}}
   .searchable(text:$search,prompt:"Search chats").navigationTitle("NChat").toolbar{ToolbarItem(placement:.topBarLeading){Button{showSettings=true}label:{Image(systemName:"slider.horizontal.3")}};ToolbarItem(placement:.topBarTrailing){Button(action:newChat){Image(systemName:"square.and.pencil")}}}
  }detail:{if let selected{ChatView(conversation:selected)}else{ContentUnavailableView("NChat",systemImage:"sparkles",description:Text("Start a new conversation."))}}
  .sheet(isPresented:$showSettings){SettingsView()}.alert("Rename chat",isPresented:Binding(get:{rename != nil},set:{if !$0{rename=nil}})){TextField("Name",text:$renameText);Button("Save"){rename?.title=renameText;rename=nil};Button("Cancel",role:.cancel){rename=nil}}
  .onAppear{if selected==nil{selected=conversations.first}}
 }
 private func newChat(){let c=Conversation(systemPrompt:UserDefaults.standard.string(forKey:"defaultSystemPrompt") ?? "");context.insert(c);selected=c}
}
