import SwiftUI
struct ModelPicker:View {
 @Bindable var conversation:Conversation
 @ObservedObject private var catalog=ModelCatalogStore.shared
 var body:some View {
  Menu {
   if catalog.isLoading { Text("Testing models… \(catalog.testedCount)/\(catalog.totalToTest)") }
   ForEach(catalog.passedModels){model in Button{conversation.modelID=model.id}label:{Label(model.displayName,systemImage:conversation.modelID==model.id ? "checkmark":"sparkles")}}
   Divider()
   Button("Retest all models"){Task{await catalog.refreshAndValidate()}}
  }label:{
   HStack(spacing:6){Circle().fill(NChatTheme.gradient).frame(width:8,height:8);Text(conversation.modelID.split(separator:"/").last.map(String.init) ?? conversation.modelID).font(.subheadline.weight(.semibold)).lineLimit(1);Image(systemName:"chevron.down").font(.caption2)}.foregroundStyle(.white)
  }
 }
}
