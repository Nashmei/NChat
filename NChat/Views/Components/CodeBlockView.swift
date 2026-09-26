import SwiftUI
import UIKit

struct CodeBlockView:View {
 let code:String
 let language:String?
 @State private var copied=false

 var body:some View {
  VStack(alignment:.leading,spacing:0) {
   HStack(spacing:8) {
    Image(systemName:"chevron.left.forwardslash.chevron.right")
    Text((language?.isEmpty==false ? language:"Code") ?? "Code").fontWeight(.medium)
    Spacer()
    Button {
     UIPasteboard.general.string=code
     copied=true
     UIImpactFeedbackGenerator(style:.light).impactOccurred()
     Task {
      try? await Task.sleep(for:.seconds(1.5))
      copied=false
     }
    } label:{
     Label(copied ? "Copied":"Copy",systemImage:copied ? "checkmark":"doc.on.doc")
    }
    .buttonStyle(.plain)
   }
   .font(.caption)
   .foregroundStyle(NChatTheme.secondary)
   .padding(.horizontal,12)
   .padding(.vertical,9)
   .background(NChatTheme.elevated)

   ScrollView(.horizontal,showsIndicators:false) {
    Text(code)
     .font(.system(.callout,design:.monospaced))
     .foregroundStyle(.white.opacity(0.92))
     .textSelection(.enabled)
     .padding(13)
     .frame(maxWidth:.infinity,alignment:.leading)
   }
   .environment(\.layoutDirection,.leftToRight)
  }
  .background(Color.black.opacity(0.28),in:RoundedRectangle(cornerRadius:14,style:.continuous))
  .clipShape(RoundedRectangle(cornerRadius:14,style:.continuous))
  .overlay(RoundedRectangle(cornerRadius:14,style:.continuous).stroke(NChatTheme.border))
 }

}

struct RichMessageText:View {
 let text:String

 var body:some View {
  let fence=String(repeating:"`",count:3)
  let parts=text.components(separatedBy:fence)
  VStack(alignment:.leading,spacing:11) {
   ForEach(Array(parts.enumerated()),id:\.offset) { index,part in
    if index % 2 == 1 {
     let lines=part.split(separator:"\n",omittingEmptySubsequences:false)
     let first=lines.first.map(String.init) ?? ""
     let language=first.trimmingCharacters(in:.whitespacesAndNewlines)
     CodeBlockView(code:lines.dropFirst().joined(separator:"\n"),language:language.isEmpty ? nil:language)
      .environment(\.layoutDirection,.leftToRight)
    } else if !part.isEmpty,let attributed=try? AttributedString(markdown:part) {
     Text(attributed)
      .textSelection(.enabled)
      .frame(maxWidth:.infinity,alignment:.leading)
    }
   }
  }
 }
}
