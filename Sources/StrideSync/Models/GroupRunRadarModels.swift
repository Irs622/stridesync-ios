import Foundation
import CoreLocation

/// Model representing a fellow athlete running or cycling nearby in real-time.
public struct BuddyRunner: Identifiable, Codable, Sendable {
    public var id: UUID
    public var name: String
    public var avatarUrl: String?
    public var latitude: Double
    public var longitude: Double
    public var currentSpeedMps: Double
    public var currentPaceSecondsPerKm: Double
    public var distanceCompletedMeters: Double
    public var activityType: ActivityType
    public var isClubMember: Bool
    public var lastSeenDate: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        avatarUrl: String? = nil,
        latitude: Double,
        longitude: Double,
        currentSpeedMps: Double = 3.5,
        currentPaceSecondsPerKm: Double = 285.0,
        distanceCompletedMeters: Double = 3200.0,
        activityType: ActivityType = .run,
        isClubMember: Bool = true,
        lastSeenDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.latitude = latitude
        self.longitude = longitude
        self.currentSpeedMps = currentSpeedMps
        self.currentPaceSecondsPerKm = currentPaceSecondsPerKm
        self.distanceCompletedMeters = distanceCompletedMeters
        self.activityType = activityType
        self.isClubMember = isClubMember
        self.lastSeenDate = lastSeenDate
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var formattedPace: String {
        guard currentPaceSecondsPerKm > 0 else { return "--" }
        let min = Int(currentPaceSecondsPerKm) / 60
        let sec = Int(currentPaceSecondsPerKm) % 60
        return String(format: "%d:%02d /km", min, sec)
    }
}

/// Calculated relative radar target ping for display on the HUD or Map overlay.
public struct RadarTargetPing: Identifiable, Sendable {
    public var id: UUID { buddy.id }
    public var buddy: BuddyRunner
    public var relativeDistanceMeters: Double
    public var relativeBearingDegrees: Double // 0 = North, 90 = East, 180 = South, 270 = West
    public var isAhead: Bool
    public var paceDifferenceSecondsPerKm: Double // Positive = buddy is faster, negative = buddy is slower
    
    public init(
        buddy: BuddyRunner,
        relativeDistanceMeters: Double,
        relativeBearingDegrees: Double,
        isAhead: Bool,
        paceDifferenceSecondsPerKm: Double
    ) {
        self.buddy = buddy
        self.relativeDistanceMeters = relativeDistanceMeters
        self.relativeBearingDegrees = relativeBearingDegrees
        self.isAhead = isAhead
        self.paceDifferenceSecondsPerKm = paceDifferenceSecondsPerKm
    }
    
    public var formattedDistance: String {
        if relativeDistanceMeters >= 1000 {
            return String(format: "%.1f km", relativeDistanceMeters / 1000.0)
        } else {
            return String(format: "%.0f m", relativeDistanceMeters)
        }
    }
    
    public var compassDirection: String {
        let normalized = (relativeBearingDegrees.truncatingRemainder(dividingBy: 360.0) + 360.0).truncatingRemainder(dividingBy: 360.0)
        switch normalized {
        case 337.5...360.0, 0..<22.5: return "N"
        case 22.5..<67.5: return "NE"
        case 67.5..<112.5: return "E"
        case 112.5..<157.5: return "SE"
        case 157.5..<202.5: return "S"
        case 202.5..<247.5: return "SW"
        case 247.5..<292.5: return "W"
        case 292.5..<337.5: return "NW"
        default: return "N"
        }
    }
}

