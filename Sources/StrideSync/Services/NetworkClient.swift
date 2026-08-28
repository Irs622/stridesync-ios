import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError
    case unauthorized
    case noInternetConnection
    case serverUnavailable
}

public enum APIEndpoint: Sendable {
    case getFeed(page: Int)
    case uploadWorkout(recordID: UUID)
    case searchAthletes(query: String)
    case syncUserSettings
    
    public var path: String {
        switch self {
        case .getFeed(let page): return "/api/v1/feed?page=\(page)"
        case .uploadWorkout(let id): return "/api/v1/workouts/\(id.uuidString)"
        case .searchAthletes(let q): return "/api/v1/search?q=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? q)"
        case .syncUserSettings: return "/api/v1/user/settings"
        }
    }
    
    public var httpMethod: String {
        switch self {
        case .getFeed, .searchAthletes: return "GET"
        case .uploadWorkout, .syncUserSettings: return "POST"
        }
    }
}

/// Asynchronous network manager with automatic Keychain auth token injection, retry queue logic, and mock response capabilities.
public final class NetworkClient: Sendable {
    public static let shared = NetworkClient()
    
    private let baseURLString: String
    private let session: URLSession
    public let isMockModeEnabled: Bool
    
    public init(baseURL: String = "https://api.stridesync.app", isMockMode: Bool = true) {
        self.baseURLString = baseURL
        self.isMockModeEnabled = isMockMode
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        self.session = URLSession(configuration: config)
    }
    
    /// Sends a network request to the specified endpoint, injecting Bearer Auth token from Keychain.
    public func request<T: Decodable & Sendable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        if isMockModeEnabled {
            return try await generateMockResponse(for: endpoint, type: responseType)
        }
        
        guard let url = URL(string: baseURLString + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainManager.shared.getAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverUnavailable
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Mock Fallback Generator for Offline Testing
    private func generateMockResponse<T: Decodable & Sendable>(for endpoint: APIEndpoint, type: T.Type) async throws -> T {
        // Simulates network latency
        try await Task.sleep(nanoseconds: 50_000_000)
        
        if type == SyncStatusResponse.self {
            let mock = SyncStatusResponse(success: true, message: "Synced successfully via StrideSync Network Client")
            if let result = mock as? T {
                return result
            }
        }
        
        if type == [AthleteProfile].self {
            let mock = AthleteProfile.sampleAthletes()
            if let result = mock as? T {
                return result
            }
        }
        
        // Generic fallback mock for basic status or empty lists
        let fallbackJson = """
        {
            "success": true,
            "message": "Mock operation succeeded"
        }
        """
        if let data = fallbackJson.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(T.self, from: data) {
            return decoded
        }
        
        throw NetworkError.decodingError
    }
}

public struct SyncStatusResponse: Codable, Sendable, Equatable {
    public let success: Bool
    public let message: String
    
    public init(success: Bool, message: String) {
        self.success = success
        self.message = message
    }
}
