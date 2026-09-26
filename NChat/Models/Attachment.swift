import Foundation
import UniformTypeIdentifiers

struct ChatAttachment:Identifiable,Hashable,Codable {
 let id:UUID
 let name:String
 let typeIdentifier:String
 let data:Data

 init(id:UUID=UUID(),name:String,typeIdentifier:String,data:Data){
  self.id=id;self.name=name;self.typeIdentifier=typeIdentifier;self.data=data
 }

 var type:UTType?{UTType(typeIdentifier)}
 var isImage:Bool{type?.conforms(to:.image)==true}
 var isPlainText:Bool{
  guard let type else{return false}
  return type.conforms(to:.plainText) || type.conforms(to:.json) || type.conforms(to:.commaSeparatedText)
 }
 var text:String?{
  guard isPlainText else{return nil}
  return String(data:data,encoding:.utf8)
 }
 var mimeType:String{type?.preferredMIMEType ?? "application/octet-stream"}
 var sizeDescription:String{ByteCountFormatter.string(fromByteCount:Int64(data.count),countStyle:.file)}
}
