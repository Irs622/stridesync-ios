import Foundation

/// Standard athletic distances tracked for All-Time Personal Records (PRs) & Best Efforts.
public enum StandardDistanceCategory: String, Codable, Sendable, CaseIterable {
    case sprint400m = "400m Sprint"
    case km1 = "1 Kilometer"
    case mile1 = "1 Mile (1.6K)"
    case km5 = "5 Kilometer"
    case km10 = "10 Kilometer"
    case halfMarathon = "Half Marathon (21.1K)"
    case marathon = "Marathon (42.2K)"
    
    public var targetDistanceMeters: Double {
        switch self {
        case .sprint400m: return 400.0
        case .km1: return 1000.0
        case .mile1: return 1609.34
        case .km5: return 5000.0
        case .km10: return 10000.0
        case .halfMarathon: return 21097.5
        case .marathon: return 42195.0
        }
    }
    
    public var iconName: String {
        switch self {
        case .sprint400m: return "bolt.fill"
        case .km1: return "1.circle.fill"
        case .mile1: return "m.circle.fill"
        case .km5: return "5.circle.fill"
        case .km10: return "10.circle.fill"
        case .halfMarathon: return "medal.fill"
        case .marathon: return "crown.fill"
        }
    }
}

/// A recorded personal best effort achieved during an activity.
public struct PersonalRecordEffort: Identifiable, Codable, Sendable {
    public var id: UUID
    public var distanceCategory: StandardDistanceCategory
    public var durationSeconds: TimeInterval
    public var averagePaceSecondsPerKm: Double
    public var achievedDate: Date
    public var activityTitle: String
    public var isNewRecord: Bool
    
    public init(
        id: UUID = UUID(),
        distanceCategory: StandardDistanceCategory,
        durationSeconds: TimeInterval,
        averagePaceSecondsPerKm: Double,
        achievedDate: Date = Date(),
        activityTitle: String = "Latihan",
        isNewRecord: Bool = false
    ) {
        self.id = id
        self.distanceCategory = distanceCategory
        self.durationSeconds = durationSeconds
        self.averagePaceSecondsPerKm = averagePaceSecondsPerKm
        self.achievedDate = achievedDate
        self.activityTitle = activityTitle
        self.isNewRecord = isNewRecord
    }
    
    public var formattedDuration: String {
        let hours = Int(durationSeconds) / 3600
        let minutes = (Int(durationSeconds) % 3600) / 60
        let seconds = Int(durationSeconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    public var formattedPace: String {
        let min = Int(averagePaceSecondsPerKm) / 60
        let sec = Int(averagePaceSecondsPerKm) % 60
        return String(format: "%d:%02d /km", min, sec)
    }
}

