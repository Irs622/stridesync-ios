import Foundation
import SwiftData

/// Profile information of an athlete/user.
public struct AthleteProfile: Codable, Sendable, Identifiable {
    public var id: UUID
    public var username: String
    public var fullName: String
    public var bio: String?
    public var avatarUrl: String?
    public var location: String?
    public var totalDistanceMeters: Double
    public var totalActivitiesCount: Int
    public var totalElevationGainMeters: Double
    public var followersCount: Int
    public var followingCount: Int
    public var trophyBadges: [String]
    
    public init(
        id: UUID = UUID(),
        username: String,
        fullName: String,
        bio: String? = nil,
        avatarUrl: String? = nil,
        location: String? = nil,
        totalDistanceMeters: Double = 0.0,
        totalActivitiesCount: Int = 0,
        totalElevationGainMeters: Double = 0.0,
        followersCount: Int = 0,
        followingCount: Int = 0,
        trophyBadges: [String] = []
    ) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.location = location
        self.totalDistanceMeters = totalDistanceMeters
        self.totalActivitiesCount = totalActivitiesCount
        self.totalElevationGainMeters = totalElevationGainMeters
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.trophyBadges = trophyBadges
    }
    
    public var formattedTotalDistance: String {
        let km = totalDistanceMeters / 1000.0
        return String(format: "%.1f km", km)
    }
}

/// A comment on an activity.
public struct CommentRecord: Codable, Sendable, Identifiable {
    public var id: UUID
    public var activityId: UUID
    public var athleteId: UUID
    public var athleteName: String
    public var athleteAvatarUrl: String?
    public var message: String
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        activityId: UUID,
        athleteId: UUID,
        athleteName: String,
        athleteAvatarUrl: String? = nil,
        message: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.activityId = activityId
        self.athleteId = athleteId
        self.athleteName = athleteName
        self.athleteAvatarUrl = athleteAvatarUrl
        self.message = message
        self.createdAt = createdAt
    }
}

/// A kudos (like/thumbs up) given on an activity.
public struct KudosRecord: Codable, Sendable, Identifiable {
    public var id: UUID
    public var activityId: UUID
    public var athleteId: UUID
    public var athleteName: String
    public var athleteAvatarUrl: String?
    public var timestamp: Date
    
    public init(
        id: UUID = UUID(),
        activityId: UUID,
        athleteId: UUID,
        athleteName: String,
        athleteAvatarUrl: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.activityId = activityId
        self.athleteId = athleteId
        self.athleteName = athleteName
        self.athleteAvatarUrl = athleteAvatarUrl
        self.timestamp = timestamp
    }
}

/// A monthly or seasonal fitness challenge.
public struct Challenge: Codable, Sendable, Identifiable {
    public var id: UUID
    public var title: String
    public var subtitle: String
    public var targetDistanceMeters: Double
    public var currentProgressMeters: Double
    public var activityType: ActivityType
    public var startDate: Date
    public var endDate: Date
    public var badgeIconName: String
    public var isJoined: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        targetDistanceMeters: Double,
        currentProgressMeters: Double = 0.0,
        activityType: ActivityType = .run,
        startDate: Date,
        endDate: Date,
        badgeIconName: String = "trophy.fill",
        isJoined: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.targetDistanceMeters = targetDistanceMeters
        self.currentProgressMeters = currentProgressMeters
        self.activityType = activityType
        self.startDate = startDate
        self.endDate = endDate
        self.badgeIconName = badgeIconName
        self.isJoined = isJoined
    }
    
    public var progressFraction: Double {
        guard targetDistanceMeters > 0 else { return 0.0 }
        return min(1.0, currentProgressMeters / targetDistanceMeters)
    }
    
    public var isCompleted: Bool {
        currentProgressMeters >= targetDistanceMeters
    }
}

/// Sports equipment (running shoes or bikes) with mileage tracking.
@Model
public final class GearItem {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var brand: String
    public var maxLifeDistanceMeters: Double // e.g. 800 km for running shoes
    public var currentDistanceMeters: Double
    public var isDefault: Bool
    public var activityTypeRaw: String
    
    public var activityType: ActivityType {
        get { ActivityType(rawValue: activityTypeRaw) ?? .run }
        set { activityTypeRaw = newValue.rawValue }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        maxLifeDistanceMeters: Double = 800_000,
        currentDistanceMeters: Double = 0,
        isDefault: Bool = false,
        activityType: ActivityType = .run
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.maxLifeDistanceMeters = maxLifeDistanceMeters
        self.currentDistanceMeters = currentDistanceMeters
        self.isDefault = isDefault
        self.activityTypeRaw = activityType.rawValue
    }
    
    public var lifeRemainingPercentage: Double {
        guard maxLifeDistanceMeters > 0 else { return 100.0 }
        let used = (currentDistanceMeters / maxLifeDistanceMeters) * 100.0
        return max(0.0, 100.0 - used)
    }
}

