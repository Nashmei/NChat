import Foundation

struct APIMessage: Codable { let role: String; let content: String }
private struct StreamEnvelope: Decodable {
    struct Choice: Decodable {
        struct Delta: Decodable { let content: String?; let reasoning_content: String? }
        let delta: Delta
    }
    let choices: [Choice]
}

actor NVIDIAService {
    func stream(messages: [APIMessage], model: ModelOption, settings: GenerationSettings) -> AsyncThrowingStream<(String,String?), Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let key = KeychainStore.read()
                    guard !key.isEmpty else { throw URLError(.userAuthenticationRequired) }
                    var req = URLRequest(url: URL(string: AppSettings.endpoint)!)
                    req.httpMethod = "POST"
                    req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    var body: [String:Any] = ["model":model.id,"messages":messages.map{["role":$0.role,"content":$0.content]},"stream":true,"temperature":settings.temperature,"top_p":settings.topP,"max_tokens":settings.maxTokens]
                    if model.supportsReasoning { body["reasoning_effort"] = settings.reasoningEffort }
                    req.httpBody = try JSONSerialization.data(withJSONObject: body)
                    let (bytes,response) = try await URLSession.shared.bytes(for:req)
                    guard let http=response as? HTTPURLResponse,(200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let payload=String(line.dropFirst(6)); if payload=="[DONE]" { break }
                        guard let d=payload.data(using:.utf8),let e=try? JSONDecoder().decode(StreamEnvelope.self,from:d),let x=e.choices.first?.delta else { continue }
                        continuation.yield((x.content ?? "",x.reasoning_content))
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing:error) }
            }
            continuation.onTermination={ _ in task.cancel() }
        }
    }
}
