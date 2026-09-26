import SwiftUI

struct ModelsView:View {
 @ObservedObject private var catalog=ModelCatalogStore.shared
 @State private var search=""

 private var filtered:[NVIDIAListModel] {
  catalog.passedModels.filter{search.isEmpty || $0.id.localizedCaseInsensitiveContains(search)}
 }

 var body:some View {
  ZStack {
   NChatPageBackground()
   List {
    Section {
     if catalog.isLoading {
      VStack(alignment:.leading,spacing:9) {
       HStack{Text("Validating catalog").font(.subheadline.weight(.semibold));Spacer();Text("\(catalog.testedCount)/\(catalog.totalToTest)").font(.caption).foregroundStyle(.secondary)}
       ProgressView(value:catalog.progress).tint(NChatTheme.pink)
      }
     }
     Button{Task{await catalog.refreshAndValidate(force:true)}}label:{Label("Retest full catalog",systemImage:"arrow.clockwise")}
     Text("A model appears here only after passing NChat's text, streaming and Arabic/Latin quality probe. Capabilities marked * are inferred from the model family/name and are not a functional capability test.")
      .font(.caption).foregroundStyle(.secondary)
    }

    Section("\(filtered.count) verified chat models") {
     ForEach(filtered) { model in
      VStack(alignment:.leading,spacing:9) {
       HStack {
        VStack(alignment:.leading,spacing:3) {
         Text(model.displayName).font(.headline)
         Text(model.id).font(.caption2).foregroundStyle(.secondary).textSelection(.enabled)
        }
        Spacer()
        Image(systemName:"checkmark.seal.fill").foregroundStyle(.green)
       }
       if let cap=catalog.capabilities[model.id] {
        ScrollView(.horizontal,showsIndicators:false) {
         HStack(spacing:6) {
          ForEach(cap.badges,id:\.self) { badge in
           Text(badge).font(.caption2.weight(.semibold)).padding(.horizontal,8).padding(.vertical,5).background(NChatTheme.elevated,in:Capsule())
          }
          Text("\(cap.latencyMS) ms").font(.caption2).foregroundStyle(.secondary).padding(.leading,4)
         }
        }
       }
      }
      .padding(.vertical,5)
      .listRowBackground(NChatTheme.surface.opacity(0.72))
     }
    }
   }
   .scrollContentBackground(.hidden)
  }
  .searchable(text:$search,prompt:"Search verified models")
  .navigationTitle("Models")
 }
}
