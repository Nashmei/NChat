import SwiftUI
struct MessageBubble:View {
 let message:ChatMessage
 var body:some View{HStack{if message.role=="assistant"{content;Spacer(minLength:24)}else{Spacer(minLength:24);content}}}
 private var content:some View{VStack(alignment:.leading,spacing:10){if let r=message.reasoning,!r.isEmpty{DisclosureGroup("Reasoning"){Text(r).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)}};RichMessageText(text:message.content)}.padding(message.role=="user" ? 12:0).background(message.role=="user" ? AnyShapeStyle(.thinMaterial):AnyShapeStyle(.clear),in:RoundedRectangle(cornerRadius:18))}
}
