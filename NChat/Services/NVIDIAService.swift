import Foundation

struct APIMessage: Codable {
    let role: String
    let content: String
    var attachments: [ChatAttachment] = []

    init(role: String, content: String, attachments: [ChatAttachment] = []) {
        self.role = role
        self.content = content
        self.attachments = attachments
    }
}

private struct StreamEnvelope: Decodable {
    struct Choice: Decodable {
        struct Delta: Decodable {
            let content: String?
            let reasoning_content: String?
        }
        let delta: Delta
    }
    let choices: [Choice]
}

enum NVIDIAServiceError: LocalizedError {
    case authentication
    case unsupportedVision
    case rateLimited
    case badResponse(Int, String?)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .authentication:
            return "NVIDIA API key is missing or invalid."
        case .unsupportedVision:
            return "This model does not support image input. Choose a Vision model."
        case .rateLimited:
            return "NVIDIA rate limit reached. Wait a moment and try again."
        case .badResponse(let code, let detail):
            if let detail, !detail.isEmpty {
                return "NVIDIA returned HTTP \(code): \(detail)"
            }
            return "NVIDIA returned HTTP \(code)."
        case .emptyResponse:
            return "The model returned an empty response."
        }
    }
}

actor NVIDIAService {
    func stream(
        messages: [APIMessage],
        modelID: String,
        settings: GenerationSettings,
        capability: ModelCapability? = nil
    ) -> AsyncThrowingStream<(String, String?), Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let key = KeychainStore.read()
                    guard !key.isEmpty else {
                        throw NVIDIAServiceError.authentication
                    }

                    let hasImages = messages.contains {
                        $0.attachments.contains(where: { $0.isImage })
                    }
                    if hasImages, capability?.supportsVision == false {
                        throw NVIDIAServiceError.unsupportedVision
                    }

                    var request = URLRequest(url: URL(string: AppSettings.endpoint)!)
                    request.httpMethod = "POST"
                    request.timeoutInterval = 60
                    request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

                    let wire: [[String: Any]] = messages.map { message in
                        let images = message.attachments.filter { $0.isImage }
                        if images.isEmpty {
                            return ["role": message.role, "content": message.content]
                        }

                        var parts: [[String: Any]] = [
                            ["type": "text", "text": message.content]
                        ]
                        for image in images {
                            parts.append([
                                "type": "image_url",
                                "image_url": [
                                    "url": "data:\(image.mimeType);base64,\(image.data.base64EncodedString())"
                                ]
                            ])
                        }
                        return ["role": message.role, "content": parts]
                    }

                    var body: [String: Any] = [
                        "model": modelID,
                        "messages": wire,
                        "stream": true,
                        "max_tokens": settings.maxTokens,
                        "temperature": min(max(settings.temperature, 0.05), 0.95),
                        "top_p": min(max(settings.topP, 0.1), 1.0)
                    ]

                    if capability?.supportsReasoning == true,
                       modelID.lowercased().contains("gpt-oss") {
                        body["reasoning_effort"] = settings.reasoningEffort
                    }

                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let http = response as? HTTPURLResponse else {
                        throw NVIDIAServiceError.badResponse(-1, nil)
                    }

                    if http.statusCode == 401 || http.statusCode == 403 {
                        throw NVIDIAServiceError.authentication
                    }
                    if http.statusCode == 429 {
                        throw NVIDIAServiceError.rateLimited
                    }
                    guard (200..<300).contains(http.statusCode) else {
                        throw NVIDIAServiceError.badResponse(http.statusCode, nil)
                    }

                    var produced = false
                    for try await line in bytes.lines {
                        try Task.checkCancellation()
                        guard line.hasPrefix("data: ") else { continue }

                        let payload = String(line.dropFirst(6))
                        if payload == "[DONE]" { break }

                        guard let data = payload.data(using: .utf8),
                              let envelope = try? JSONDecoder().decode(StreamEnvelope.self, from: data),
                              let delta = envelope.choices.first?.delta else {
                            continue
                        }

                        let clean = Self.clean(delta.content ?? "")
                        if !clean.isEmpty {
                            produced = true
                            continuation.yield((clean, nil))
                        }
                    }

                    if !produced {
                        throw NVIDIAServiceError.emptyResponse
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func complete(
        messages: [APIMessage],
        modelID: String,
        settings: GenerationSettings = GenerationSettings(),
        capability: ModelCapability? = nil
    ) async throws -> String {
        var result = ""
        let stream = stream(
            messages: messages,
            modelID: modelID,
            settings: settings,
            capability: capability
        )
        for try await (chunk, _) in stream {
            result += chunk
        }
        return result
    }

    func qualityProbe(modelID: String) async throws -> String {
        var settings = GenerationSettings()
        settings.temperature = 0.2
        settings.topP = 0.7
        settings.maxTokens = 32
        return try await complete(
            messages: [
                .init(
                    role: "user",
                    content: "Return exactly this text and nothing else: مرحبا NCHAT"
                )
            ],
            modelID: modelID,
            settings: settings
        )
    }

    func probe(modelID: String) async throws {
        _ = try await qualityProbe(modelID: modelID)
    }

    nonisolated private static func clean(_ text: String) -> String {
        text.replacingOccurrences(of: "\u{FFFD}", with: "")
    }
}
