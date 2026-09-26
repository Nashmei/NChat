import Foundation
import UniformTypeIdentifiers

struct ChatAttachment:Identifiable,Hashable,Codable {
 let id:UUID
 let name:String
 let typeIdentifier:String
 let data:Data
 init(id:UUID=UUID(),name:String,typeIdentifier:String,data:Data){self.id=id;self.name=name;self.typeIdentifier=typeIdentifier;self.data=data}
 var isImage:Bool{UTType(typeIdentifier)?.conforms(to:.image)==true}
 var text:String?{String(data:data,encoding:.utf8)}
 var mimeType:String{UTType(typeIdentifier)?.preferredMIMEType ?? "application/octet-stream"}
}
