import SwiftUI

struct MessageBubble:View {
 let message:ChatMessage
 private var isAssistant:Bool{message.role=="assistant"}

 var body:some View {
  HStack(alignment:.top,spacing:10) {
   if isAssistant {
    avatar
    content
    Spacer(minLength:18)
   } else {
    Spacer(minLength:38)
    content
   }
  }
  .accessibilityElement(children:.contain)
 }

 private var avatar:some View {
  ZStack {
   Circle().fill(NChatTheme.gradient)
   Image(systemName:"sparkles").font(.caption.bold()).foregroundStyle(.white)
  }
  .frame(width:30,height:30)
  .shadow(color:NChatTheme.purple.opacity(0.28),radius:12,y:5)
  .accessibilityHidden(true)
 }

 private var content:some View {
  RichMessageText(text:message.content)
   .foregroundStyle(NChatTheme.text)
   .padding(.horizontal,isAssistant ? 0:15)
   .padding(.vertical,isAssistant ? 2:12)
   .background(isAssistant ? AnyShapeStyle(.clear):AnyShapeStyle(NChatTheme.elevated.opacity(0.95)),in:RoundedRectangle(cornerRadius:20,style:.continuous))
   .overlay {
    if !isAssistant {
     RoundedRectangle(cornerRadius:20,style:.continuous).stroke(NChatTheme.border)
    }
   }
   .environment(\.layoutDirection,preferredDirection)
 }

 private var preferredDirection:LayoutDirection {
  let arabic=message.content.unicodeScalars.filter{(0x0600...0x06FF).contains($0.value)}.count
  let latin=message.content.unicodeScalars.filter{(0x0041...0x005A).contains($0.value)||(0x0061...0x007A).contains($0.value)}.count
  return arabic>latin ? .rightToLeft:.leftToRight
 }
}
