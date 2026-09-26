import Foundation

enum ExportService {
    static func markdown(for c:Conversation)->String {
        var out="# \(c.title)\n\nModel: \(c.modelID)\n\n"
        if !c.systemPrompt.isEmpty { out += "## System Prompt\n\n\(c.systemPrompt)\n\n" }
        for m in c.messages.sorted(by:{$0.createdAt<$1.createdAt}) {
            out += "## \(m.role.capitalized)\n\n\(m.content)\n\n"
        }
        return out
    }
}
