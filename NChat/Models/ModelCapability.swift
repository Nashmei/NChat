import Foundation

enum CapabilityConfidence:String,Codable,Hashable {
 case verified
 case inferred
 case unknown
}

struct ModelCapability:Codable,Identifiable,Hashable {
 let id:String
 var displayName:String
 var passed:Bool
 var supportsArabic:Bool
 var supportsStreaming:Bool
 var supportsVision:Bool
 var supportsReasoning:Bool
 var supportsTools:Bool
 var visionConfidence:CapabilityConfidence = .unknown
 var reasoningConfidence:CapabilityConfidence = .unknown
 var toolsConfidence:CapabilityConfidence = .unknown
 var testedAt:Date
 var latencyMS:Int
 var failureReason:String?

 var badges:[String] {
  var result=["Text","Arabic"]
  if supportsVision{result.append("Vision*")}
  if supportsReasoning{result.append("Reasoning*")}
  if supportsTools{result.append("Tools*")}
  return result
 }
}

enum ModelEligibility {
 static let blockedTerms=["embed","embedding","rerank","guard","safety","moderation","reward","parse","ocr","tts","speech","asr"]
 static func isChatCandidate(_ id:String)->Bool {
  let value=id.lowercased()
  return !blockedTerms.contains(where:value.contains)
 }
 static func inferredVision(_ id:String)->Bool {
  let value=id.lowercased()
  return ["vision","vl","vlm","llava","phi-3-vision","pixtral"].contains(where:value.contains)
 }
 static func inferredReasoning(_ id:String)->Bool {
  let value=id.lowercased()
  return ["reason","thinking","qwq","r1","gpt-oss","nemotron"].contains(where:value.contains)
 }
 static func inferredTools(_ id:String)->Bool {
  let value=id.lowercased()
  return ["tool","function","instruct","chat"].contains(where:value.contains)
 }
}
