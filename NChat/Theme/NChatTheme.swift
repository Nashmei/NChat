import SwiftUI

enum NChatTheme {
    static let background=Color(red:7/255,green:4/255,blue:11/255)
    static let surface=Color(red:20/255,green:14/255,blue:28/255)
    static let elevated=Color(red:31/255,green:21/255,blue:43/255)
    static let purple=Color(red:105/255,green:71/255,blue:136/255)
    static let violet=Color(red:59/255,green:37/255,blue:104/255)
    static let pink=Color(red:194/255,green:117/255,blue:149/255)
    static let text=Color.white
    static let secondary=Color.white.opacity(0.58)
    static let border=Color.white.opacity(0.09)
    static let gradient=LinearGradient(colors:[purple,pink],startPoint:.topLeading,endPoint:.bottomTrailing)
}

struct NChatCard:ViewModifier {
    func body(content:Content)->some View {
        content.padding(14).background(NChatTheme.surface,in:RoundedRectangle(cornerRadius:20,style:.continuous)).overlay(RoundedRectangle(cornerRadius:20,style:.continuous).stroke(NChatTheme.border))
    }
}
extension View { func nchatCard()->some View{modifier(NChatCard())} }
