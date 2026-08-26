import Foundation
import SwiftData

/// Sendable snapshot of an activity's core telemetry metrics for cross-actor transfer.
public struct ActivitySummarySnapshot: Sendable, Codable {
    public var title: String
    public var activityType: ActivityType
    public var startTime: Date
    public var endTime: Date
    public var distanceMeters: Double
    public var durationSeconds: TimeInterval
    public var movingTimeSeconds: TimeInterval
    public var totalElevationGainMeters: Double
    public var averageSpeedMps: Double
    public var maxSpeedMps: Double
    public var averageHeartRate: Int?
    public var maxHeartRate: Int?
    public var caloriesBurned: Double?
    public var notes: String?
    public var visibility: VisibilityType
    
    public init(
        title: String,
        activityType: ActivityType = .run,
        startTime: Date = Date(),
        endTime: Date = Date(),
        distanceMeters: Double = 0.0,
        durationSeconds: TimeInterval = 0.0,
        movingTimeSeconds: TimeInterval = 0.0,
        totalElevationGainMeters: Double = 0.0,
        averageSpeedMps: Double = 0.0,
        maxSpeedMps: Double = 0.0,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        caloriesBurned: Double? = nil,
        notes: String? = nil,
        visibility: VisibilityType = .publicVisibility
    ) {
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
        self.notes = notes
        self.visibility = visibility
    }
}

/// The primary entity representing a recorded workout and activity session.
@Model
public final class ActivityRecord {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var activityTypeRaw: String
    public var startTime: Date
    public var endTime: Date
    public var distanceMeters: Double
    public var durationSeconds: TimeInterval
    public var movingTimeSeconds: TimeInterval
    public var totalElevationGainMeters: Double
    public var averageSpeedMps: Double
    public var maxSpeedMps: Double
    public var averageHeartRate: Int?
    public var maxHeartRate: Int?
    public var caloriesBurned: Double?
    public var notes: String?
    public var visibilityRaw: String
    public var kudosCount: Int
    public var commentsCount: Int
    public var photoUrls: [String]
    public var isLikedByCurrentUser: Bool
    public var gearName: String?
    
    @Relationship(deleteRule: .cascade) public var telemetryPoints: [TelemetryPoint]
    @Relationship(deleteRule: .cascade) public var splits: [DistanceSplit]
    
    public var activityType: ActivityType {
        get { ActivityType(rawValue: activityTypeRaw) ?? .run }
        set { activityTypeRaw = newValue.rawValue }
    }
    
    public var visibility: VisibilityType {
        get { VisibilityType(rawValue: visibilityRaw) ?? .publicVisibility }
        set { visibilityRaw = newValue.rawValue }
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        activityType: ActivityType = .run,
        startTime: Date = Date(),
        endTime: Date = Date(),
        distanceMeters: Double = 0.0,
        durationSeconds: TimeInterval = 0.0,
        movingTimeSeconds: TimeInterval = 0.0,
        totalElevationGainMeters: Double = 0.0,
        averageSpeedMps: Double = 0.0,
        maxSpeedMps: Double = 0.0,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        caloriesBurned: Double? = nil,
        notes: String? = nil,
        visibility: VisibilityType = .publicVisibility,
        gearName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.activityTypeRaw = activityType.rawValue
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
        self.notes = notes
        self.visibilityRaw = visibility.rawValue
        self.kudosCount = 0
        self.commentsCount = 0
        self.photoUrls = []
        self.isLikedByCurrentUser = false
        self.gearName = gearName
        self.telemetryPoints = []
        self.splits = []
    }
    
    public convenience init(from snapshot: ActivitySummarySnapshot) {
        self.init(
            title: snapshot.title,
            activityType: snapshot.activityType,
            startTime: snapshot.startTime,
            endTime: snapshot.endTime,
            distanceMeters: snapshot.distanceMeters,
            durationSeconds: snapshot.durationSeconds,
            movingTimeSeconds: snapshot.movingTimeSeconds,
            totalElevationGainMeters: snapshot.totalElevationGainMeters,
            averageSpeedMps: snapshot.averageSpeedMps,
            maxSpeedMps: snapshot.maxSpeedMps,
            averageHeartRate: snapshot.averageHeartRate,
            maxHeartRate: snapshot.maxHeartRate,
            caloriesBurned: snapshot.caloriesBurned,
            notes: snapshot.notes,
            visibility: snapshot.visibility
        )
    }
    
    // MARK: - Computed Formatters
    
    /// Distance formatted in kilometers (e.g. "10.42 km")
    public var formattedDistance: String {
        let km = distanceMeters / 1000.0
        return String(format: "%.2f km", km)
    }
    
    /// Duration formatted as HH:MM:SS or MM:SS
    public var formattedDuration: String {
        formatTimeInterval(durationSeconds)
    }
    
    /// Moving time formatted as HH:MM:SS or MM:SS
    public var formattedMovingTime: String {
        formatTimeInterval(movingTimeSeconds > 0 ? movingTimeSeconds : durationSeconds)
    }
    
    /// Average pace (min/km) or speed (km/h) depending on activity type preference
    public var formattedAveragePace: String {
        if activityType.prefersPaceFormat {
            guard averageSpeedMps > 0.1 else { return "-:--" }
            let paceSecondsPerKm = 1000.0 / averageSpeedMps
            let minutes = Int(paceSecondsPerKm) / 60
            let seconds = Int(paceSecondsPerKm) % 60
            return String(format: "%d:%02d /km", minutes, seconds)
        } else {
            let kmh = averageSpeedMps * 3.6
            return String(format: "%.1f km/h", kmh)
        }
    }
    
    /// Elevation gain formatted (e.g. "124 m")
    public var formattedElevationGain: String {
        return String(format: "%.0f m", totalElevationGainMeters)
    }
    
    /// Calories formatted (e.g. "540 kcal")
    public var formattedCalories: String {
        guard let cal = caloriesBurned, cal > 0 else { return "-- kcal" }
        return String(format: "%.0f kcal", cal)
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

