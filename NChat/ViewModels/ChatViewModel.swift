import Foundation
import SwiftData

@MainActor final class ChatViewModel: ObservableObject {
    @Published var draft = ""
    @Published var isStreaming = false
    @Published var errorMessage: String?
    @Published var settings = GenerationSettings()
    private let service = NVIDIAService()
    private var task: Task<Void,Never>?

    func send(in conversation: Conversation, context: ModelContext) {
        let text=draft.trimmingCharacters(in:.whitespacesAndNewlines)
        guard !text.isEmpty,!isStreaming else { return }
        draft=""; let user=ChatMessage(role:"user",content:text); user.conversation=conversation
        let assistant=ChatMessage(role:"assistant",content:""); assistant.conversation=conversation
        context.insert(user); context.insert(assistant); conversation.updatedAt = .now
        if conversation.title=="New chat" { conversation.title=String(text.prefix(44)) }
        let history=conversation.messages.sorted{$0.createdAt<$1.createdAt}.filter{$0.id != assistant.id}.map{APIMessage(role:$0.role,content:$0.content)}
        var api:[APIMessage]=[]; if !conversation.systemPrompt.isEmpty { api.append(.init(role:"system",content:conversation.systemPrompt)) }; api += history
        let model=ModelOption.featured.first(where:{$0.id==conversation.modelID}) ?? ModelOption(id:conversation.modelID,title:conversation.modelID,supportsReasoning:false)
        isStreaming=true
        task=Task {
            do {
                for try await (chunk,reasoning) in await service.stream(messages:api,model:model,settings:settings) {
                    assistant.content += chunk
                    if let reasoning { assistant.reasoning=(assistant.reasoning ?? "")+reasoning }
                }
            } catch { errorMessage=error.localizedDescription }
            isStreaming=false; try? context.save()
        }
    }
    func stop() { task?.cancel(); isStreaming=false }
}
