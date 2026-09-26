import Foundation

enum ContextManager {
 static func estimatedTokens(_ messages:[APIMessage])->Int {
  messages.reduce(0){$0+estimatedTokens($1.content)}
 }
 static func estimatedTokens(_ text:String)->Int {
  guard !text.isEmpty else{return 0}
  let scalars=text.unicodeScalars.count
  let words=text.split(whereSeparator:{ $0.isWhitespace }).count
  return max(1,Int(Double(scalars)*0.28)+Int(Double(words)*0.35))
 }

 static func trimmed(_ messages:[APIMessage],budget:Int)->[APIMessage] {
  guard !messages.isEmpty else{return []}
  let safeBudget=max(1024,budget)
  let system=messages.first?.role=="system" ? messages.first : nil
  let history=system == nil ? messages:Array(messages.dropFirst())
  let systemCost=system.map{estimatedTokens($0.content)} ?? 0
  let historyBudget=max(256,safeBudget-systemCost)
  var kept:[APIMessage]=[]
  var used=0

  for message in history.reversed() {
   let cost=max(1,estimatedTokens(message.content))
   if used+cost>historyBudget {
    if kept.isEmpty { kept.insert(message,at:0) }
    break
   }
   kept.insert(message,at:0)
   used+=cost
  }

  if let system{return [system]+kept}
  return kept
 }
}
