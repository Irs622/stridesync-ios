import Foundation
import SwiftData

/// Breakdown metrics for each kilometer or mile segment within an activity.
@Model
public final class DistanceSplit {
    public var splitIndex: Int
    public var distanceMeters: Double
    public var durationSeconds: TimeInterval
    public var averagePaceSecondsPerKm: Double
    public var elevationChangeMeters: Double
    public var averageHeartRate: Int?
    
    public init(
        splitIndex: Int,
        distanceMeters: Double,
        durationSeconds: TimeInterval,
        averagePaceSecondsPerKm: Double,
        elevationChangeMeters: Double = 0.0,
        averageHeartRate: Int? = nil
    ) {
        self.splitIndex = splitIndex
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.averagePaceSecondsPerKm = averagePaceSecondsPerKm
        self.elevationChangeMeters = elevationChangeMeters
        self.averageHeartRate = averageHeartRate
    }
}

/// Sendable lightweight snapshot of a distance split.
public struct SplitSnapshot: Codable, Sendable, Identifiable {
    public var id: Int { splitIndex }
    public var splitIndex: Int
    public var distanceMeters: Double
    public var durationSeconds: TimeInterval
    public var averagePaceSecondsPerKm: Double
    public var elevationChangeMeters: Double
    public var averageHeartRate: Int?
    
    public init(
        splitIndex: Int,
        distanceMeters: Double,
        durationSeconds: TimeInterval,
        averagePaceSecondsPerKm: Double,
        elevationChangeMeters: Double = 0.0,
        averageHeartRate: Int? = nil
    ) {
        self.splitIndex = splitIndex
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.averagePaceSecondsPerKm = averagePaceSecondsPerKm
        self.elevationChangeMeters = elevationChangeMeters
        self.averageHeartRate = averageHeartRate
    }
    
    /// Formatted pace string like "5:24 /km".
    public var formattedPace: String {
        guard averagePaceSecondsPerKm > 0, !averagePaceSecondsPerKm.isInfinite, !averagePaceSecondsPerKm.isNaN else {
            return "-:--"
        }
        let minutes = Int(averagePaceSecondsPerKm) / 60
        let seconds = Int(averagePaceSecondsPerKm) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
    
    /// Formatted duration string like "5:24".
    public var formattedDuration: String {
        let minutes = Int(durationSeconds) / 60
        let seconds = Int(durationSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

