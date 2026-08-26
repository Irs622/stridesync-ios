import Foundation

/// Type of social and activity notifications delivered to the athlete.
public enum NotificationType: String, Codable, Sendable, CaseIterable {
    case kudos = "Kudos"
    case comment = "Komentar"
    case komLost = "Rekor KOM Tergeser"
    case challengeJoined = "Tantangan"
    case clubAnnouncement = "Klub"
    case weeklyDigest = "Ringkasan Mingguan"
    
    public var iconName: String {
        switch self {
        case .kudos: return "hand.thumbsup.fill"
        case .comment: return "bubble.left.fill"
        case .komLost: return "crown.fill"
        case .challengeJoined: return "trophy.fill"
        case .clubAnnouncement: return "person.3.fill"
        case .weeklyDigest: return "chart.bar.fill"
        }
    }
}

/// Represents a single notification item in the athlete's inbox.
public struct AppNotification: Identifiable, Sendable {
    public let id: UUID
    public let type: NotificationType
    public let title: String
    public let message: String
    public let actorName: String
    public let timestamp: Date
    public var isRead: Bool
    public let relatedActivityId: UUID?
    
    public init(
        id: UUID = UUID(),
        type: NotificationType,
        title: String,
        message: String,
        actorName: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        relatedActivityId: UUID? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.actorName = actorName
        self.timestamp = timestamp
        self.isRead = isRead
        self.relatedActivityId = relatedActivityId
    }
}

