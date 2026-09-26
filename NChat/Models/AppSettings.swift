import Foundation

enum AppSettings {
    static let endpoint = "https://integrate.api.nvidia.com/v1/chat/completions"
    static let defaultModel = "nvidia/nemotron-3-super-120b-a12b"
}

struct GenerationSettings: Codable, Equatable {
    var temperature = 0.7
    var topP = 0.95
    var maxTokens = 4096
    var reasoningEffort = "medium"
}

struct ModelOption: Identifiable, Hashable {
    let id: String
    let title: String
    let supportsReasoning: Bool
    static let featured: [ModelOption] = [
        .init(id: "nvidia/nemotron-3-super-120b-a12b", title: "Nemotron 3 Super 120B", supportsReasoning: true),
        .init(id: "openai/gpt-oss-120b", title: "GPT-OSS 120B", supportsReasoning: true),
        .init(id: "qwen/qwen3-next-80b-a3b-thinking", title: "Qwen 3 Next Thinking", supportsReasoning: true),
        .init(id: "qwen/qwen3-next-80b-a3b-instruct", title: "Qwen 3 Next Instruct", supportsReasoning: false),
        .init(id: "meta/llama-3.3-70b-instruct", title: "Llama 3.3 70B", supportsReasoning: false)
    ]
}
