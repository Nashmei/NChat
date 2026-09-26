import SwiftUI
struct ModelsView:View {
 @ObservedObject private var catalog=ModelCatalogStore.shared
 @State private var search=""
 var filtered:[NVIDIAListModel]{catalog.passedModels.filter{search.isEmpty || $0.id.localizedCaseInsensitiveContains(search)}}
 var body:some View{
  ZStack{NChatTheme.background.ignoresSafeArea();List{
   Section{
    if catalog.isLoading{VStack(alignment:.leading,spacing:8){ProgressView(value:catalog.progress);Text("Testing \(catalog.testedCount) of \(catalog.totalToTest) NVIDIA models").font(.caption).foregroundStyle(.secondary)}}
    Button{Task{await catalog.refreshAndValidate(force:true)}}label:{Label("Retest full catalog",systemImage:"arrow.clockwise")}
   }
   Section("\(filtered.count) verified chat models"){
    ForEach(filtered){m in
     VStack(alignment:.leading,spacing:8){
      HStack{VStack(alignment:.leading,spacing:3){Text(m.displayName).font(.headline);Text(m.id).font(.caption2).foregroundStyle(.secondary)};Spacer();Image(systemName:"checkmark.seal.fill").foregroundStyle(.green)}
      if let cap=catalog.capabilities[m.id]{
       HStack{ForEach(cap.badges,id:\.self){Text($0).font(.caption2.weight(.semibold)).padding(.horizontal,7).padding(.vertical,4).background(NChatTheme.elevated,in:Capsule())};Spacer();Text("\(cap.latencyMS) ms").font(.caption2).foregroundStyle(.secondary)}
      }
     }.padding(.vertical,4)
    }
   }
  }.scrollContentBackground(.hidden)}
  .searchable(text:$search,prompt:"Search verified models").navigationTitle("Verified Models")
 }
}
