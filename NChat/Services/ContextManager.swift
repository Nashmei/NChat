import Foundation

enum ContextManager {
    static func estimatedTokens(_ messages:[APIMessage])->Int {
        max(1,messages.reduce(0){$0+$1.content.count}/4)
    }
    static func trimmed(_ messages:[APIMessage],budget:Int)->[APIMessage] {
        guard estimatedTokens(messages)>budget else{return messages}
        var result:[APIMessage]=[]; var used=0
        for m in messages.reversed() {
            let cost=max(1,m.content.count/4)
            if used+cost>budget { break }
            result.insert(m,at:0); used+=cost
        }
        if let system=messages.first,system.role=="system",result.first?.role != "system" { result.insert(system,at:0) }
        return result
    }
}
