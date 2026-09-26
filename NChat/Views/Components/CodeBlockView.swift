import SwiftUI
import UIKit
struct CodeBlockView:View {
 let code:String;let language:String?;@State private var copied=false
 var body:some View{VStack(alignment:.leading,spacing:0){HStack{Text(language ?? "code").font(.caption).foregroundStyle(.secondary);Spacer();Button(copied ? "Copied":"Copy"){UIPasteboard.general.string=code;copied=true}}.padding(.horizontal,12).padding(.vertical,8).background(.quaternary);ScrollView(.horizontal,showsIndicators:false){Text(code).font(.system(.callout,design:.monospaced)).textSelection(.enabled).padding(12)}}.background(.thinMaterial,in:RoundedRectangle(cornerRadius:12)).clipShape(RoundedRectangle(cornerRadius:12))}
}
struct RichMessageText:View {
 let text:String
 var body:some View {
  let fence=String(repeating:"`",count:3);let parts=text.components(separatedBy:fence)
  VStack(alignment:.leading,spacing:10){ForEach(Array(parts.enumerated()),id:\.offset){i,p in if i % 2 == 1{let lines=p.split(separator:"\n",omittingEmptySubsequences:false);CodeBlockView(code:lines.dropFirst().joined(separator:"\n"),language:lines.first.map(String.init))}else if let a=try? AttributedString(markdown:p){Text(a).textSelection(.enabled)}}}
 }
}
