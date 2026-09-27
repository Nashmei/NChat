import Foundation

enum OnlineServiceError: LocalizedError {
    case notConfigured
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Online backend is not configured."
        case .invalidResponse: return "Invalid server response."
        case .server(let message): return message
        }
    }
}

struct MatchTicket: Codable {
    let ticketID: String
    let status: String
    let websocketURL: String?
}

actor OnlineService {
    static let shared = OnlineService()

    func requestMatch(baseURL: String, token: String, rating: Int, mode: GameMode) async throws -> MatchTicket {
        guard let base = URL(string: baseURL), !baseURL.isEmpty else { throw OnlineServiceError.notConfigured }
        let url = base.appendingPathComponent("v1/matchmaking")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !token.isEmpty { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["rating": rating, "mode": mode.rawValue])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw OnlineServiceError.invalidResponse }
        guard 200..<300 ~= http.statusCode else { throw OnlineServiceError.server("Server returned \(http.statusCode).") }
        return try JSONDecoder().decode(MatchTicket.self, from: data)
    }
}
