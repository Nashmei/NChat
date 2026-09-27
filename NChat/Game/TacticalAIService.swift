import Foundation

enum TacticalAIService {
    struct Request: Codable {
        let command: String
        let format: String
    }

    struct Response: Codable {
        let tactic: String
        let focusLane: Int
        let aggression: Double
        let holdPosition: Bool
        let summary: String
    }

    static func interpret(command: String, endpoint: URL) async throws -> TacticalPlan {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(Request(
            command: command,
            format: "Return a validated tactical plan only. Never decide damage, rewards, health, or winner."
        ))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        let tactic = Tactic(rawValue: decoded.tactic) ?? .balanced
        return TacticalPlan(
            tactic: tactic,
            focusLane: min(2, max(0, decoded.focusLane)),
            aggression: min(1, max(0, decoded.aggression)),
            holdPosition: decoded.holdPosition,
            summary: decoded.summary
        )
    }
}
