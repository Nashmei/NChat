import Foundation
import UniformTypeIdentifiers

struct ChatAttachment: Identifiable, Hashable {
    let id=UUID()
    let name:String
    let typeIdentifier:String
    let data:Data
    var isImage:Bool { UTType(typeIdentifier)?.conforms(to:.image) == true }
    var text:String? { String(data:data,encoding:.utf8) }
}
