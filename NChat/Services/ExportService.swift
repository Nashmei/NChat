import Foundation

enum ExportService {
 static func markdown(for conversation:Conversation)->String {
  var output="# \(conversation.title)\n\n"
  output+="> Exported from NChat · \(Date.now.formatted(date:.abbreviated,time:.shortened))\n\n"
  output+="**Model:** `\(conversation.modelID)`\n\n---\n\n"

  for message in conversation.messages.sorted(by:{$0.createdAt<$1.createdAt}) {
   let heading=message.role=="user" ? "You":"NChat"
   output+="## \(heading)\n\n\(message.content)\n\n"
  }
  return output
 }
}
