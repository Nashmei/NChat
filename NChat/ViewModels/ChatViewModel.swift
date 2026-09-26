import Foundation
import SwiftData

@MainActor final class ChatViewModel:ObservableObject {
 @Published var draft=""
 @Published var isStreaming=false
 @Published var errorMessage:String?
 @Published var settings=GenerationSettings()
 @Published var attachments:[ChatAttachment]=[]
 @Published var activeAgent:String?
 private let service=NVIDIAService()
 private var task:Task<Void,Never>?

 init(){
  settings.temperature=UserDefaults.standard.object(forKey:"temperature") as? Double ?? 0.4
  settings.topP=UserDefaults.standard.object(forKey:"topP") as? Double ?? 0.9
  settings.maxTokens=UserDefaults.standard.object(forKey:"maxTokens") as? Int ?? 4096
  settings.reasoningEffort=UserDefaults.standard.string(forKey:"reasoningEffort") ?? "medium"
 }

 func send(in c:Conversation,context:ModelContext){
  let pending=attachments
  var text=draft.trimmingCharacters(in:.whitespacesAndNewlines)
  for a in pending where !a.isImage{if let t=a.text{text+="\n\n[File: \(a.name)]\n\(t)"}}
  guard !text.isEmpty || !pending.isEmpty,!isStreaming else{return}
  draft="";attachments=[]

  let catalog=ModelCatalogStore.shared
  let selected=(catalog.capabilities[c.modelID]?.passed==true) ? c.modelID : (catalog.passedModels.first?.id ?? c.modelID)
  c.modelID=selected
  let selectedCapability=catalog.capabilities[selected]

  if pending.contains(where:{$0.isImage}),selectedCapability?.supportsVision != true{
   errorMessage="The selected model is not verified for image input. Choose a model marked Vision."
   attachments=pending
   return
  }

  let user=ChatMessage(role:"user",content:text.isEmpty ? "[Image attachment]" : text);user.conversation=c
  let assistant=ChatMessage(role:"assistant",content:"");assistant.conversation=c
  context.insert(user);context.insert(assistant);c.updatedAt = .now
  if c.title=="New chat"{c.title=String(user.content.prefix(44))}

  var api=c.messages.sorted{$0.createdAt<$1.createdAt}.filter{$0.id != assistant.id}.map{APIMessage(role:$0.role,content:$0.content)}
  if let i=api.indices.last{api[i]=APIMessage(role:api[i].role,content:api[i].content,attachments:pending.filter{$0.isImage})}
  let policy=c.systemPrompt.isEmpty ? AppSettings.defaultSystemPrompt : AppSettings.defaultSystemPrompt+"\n\nUSER CUSTOM INSTRUCTIONS:\n"+c.systemPrompt
  api.insert(.init(role:"system",content:policy),at:0)
  api=ContextManager.trimmed(api,budget:c.contextBudget)
  isStreaming=true

  task=Task{
   do{
    let orchestration=OrchestrationStore.load()
    if orchestration.enabled,let agent=try? await route(text,config:orchestration,catalog:catalog){
     activeAgent=agent.name
     if let agentCap=catalog.capabilities[agent.modelID] {
      do{
       let agentPolicy=AppSettings.defaultSystemPrompt+"\n\nSPECIALIST ROLE:\n"+agent.instructions
       let result=try await service.complete(messages:[.init(role:"system",content:agentPolicy),.init(role:"user",content:text,attachments:pending.filter{$0.isImage})],modelID:agent.modelID,settings:settings,capability:agentCap)
       api.append(.init(role:"system",content:"A specialist named \(agent.name) supplied the following supporting result. Verify it and use only what is useful in the final answer:\n\(result)"))
      }catch{ }
     }
     activeAgent=nil
    }
    for try await(chunk,_)in await service.stream(messages:api,modelID:selected,settings:settings,capability:selectedCapability){assistant.content+=chunk}\n    try ResponseQualityGuard.validate(assistant.content,expectedArabic:Self.prefersArabic(text))
   }catch{
    if assistant.content.isEmpty || error is ResponseQualityGuard.QualityError {
     context.delete(assistant)
    }
    errorMessage=error.localizedDescription
   }
   activeAgent=nil;isStreaming=false;try? context.save()
  }
 }

 private func route(_ request:String,config:OrchestrationSettings,catalog:ModelCatalogStore)async throws->AgentConfiguration?{
  let active=config.agents.filter{$0.isEnabled && catalog.capabilities[$0.modelID]?.passed==true}
  guard !active.isEmpty else{return nil}
  let coordinator=(catalog.capabilities[config.coordinatorModelID]?.passed==true) ? config.coordinatorModelID : (catalog.passedModels.first?.id ?? config.coordinatorModelID)
  let labels=active.map{"\($0.name): \($0.instructions)"}.joined(separator:"\n")
  let prompt="Select at most one specialist for this request. Return only its exact name, or NONE.\n\nSPECIALISTS:\n\(labels)\n\nREQUEST:\n\(request)"
  let answer=try await service.complete(messages:[.init(role:"system",content:"You route requests to specialists. Output one exact specialist name or NONE. No explanation."),.init(role:"user",content:prompt)],modelID:coordinator,settings:settings,capability:catalog.capabilities[coordinator])
  let clean=answer.trimmingCharacters(in:.whitespacesAndNewlines)
  return active.first{clean.caseInsensitiveCompare($0.name)==.orderedSame}
 }

 func regenerate(in c:Conversation,context:ModelContext){
  if let last=c.messages.sorted(by:{$0.createdAt<$1.createdAt}).last,last.role=="assistant"{context.delete(last)}
  guard let p=c.messages.sorted(by:{$0.createdAt<$1.createdAt}).last(where:{$0.role=="user"})else{return}
  draft=p.content;context.delete(p);send(in:c,context:context)
 }
 private static func prefersArabic(_ text:String)->Bool{var ar=0;var latin=0;for s in text.unicodeScalars{if (0x0600...0x06FF).contains(s.value) || (0x0750...0x077F).contains(s.value) || (0x08A0...0x08FF).contains(s.value){ar+=1}else if (0x0041...0x005A).contains(s.value) || (0x0061...0x007A).contains(s.value){latin+=1}};return ar>0 && ar>=latin}\n func stop(){task?.cancel();activeAgent=nil;isStreaming=false}
}
