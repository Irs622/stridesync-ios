import Foundation

/// Real-time event types emitted by Supabase PostgreSQL Realtime channels.
public enum RealtimeFeedEventType: String, Codable, Sendable {
    case kudosInserted = "kudos_insert"
    case kudosDeleted = "kudos_delete"
    case commentInserted = "comment_insert"
    case commentDeleted = "comment_delete"
}

/// Structured payload for a live incoming social activity event.
public struct RealtimeFeedEvent: Codable, Sendable, Identifiable {
    public let id: UUID
    public let eventType: RealtimeFeedEventType
    public let activityId: UUID
    public let userId: UUID
    public let userName: String?
    public let message: String?
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        eventType: RealtimeFeedEventType,
        activityId: UUID,
        userId: UUID,
        userName: String? = nil,
        message: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.eventType = eventType
        self.activityId = activityId
        self.userId = userId
        self.userName = userName
        self.message = message
        self.timestamp = timestamp
    }
}

/// Actor managing real-time WebSocket connections to Supabase Realtime Channels.
public actor SupabaseRealtimeManager {
    public static let shared = SupabaseRealtimeManager()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected: Bool = false
    private var eventContinuations: [UUID: AsyncStream<RealtimeFeedEvent>.Continuation] = [:]
    
    public init() {}
    
    /// Connects to the Supabase Realtime WebSocket server.
    public func connect(projectURL: String = SupabaseConfig.projectURL, apiKey: String = SupabaseConfig.publishableKey) {
        guard !isConnected else { return }
        
        let wsURLString = projectURL
            .replacingOccurrences(of: "https://", with: "wss://")
            .appending("/realtime/v1/websocket?apikey=\(apiKey)&vsn=1.0.0")
        
        guard let url = URL(string: wsURLString) else { return }
        
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)
        self.webSocketTask = task
        self.isConnected = true
        task.resume()
        
        // Start listening for messages
        listenForMessages()
        
        // Join channels for kudos & comments
        subscribeToChannel(topic: "realtime:public:kudos")
        subscribeToChannel(topic: "realtime:public:comments")
    }
    
    /// Disconnects from the WebSocket server and tears down active streams.
    public func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        for continuation in eventContinuations.values {
            continuation.finish()
        }
        eventContinuations.removeAll()
    }
    
    /// Subscribes to an AsyncStream of real-time feed events.
    public func feedEventsStream() -> AsyncStream<RealtimeFeedEvent> {
        let streamId = UUID()
        return AsyncStream { continuation in
            self.eventContinuations[streamId] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { [weak self] in
                    await self?.removeContinuation(id: streamId)
                }
            }
        }
    }
    
    /// Broadcasts an event locally (used for testing or optimistic UI updates).
    public func broadcastMockEvent(_ event: RealtimeFeedEvent) {
        for continuation in eventContinuations.values {
            continuation.yield(event)
        }
    }
    
    private func removeContinuation(id: UUID) {
        eventContinuations.removeValue(forKey: id)
    }
    
    private func subscribeToChannel(topic: String) {
        let joinMessage: [String: Any] = [
            "topic": topic,
            "event": "phx_join",
            "payload": [:],
            "ref": UUID().uuidString
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: joinMessage),
           let jsonString = String(data: data, encoding: .utf8) {
            webSocketTask?.send(.string(jsonString)) { _ in }
        }
    }
    
    private func listenForMessages() {
        guard isConnected, let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            Task { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let message):
                    await self.handleIncomingMessage(message)
                    await self.listenForMessages()
                case .failure:
                    await self.handleDisconnect()
                }
            }
        }
    }
    
    private func handleIncomingMessage(_ message: URLSessionWebSocketTask.Message) {
        let text: String?
        switch message {
        case .string(let s): text = s
        case .data(let d): text = String(data: d, encoding: .utf8)
        @unknown default: text = nil
        }
        
        guard let text = text, let data = text.data(using: .utf8) else { return }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let eventName = json["event"] as? String {
            if eventName == "INSERT",
               let payload = json["payload"] as? [String: Any],
               let record = payload["record"] as? [String: Any] {
                
                let activityIdString = (record["activity_id"] as? String) ?? UUID().uuidString
                let userIdString = (record["user_id"] as? String) ?? UUID().uuidString
                let activityId = UUID(uuidString: activityIdString) ?? UUID()
                let userId = UUID(uuidString: userIdString) ?? UUID()
                let messageText = record["message"] as? String
                
                let feedEvent = RealtimeFeedEvent(
                    eventType: messageText != nil ? .commentInserted : .kudosInserted,
                    activityId: activityId,
                    userId: userId,
                    message: messageText
                )
                
                for continuation in eventContinuations.values {
                    continuation.yield(feedEvent)
                }
            }
        }
    }
    
    private func handleDisconnect() {
        self.isConnected = false
        self.webSocketTask = nil
    }
}

