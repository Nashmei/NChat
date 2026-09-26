import SwiftUI
struct ModelsView:View {
 @ObservedObject private var catalog=ModelCatalogStore.shared
 @State private var search=""
 var filtered:[NVIDIAListModel]{catalog.passedModels.filter{search.isEmpty || $0.id.localizedCaseInsensitiveContains(search)}}
 var body:some View{
  ZStack{NChatTheme.background.ignoresSafeArea();List{
   Section{if catalog.isLoading{VStack(alignment:.leading,spacing:8){ProgressView(value:catalog.progress);Text("Testing \(catalog.testedCount) of \(catalog.totalToTest) NVIDIA models").font(.caption).foregroundStyle(.secondary)}};Button{Task{await catalog.refreshAndValidate()}}label:{Label("Retest full catalog",systemImage:"arrow.clockwise")}}
   Section("\(filtered.count) verified chat models"){ForEach(filtered){m in HStack{VStack(alignment:.leading,spacing:4){Text(m.displayName);Text(m.id).font(.caption2).foregroundStyle(.secondary)};Spacer();if let cap=catalog.capabilities[m.id]{VStack(alignment:.trailing){Image(systemName:"checkmark.seal.fill").foregroundStyle(.green);Text("\(cap.latencyMS) ms").font(.caption2).foregroundStyle(.secondary)}}}}}
  }.scrollContentBackground(.hidden)}.searchable(text:$search,prompt:"Search verified models").navigationTitle("Verified Models")
 }
}
