import Foundation

struct APIMessage:Codable {
 let role:String
 let content:String
 var attachments:[ChatAttachment]=[]
 init(role:String,content:String,attachments:[ChatAttachment]=[]){self.role=role;self.content=content;self.attachments=attachments}
}
private struct StreamEnvelope:Decodable {
 struct Choice:Decodable{struct Delta:Decodable{let content:String?;let reasoning_content:String?};let delta:Delta}
 let choices:[Choice]
}
enum NVIDIAServiceError:LocalizedError {
 case authentication,unsupportedVision,rateLimited,badResponse(Int,String?),emptyResponse
 var errorDescription:String? {
  switch self {
  case .authentication:return "NVIDIA API key is missing or invalid."
  case .unsupportedVision:return "This model does not support image input. Choose a Vision model."
  case .badResponse(let code):return "NVIDIA returned HTTP \(code)."
  case .emptyResponse:return "The model returned an empty response."
  }
 }
}

actor NVIDIAService {
 func stream(messages:[APIMessage],modelID:String,settings:GenerationSettings,capability:ModelCapability?=nil)->AsyncThrowingStream<(String,String?),Error>{
  AsyncThrowingStream{continuation in
   let task=Task{do{
    let key=KeychainStore.read();guard !key.isEmpty else{throw NVIDIAServiceError.authentication}
    let hasImages=messages.contains{$0.attachments.contains(where:{$0.isImage})}
    if hasImages,capability?.supportsVision == false{throw NVIDIAServiceError.unsupportedVision}
    var req=URLRequest(url:URL(string:AppSettings.endpoint)!)
    req.httpMethod="POST";req.timeoutInterval=60
    req.setValue("Bearer \(key)",forHTTPHeaderField:"Authorization")
    req.setValue("application/json",forHTTPHeaderField:"Content-Type")
    req.setValue("text/event-stream",forHTTPHeaderField:"Accept")
    let wire:[[String:Any]]=messages.map{m in
     let images=m.attachments.filter{$0.isImage}
     if images.isEmpty{return["role":m.role,"content":m.content]}
     var parts:[[String:Any]]=[["type":"text","text":m.content]]
     for image in images{parts.append(["type":"image_url","image_url":["url":"data:\(image.mimeType);base64,\(image.data.base64EncodedString())"]])}
     return["role":m.role,"content":parts]
    }
    var body:[String:Any]=["model":modelID,"messages":wire,"stream":true,"max_tokens":settings.maxTokens]
    body["temperature"]=min(max(settings.temperature,0.05),0.95)
    body["top_p"]=min(max(settings.topP,0.1),1.0)
    if capability?.supportsReasoning==true,modelID.lowercased().contains("gpt-oss"){body["reasoning_effort"]=settings.reasoningEffort}
    req.httpBody=try JSONSerialization.data(withJSONObject:body)
    let(bytes,response)=try await URLSession.shared.bytes(for:req)
    guard let h=response as? HTTPURLResponse else{throw NVIDIAServiceError.badResponse(-1)}
    guard (200..<300).contains(h.statusCode)else{throw NVIDIAServiceError.badResponse(h.statusCode)}
    var produced=false
    for try await line in bytes.lines {
     guard line.hasPrefix("data: ")else{continue}
     let payload=String(line.dropFirst(6));if payload=="[DONE]"{break}
     guard let d=payload.data(using:.utf8),let envelope=try? JSONDecoder().decode(StreamEnvelope.self,from:d),let delta=envelope.choices.first?.delta else{continue}
     let clean=Self.clean(delta.content ?? "")
     if !clean.isEmpty{produced=true;continuation.yield((clean,nil))}
    }
    if !produced{throw NVIDIAServiceError.emptyResponse}
    continuation.finish()
   }catch{continuation.finish(throwing:error)}}
   continuation.onTermination={_ in task.cancel()}
  }
 }
 func complete(messages:[APIMessage],modelID:String,settings:GenerationSettings=GenerationSettings(),capability:ModelCapability?=nil)async throws->String{
  var result=""
  for try await(chunk,_)in stream(messages:messages,modelID:modelID,settings:settings,capability:capability){result+=chunk}
  return result
 }
 func qualityProbe(modelID:String)async throws->String{
  var s=GenerationSettings();s.temperature=0.2;s.topP=0.7;s.maxTokens=32
  return try await complete(messages:[.init(role:"user",content:"Return exactly this text and nothing else: مرحبا NCHAT")],modelID:modelID,settings:s)
 }
 func probe(modelID:String)async throws{_=try await qualityProbe(modelID:modelID)}
 nonisolated private static func clean(_ text:String)->String{text.replacingOccurrences(of:"\u{FFFD}",with:"")}
}
