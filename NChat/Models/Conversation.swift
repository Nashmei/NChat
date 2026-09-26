import Foundation
import SwiftData

@Model final class Conversation {
    var id=UUID()
    var title:String
    var modelID:String
    var systemPrompt:String
    var createdAt=Date.now
    var updatedAt=Date.now
    var isPinned=false
    var contextBudget=32000
    @Relationship(deleteRule:.cascade,inverse:\ChatMessage.conversation) var messages:[ChatMessage]=[]
    init(title:String="New chat",modelID:String=AppSettings.defaultModel,systemPrompt:String="") {
        self.title=title; self.modelID=modelID; self.systemPrompt=systemPrompt
    }
}

@Model final class ChatMessage {
    var id=UUID()
    var role:String
    var content:String
    var reasoning:String?
    var createdAt=Date.now
    var conversation:Conversation?
    init(role:String,content:String,reasoning:String?=nil) {
        self.role=role; self.content=content; self.reasoning=reasoning
    }
}
