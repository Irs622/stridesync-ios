import Foundation
import CoreLocation

/// Source of baseline pace for the Virtual Ghost Runner.
public enum GhostPaceSource: Sendable, Codable, Equatable {
    case pastPersonalRecord(activityTitle: String, totalTimeSeconds: TimeInterval)
    case segmentKOM(segmentName: String, komTimeSeconds: TimeInterval, athleteName: String)
    case customTargetPace(paceSecondsPerKm: TimeInterval)
    
    public var label: String {
        switch self {
        case .pastPersonalRecord(let title, _):
            return "Rekor Pribadi: \(title)"
        case .segmentKOM(let name, _, let athlete):
            return "KOM Segmen (\(athlete)): \(name)"
        case .customTargetPace(let pace):
            let min = Int(pace) / 60
            let sec = Int(pace) % 60
            return String(format: "Target Pace: %d:%02d /km", min, sec)
        }
    }
}

/// Real-time delta comparison against the Virtual Ghost Runner.
public struct GhostRunnerDelta: Sendable, Codable {
    public var distanceSeparationMeters: Double // Positive = Athlete is ahead, Negative = Athlete is behind
    public var timeDeltaSeconds: TimeInterval // Positive = Athlete is ahead, Negative = Athlete is behind
    public var ghostPaceSecondsPerKm: TimeInterval
    public var athleteCurrentPaceSecondsPerKm: TimeInterval
    
    public var isAhead: Bool {
        distanceSeparationMeters >= 0
    }
    
    public var formattedDistanceDelta: String {
        let absDist = abs(distanceSeparationMeters)
        let formatted = absDist >= 1000 ? String(format: "%.2f km", absDist / 1000.0) : String(format: "%.0f m", absDist)
        return isAhead ? "+\(formatted) di Depan 🏃‍♂️" : "-\(formatted) di Belakang 👻"
    }
    
    public var formattedTimeDelta: String {
        let absSec = Int(abs(timeDeltaSeconds))
        let min = absSec / 60
        let sec = absSec % 60
        let sign = isAhead ? "+" : "-"
        return min > 0 ? String(format: "%@%d:%02d", sign, min, sec) : String(format: "%@%ds", sign, sec)
    }
    
    public init(
        distanceSeparationMeters: Double,
        timeDeltaSeconds: TimeInterval,
        ghostPaceSecondsPerKm: TimeInterval,
        athleteCurrentPaceSecondsPerKm: TimeInterval
    ) {
        self.distanceSeparationMeters = distanceSeparationMeters
        self.timeDeltaSeconds = timeDeltaSeconds
        self.ghostPaceSecondsPerKm = ghostPaceSecondsPerKm
        self.athleteCurrentPaceSecondsPerKm = athleteCurrentPaceSecondsPerKm
    }
}

/// Active status state of the Ghost Runner.
public struct GhostRunnerState: Sendable, Codable {
    public var isActive: Bool
    public var source: GhostPaceSource
    public var ghostCurrentDistanceMeters: Double
    public var latestDelta: GhostRunnerDelta?
    
    public init(
        isActive: Bool = false,
        source: GhostPaceSource = .customTargetPace(paceSecondsPerKm: 300),
        ghostCurrentDistanceMeters: Double = 0.0,
        latestDelta: GhostRunnerDelta? = nil
    ) {
        self.isActive = isActive
        self.source = source
        self.ghostCurrentDistanceMeters = ghostCurrentDistanceMeters
        self.latestDelta = latestDelta
    }
}

