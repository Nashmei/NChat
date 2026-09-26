import Foundation

struct APIMessage:Codable { let role:String; let content:String }
private struct StreamEnvelope:Decodable {
    struct Choice:Decodable { struct Delta:Decodable { let content:String?; let reasoning_content:String? }; let delta:Delta }
    let choices:[Choice]
}

actor NVIDIAService {
    func stream(messages:[APIMessage],modelID:String,settings:GenerationSettings) -> AsyncThrowingStream<(String,String?),Error> {
        AsyncThrowingStream { continuation in
            let task=Task {
                do {
                    let key=KeychainStore.read(); guard !key.isEmpty else { throw URLError(.userAuthenticationRequired) }
                    var req=URLRequest(url:URL(string:AppSettings.endpoint)!)
                    req.httpMethod="POST"; req.setValue("Bearer \(key)",forHTTPHeaderField:"Authorization")
                    req.setValue("application/json",forHTTPHeaderField:"Content-Type"); req.setValue("text/event-stream",forHTTPHeaderField:"Accept")
                    let body:[String:Any]=["model":modelID,"messages":messages.map{["role":$0.role,"content":$0.content]},"stream":true,"temperature":settings.temperature,"top_p":settings.topP,"max_tokens":settings.maxTokens]
                    req.httpBody=try JSONSerialization.data(withJSONObject:body)
                    let (bytes,response)=try await URLSession.shared.bytes(for:req)
                    guard let h=response as? HTTPURLResponse,(200..<300).contains(h.statusCode) else { throw URLError(.badServerResponse) }
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let p=String(line.dropFirst(6)); if p=="[DONE]" { break }
                        guard let d=p.data(using:.utf8),let e=try? JSONDecoder().decode(StreamEnvelope.self,from:d),let x=e.choices.first?.delta else { continue }
                        continuation.yield((x.content ?? "",x.reasoning_content))
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing:error) }
            }
            continuation.onTermination={_ in task.cancel()}
        }
    }

    func complete(messages:[APIMessage],modelID:String,settings:GenerationSettings=GenerationSettings()) async throws -> String {
        var result=""
        for try await (chunk,_) in stream(messages:messages,modelID:modelID,settings:settings) { result += chunk }
        return result
    }

    func probe(modelID:String) async throws {
        var s=GenerationSettings(); s.temperature=0; s.maxTokens=1
        _ = try await complete(messages:[.init(role:"user",content:"Reply OK")],modelID:modelID,settings:s)
    }
}
