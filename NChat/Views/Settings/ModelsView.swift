import SwiftUI
struct ModelsView:View {
 @ObservedObject private var catalog=ModelCatalogStore.shared
 @State private var search=""
 var filtered:[NVIDIAListModel]{catalog.models.filter{search.isEmpty || $0.id.localizedCaseInsensitiveContains(search)}}
 var body:some View {
  List {
   Section { Button{Task{await catalog.refresh()}}label:{Label("Refresh from NVIDIA",systemImage:"arrow.clockwise")}; if catalog.isLoading{ProgressView()}; if let e=catalog.error{Text(e).foregroundStyle(.red).font(.caption)} }
   Section("\(filtered.count) available models") {
    ForEach(filtered){m in HStack{VStack(alignment:.leading){Text(m.displayName);Text(m.id).font(.caption2).foregroundStyle(.secondary)};Spacer();if catalog.verified.contains(m.id){Image(systemName:"checkmark.seal.fill").foregroundStyle(.green)}else if catalog.unavailable.contains(m.id){Image(systemName:"xmark.circle").foregroundStyle(.red)}else{Button("Test"){Task{await catalog.validate(m)}}.font(.caption)}}}
   }
  }.searchable(text:$search,prompt:"Search NVIDIA models").navigationTitle("Models").task{await catalog.refresh()}
 }
}
