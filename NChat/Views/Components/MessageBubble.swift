import SwiftUI
struct MessageBubble:View {
 let message:ChatMessage
 var body:some View{HStack(alignment:.bottom,spacing:10){if message.role=="assistant"{avatar;content;Spacer(minLength:26)}else{Spacer(minLength:40);content}}}
 private var avatar:some View{ZStack{Circle().fill(NChatTheme.gradient);Image(systemName:"sparkles").font(.caption.bold()).foregroundStyle(.white)}.frame(width:28,height:28)}
 private var content:some View{RichMessageText(text:message.content).foregroundStyle(NChatTheme.text).padding(message.role=="user" ? 13:0).background(message.role=="user" ? AnyShapeStyle(NChatTheme.elevated):AnyShapeStyle(.clear),in:RoundedRectangle(cornerRadius:18,style:.continuous))}
}
