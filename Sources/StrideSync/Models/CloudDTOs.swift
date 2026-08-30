import Foundation

// MARK: - Authentication DTOs

public struct AppleAuthRequest: Codable, Sendable, Equatable {
    public let identityToken: String
    public let authorizationCode: String
    public let userIdentifier: String
    public let fullName: String?
    public let email: String?
    
    public init(
        identityToken: String,
        authorizationCode: String,
        userIdentifier: String,
        fullName: String? = nil,
        email: String? = nil
    ) {
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.userIdentifier = userIdentifier
        self.fullName = fullName
        self.email = email
    }
}

public struct EmailAuthRequest: Codable, Sendable, Equatable {
    public let email: String
    public let passwordHash: String
    public let fullName: String?
    
    public init(email: String, passwordHash: String, fullName: String? = nil) {
        self.email = email
        self.passwordHash = passwordHash
        self.fullName = fullName
    }
}

public struct AuthResponse: Codable, Sendable, Equatable {
    public let accessToken: String
    public let refreshToken: String
    public let user: CloudUserProfile
    
    public init(accessToken: String, refreshToken: String, user: CloudUserProfile) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
    }
}

public struct CloudUserProfile: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public var email: String
    public var username: String
    public var fullName: String
    public var bio: String?
    public var avatarUrl: String?
    public var location: String?
    public var followersCount: Int
    public var followingCount: Int
    public var isFollowing: Bool?
    
    public init(
        id: UUID = UUID(),
        email: String,
        username: String,
        fullName: String,
        bio: String? = nil,
        avatarUrl: String? = nil,
        location: String? = "Jakarta, Indonesia",
        followersCount: Int = 0,
        followingCount: Int = 0,
        isFollowing: Bool? = false
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.location = location
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.isFollowing = isFollowing
    }
}

// MARK: - Activity & Feed Cloud DTOs

public struct CloudActivityDTO: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let userId: UUID
    public let athleteName: String
    public let athleteAvatarUrl: String?
    public let title: String
    public let activityType: String
    public let startTime: Date
    public let endTime: Date
    public let distanceMeters: Double
    public let durationSeconds: TimeInterval
    public let movingTimeSeconds: TimeInterval
    public let totalElevationGainMeters: Double
    public let averageSpeedMps: Double
    public let maxSpeedMps: Double
    public let averageHeartRate: Int?
    public let maxHeartRate: Int?
    public let caloriesBurned: Int
    public let encodedPolyline: String?
    public let notes: String?
    public let gearName: String?
    public var kudosCount: Int
    public var commentsCount: Int
    public var isLikedByCurrentUser: Bool
    
    public init(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        athleteName: String,
        athleteAvatarUrl: String? = nil,
        title: String,
        activityType: String,
        startTime: Date,
        endTime: Date,
        distanceMeters: Double,
        durationSeconds: TimeInterval,
        movingTimeSeconds: TimeInterval,
        totalElevationGainMeters: Double,
        averageSpeedMps: Double,
        maxSpeedMps: Double,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        caloriesBurned: Int = 0,
        encodedPolyline: String? = nil,
        notes: String? = nil,
        gearName: String? = nil,
        kudosCount: Int = 0,
        commentsCount: Int = 0,
        isLikedByCurrentUser: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.athleteName = athleteName
        self.athleteAvatarUrl = athleteAvatarUrl
        self.title = title
        self.activityType = activityType
        self.startTime = startTime
        self.endTime = endTime
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.movingTimeSeconds = movingTimeSeconds
        self.totalElevationGainMeters = totalElevationGainMeters
        self.averageSpeedMps = averageSpeedMps
        self.maxSpeedMps = maxSpeedMps
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.caloriesBurned = caloriesBurned
        self.encodedPolyline = encodedPolyline
        self.notes = notes
        self.gearName = gearName
        self.kudosCount = kudosCount
        self.commentsCount = commentsCount
        self.isLikedByCurrentUser = isLikedByCurrentUser
    }
}

public struct CloudFeedResponse: Codable, Sendable, Equatable {
    public let activities: [CloudActivityDTO]
    public let nextPage: Int?
    public let hasMore: Bool
    
    public init(activities: [CloudActivityDTO], nextPage: Int? = nil, hasMore: Bool = false) {
        self.activities = activities
        self.nextPage = nextPage
        self.hasMore = hasMore
    }
}

// MARK: - Social Interaction DTOs

public struct CloudCommentDTO: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let activityId: UUID
    public let userId: UUID
    public let athleteName: String
    public let message: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        activityId: UUID,
        userId: UUID,
        athleteName: String,
        message: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.activityId = activityId
        self.userId = userId
        self.athleteName = athleteName
        self.message = message
        self.createdAt = createdAt
    }
}

public struct KudoToggleResponse: Codable, Sendable, Equatable {
    public let isLiked: Bool
    public let totalKudos: Int
    
    public init(isLiked: Bool, totalKudos: Int) {
        self.isLiked = isLiked
        self.totalKudos = totalKudos
    }
}

// MARK: - Leaderboard DTOs

public struct CloudLeaderboardEntryDTO: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let rank: Int
    public let athleteId: UUID
    public let athleteName: String
    public let elapsedTimeSeconds: Double
    public let averageSpeedMps: Double
    public let averageHeartRate: Int?
    public let averagePowerWatts: Double?
    public let effortDate: Date
    
    public init(
        id: UUID = UUID(),
        rank: Int,
        athleteId: UUID,
        athleteName: String,
        elapsedTimeSeconds: Double,
        averageSpeedMps: Double,
        averageHeartRate: Int? = nil,
        averagePowerWatts: Double? = nil,
        effortDate: Date = Date()
    ) {
        self.id = id
        self.rank = rank
        self.athleteId = athleteId
        self.athleteName = athleteName
        self.elapsedTimeSeconds = elapsedTimeSeconds
        self.averageSpeedMps = averageSpeedMps
        self.averageHeartRate = averageHeartRate
        self.averagePowerWatts = averagePowerWatts
        self.effortDate = effortDate
    }
}

