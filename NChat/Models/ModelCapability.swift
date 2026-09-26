import Foundation

struct ModelCapability:Codable,Identifiable,Hashable {
 let id:String
 var displayName:String
 var passed:Bool
 var supportsArabic:Bool
 var supportsStreaming:Bool
 var supportsVision:Bool
 var supportsReasoning:Bool
 var supportsTools:Bool
 var testedAt:Date
 var latencyMS:Int
 var failureReason:String?
 var badges:[String] {
  var x=["Text"]
  if supportsVision{x.append("Vision")}
  if supportsReasoning{x.append("Reasoning")}
  if supportsTools{x.append("Tools")}
  if supportsArabic{x.append("Arabic")}
  return x
 }
}

enum ModelEligibility {
 static let blockedTerms=["embed","embedding","rerank","guard","safety","moderation","reward","parse","ocr"]
 static func isChatCandidate(_ id:String)->Bool{let value=id.lowercased();return !blockedTerms.contains(where:value.contains)}
 static func inferredVision(_ id:String)->Bool{let v=id.lowercased();return ["vision","vl","vlm","llava","phi-3-vision","pixtral"].contains(where:v.contains)}
 static func inferredReasoning(_ id:String)->Bool{let v=id.lowercased();return ["reason","thinking","qwq","r1","gpt-oss","nemotron"].contains(where:v.contains)}
 static func inferredTools(_ id:String)->Bool{let v=id.lowercased();return !["vision-only","embed","rerank"].contains(where:v.contains)}
}
