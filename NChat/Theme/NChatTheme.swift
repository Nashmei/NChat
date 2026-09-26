import SwiftUI

enum NChatTheme {
 static let background=Color(red:7/255,green:4/255,blue:11/255)
 static let backgroundTop=Color(red:18/255,green:10/255,blue:27/255)
 static let surface=Color(red:20/255,green:14/255,blue:28/255)
 static let elevated=Color(red:31/255,green:21/255,blue:43/255)
 static let purple=Color(red:105/255,green:71/255,blue:136/255)
 static let violet=Color(red:59/255,green:37/255,blue:104/255)
 static let pink=Color(red:194/255,green:117/255,blue:149/255)
 static let text=Color.white
 static let secondary=Color.white.opacity(0.62)
 static let tertiary=Color.white.opacity(0.38)
 static let border=Color.white.opacity(0.09)
 static let strongBorder=Color.white.opacity(0.15)
 static let gradient=LinearGradient(colors:[purple,pink],startPoint:.topLeading,endPoint:.bottomTrailing)
 static let pageGradient=LinearGradient(colors:[backgroundTop,background],startPoint:.top,endPoint:.center)

 static let cardRadius:CGFloat=22
 static let controlRadius:CGFloat=18
}

struct NChatPageBackground:View {
 var body:some View {
  ZStack {
   NChatTheme.pageGradient
   Circle().fill(NChatTheme.purple.opacity(0.16)).frame(width:320,height:320).blur(radius:80).offset(x:150,y:-260)
   Circle().fill(NChatTheme.pink.opacity(0.08)).frame(width:260,height:260).blur(radius:90).offset(x:-170,y:330)
  }.ignoresSafeArea()
 }
}

struct NChatCard:ViewModifier {
 var padding:CGFloat=16
 func body(content:Content)->some View {
  content
   .padding(padding)
   .background(NChatTheme.surface.opacity(0.94),in:RoundedRectangle(cornerRadius:NChatTheme.cardRadius,style:.continuous))
   .overlay(RoundedRectangle(cornerRadius:NChatTheme.cardRadius,style:.continuous).stroke(NChatTheme.border))
 }
}

extension View {
 func nchatCard(padding:CGFloat=16)->some View{modifier(NChatCard(padding:padding))}
}
