import Foundation
import SwiftData
@MainActor final class ChatViewModel:ObservableObject {
 @Published var draft="";@Published var isStreaming=false;@Published var errorMessage:String?;@Published var settings=GenerationSettings();@Published var attachments:[ChatAttachment]=[]
 private let service=NVIDIAService();private var task:Task<Void,Never>?
 init(){settings.temperature=UserDefaults.standard.object(forKey:"temperature") as? Double ?? 0.7;settings.topP=UserDefaults.standard.object(forKey:"topP") as? Double ?? 0.95;settings.maxTokens=UserDefaults.standard.object(forKey:"maxTokens") as? Int ?? 4096}
 func send(in c:Conversation,context:ModelContext){
  let pending=attachments;var text=draft.trimmingCharacters(in:.whitespacesAndNewlines)
  for a in pending where !a.isImage{if let t=a.text{text+="\n\n[File: \(a.name)]\n\(t)"}}
  guard !text.isEmpty || !pending.isEmpty,!isStreaming else{return};draft="";attachments=[]
  let user=ChatMessage(role:"user",content:text.isEmpty ? "[Image attachment]" : text);user.conversation=c;let assistant=ChatMessage(role:"assistant",content:"");assistant.conversation=c;context.insert(user);context.insert(assistant);c.updatedAt = .now;if c.title=="New chat"{c.title=String(user.content.prefix(44))}
  var api=c.messages.sorted{$0.createdAt<$1.createdAt}.filter{$0.id != assistant.id}.map{APIMessage(role:$0.role,content:$0.content)}
  if let i=api.indices.last{api[i]=APIMessage(role:api[i].role,content:api[i].content,attachments:pending.filter{$0.isImage})}
  if !c.systemPrompt.isEmpty{api.insert(.init(role:"system",content:c.systemPrompt),at:0)};api=ContextManager.trimmed(api,budget:c.contextBudget);isStreaming=true
  task=Task{do{let o=OrchestrationStore.load();if o.enabled,let agent=try await route(text,config:o){let r=try await service.complete(messages:[.init(role:"system",content:agent.instructions),.init(role:"user",content:text,attachments:pending.filter{$0.isImage})],modelID:agent.modelID,settings:settings);api.append(.init(role:"system",content:"Specialist \(agent.name) returned:\n\(r)\nUse this result to answer accurately."))}
   for try await(chunk,reasoning)in await service.stream(messages:api,modelID:c.modelID,settings:settings){assistant.content+=chunk;if let reasoning{assistant.reasoning=(assistant.reasoning ?? "")+reasoning}}
  }catch{errorMessage=error.localizedDescription};isStreaming=false;try? context.save()}
 }
 private func route(_ request:String,config:OrchestrationSettings)async throws->AgentConfiguration?{let active=config.agents.filter{$0.isEnabled};guard !active.isEmpty else{return nil};let names=active.map{$0.name}.joined(separator:", ");let p="Choose one specialist only if useful. Available: \(names). Return exactly its name or NONE. Request: \(request)";let x=try await service.complete(messages:[.init(role:"system",content:"You are a routing controller. Output only one label."),.init(role:"user",content:p)],modelID:config.coordinatorModelID);return active.first{x.localizedCaseInsensitiveContains($0.name)}}
 func regenerate(in c:Conversation,context:ModelContext){if let last=c.messages.sorted(by:{$0.createdAt<$1.createdAt}).last,last.role=="assistant"{context.delete(last)};guard let p=c.messages.sorted(by:{$0.createdAt<$1.createdAt}).last(where:{$0.role=="user"})else{return};draft=p.content;context.delete(p);send(in:c,context:context)}
 func stop(){task?.cancel();isStreaming=false}
}
