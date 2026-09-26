import Foundation

struct ModelCapability:Codable,Identifiable,Hashable {
    let id:String
    var displayName:String
    var passed:Bool
    var supportsArabic:Bool
    var supportsStreaming:Bool
    var testedAt:Date
    var latencyMS:Int
    var failureReason:String?
}

enum ModelEligibility {
    static let blockedTerms=["embed","embedding","rerank","guard","safety","moderation","reward","parse","ocr"]
    static func isChatCandidate(_ id:String)->Bool {
        let value=id.lowercased()
        return !blockedTerms.contains(where:value.contains)
    }
}
