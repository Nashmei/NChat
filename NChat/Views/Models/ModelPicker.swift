import SwiftUI

struct ModelPicker:View {
    @Bindable var conversation:Conversation
    @ObservedObject private var catalog=ModelCatalogStore.shared
    @State private var search=""
    var body:some View {
        Menu {
            if catalog.models.isEmpty { Button("Load NVIDIA models"){Task{await catalog.refresh()}} }
            ForEach(catalog.models.filter{search.isEmpty || $0.id.localizedCaseInsensitiveContains(search)}.prefix(80)) { model in
                Button { conversation.modelID=model.id } label:{
                    Label(model.displayName,systemImage:catalog.verified.contains(model.id) ? "checkmark.seal.fill" : "circle")
                }
            }
            Divider(); Button("Refresh models"){Task{await catalog.refresh()}}
        } label:{
            HStack(spacing:5){Text(conversation.modelID.split(separator:"/").last.map(String.init) ?? conversation.modelID).font(.subheadline).bold().lineLimit(1);Image(systemName:"chevron.down").font(.caption2)}
        }
        .task{if catalog.models.isEmpty{await catalog.refresh()}}
    }
}
