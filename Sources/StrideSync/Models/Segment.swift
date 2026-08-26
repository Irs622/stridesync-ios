import Foundation
import SwiftData
import CoreLocation

/// Coordinate point specifically used for segment geometries.
public struct SegmentPoint: Codable, Sendable {
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double
    
    public init(latitude: Double, longitude: Double, altitude: Double = 0.0) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// A community-created course or hill climb segment used for virtual racing and leaderboards.
@Model
public final class Segment {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var activityTypeRaw: String
    public var distanceMeters: Double
    public var elevationGainMeters: Double
    public var averageGradePercent: Double
    public var maximumGradePercent: Double
    public var startLatitude: Double
    public var startLongitude: Double
    public var endLatitude: Double
    public var endLongitude: Double
    public var polylineJson: String // Serialized [SegmentPoint]
    public var komTimeSeconds: TimeInterval?
    public var komAthleteName: String?
    public var qomTimeSeconds: TimeInterval?
    public var qomAthleteName: String?
    public var totalEffortsCount: Int
    
    public var activityType: ActivityType {
        get { ActivityType(rawValue: activityTypeRaw) ?? .run }
        set { activityTypeRaw = newValue.rawValue }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        activityType: ActivityType = .run,
        distanceMeters: Double,
        elevationGainMeters: Double = 0.0,
        averageGradePercent: Double = 0.0,
        maximumGradePercent: Double = 0.0,
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D,
        polyline: [SegmentPoint] = [],
        komTimeSeconds: TimeInterval? = nil,
        komAthleteName: String? = nil,
        qomTimeSeconds: TimeInterval? = nil,
        qomAthleteName: String? = nil,
        totalEffortsCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.activityTypeRaw = activityType.rawValue
        self.distanceMeters = distanceMeters
        self.elevationGainMeters = elevationGainMeters
        self.averageGradePercent = averageGradePercent
        self.maximumGradePercent = maximumGradePercent
        self.startLatitude = startCoordinate.latitude
        self.startLongitude = startCoordinate.longitude
        self.endLatitude = endCoordinate.latitude
        self.endLongitude = endCoordinate.longitude
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(polyline), let json = String(data: data, encoding: .utf8) {
            self.polylineJson = json
        } else {
            self.polylineJson = "[]"
        }
        
        self.komTimeSeconds = komTimeSeconds
        self.komAthleteName = komAthleteName
        self.qomTimeSeconds = qomTimeSeconds
        self.qomAthleteName = qomAthleteName
        self.totalEffortsCount = totalEffortsCount
    }
    
    public var polylinePoints: [SegmentPoint] {
        guard let data = polylineJson.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([SegmentPoint].self, from: data)) ?? []
    }
}

/// An athlete's specific timed attempt over a defined Segment.
public struct SegmentEffort: Codable, Sendable, Identifiable {
    public var id: UUID
    public var segmentId: UUID
    public var segmentName: String
    public var athleteId: UUID
    public var athleteName: String
    public var elapsedTimeSeconds: TimeInterval
    public var averageSpeedMps: Double
    public var averageHeartRate: Int?
    public var dateAchieved: Date
    public var isKOM: Bool
    public var isQOM: Bool
    public var isPersonalRecord: Bool
    
    public init(
        id: UUID = UUID(),
        segmentId: UUID,
        segmentName: String,
        athleteId: UUID,
        athleteName: String,
        elapsedTimeSeconds: TimeInterval,
        averageSpeedMps: Double,
        averageHeartRate: Int? = nil,
        dateAchieved: Date = Date(),
        isKOM: Bool = false,
        isQOM: Bool = false,
        isPersonalRecord: Bool = false
    ) {
        self.id = id
        self.segmentId = segmentId
        self.segmentName = segmentName
        self.athleteId = athleteId
        self.athleteName = athleteName
        self.elapsedTimeSeconds = elapsedTimeSeconds
        self.averageSpeedMps = averageSpeedMps
        self.averageHeartRate = averageHeartRate
        self.dateAchieved = dateAchieved
        self.isKOM = isKOM
        self.isQOM = isQOM
        self.isPersonalRecord = isPersonalRecord
    }
    
    public var formattedDuration: String {
        let minutes = Int(elapsedTimeSeconds) / 60
        let seconds = Int(elapsedTimeSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Leaderboard ranking entry for display in leaderboard tables.
public struct LeaderboardEntry: Codable, Sendable, Identifiable {
    public var id: UUID { effortId }
    public var rank: Int
    public var effortId: UUID
    public var athleteName: String
    public var athleteAvatarUrl: String?
    public var formattedTime: String
    public var formattedSpeedOrPace: String
    public var dateFormatted: String
    public var isCrownHolder: Bool
    public var isCurrentUser: Bool
    
    public init(
        rank: Int,
        effortId: UUID = UUID(),
        athleteName: String,
        athleteAvatarUrl: String? = nil,
        formattedTime: String,
        formattedSpeedOrPace: String,
        dateFormatted: String,
        isCrownHolder: Bool = false,
        isCurrentUser: Bool = false
    ) {
        self.rank = rank
        self.effortId = effortId
        self.athleteName = athleteName
        self.athleteAvatarUrl = athleteAvatarUrl
        self.formattedTime = formattedTime
        self.formattedSpeedOrPace = formattedSpeedOrPace
        self.dateFormatted = dateFormatted
        self.isCrownHolder = isCrownHolder
        self.isCurrentUser = isCurrentUser
    }
}

