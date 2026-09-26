import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack { if message.role=="assistant" { content; Spacer(minLength:30) } else { Spacer(minLength:30); content } }
    }
    private var content: some View {
        VStack(alignment:.leading,spacing:8) {
            if let reasoning=message.reasoning,!reasoning.isEmpty {
                DisclosureGroup("Reasoning") { Text(reasoning).font(.caption).foregroundStyle(.secondary).textSelection(.enabled) }
            }
            if let attributed=try? AttributedString(markdown:message.content) { Text(attributed).textSelection(.enabled) }
            else { Text(message.content).textSelection(.enabled) }
        }
        .padding(message.role=="user" ? 12 : 0)
        .background(message.role=="user" ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear),in:RoundedRectangle(cornerRadius:18))
    }
}
