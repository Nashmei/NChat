import SwiftUI

struct ModelPicker: View {
    @Bindable var conversation: Conversation
    var body: some View {
        Menu {
            ForEach(ModelOption.featured) { model in
                Button { conversation.modelID=model.id } label: {
                    if conversation.modelID==model.id { Label(model.title,systemImage:"checkmark") } else { Text(model.title) }
                }
            }
            Divider()
            Button("Custom model…") {}
        } label: {
            HStack(spacing:5) { Text(ModelOption.featured.first(where:{$0.id==conversation.modelID})?.title ?? conversation.modelID).font(.subheadline).bold().lineLimit(1); Image(systemName:"chevron.down").font(.caption2) }
        }
    }
}
