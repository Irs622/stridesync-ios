import Foundation

/// Defines a pre-set pacing or time target for a workout session.
public struct PacingTarget: Sendable, Equatable {
    public var targetDistanceMeters: Double
    public var targetDurationSeconds: TimeInterval
    public var targetPaceSecondsPerKm: Double
    
    public init(
        targetDistanceMeters: Double,
        targetDurationSeconds: TimeInterval
    ) {
        self.targetDistanceMeters = targetDistanceMeters
        self.targetDurationSeconds = targetDurationSeconds
        let km = targetDistanceMeters / 1000.0
        self.targetPaceSecondsPerKm = km > 0 ? (targetDurationSeconds / km) : 0
    }
    
    public init(
        targetDistanceMeters: Double,
        targetPaceSecondsPerKm: Double
    ) {
        self.targetDistanceMeters = targetDistanceMeters
        self.targetPaceSecondsPerKm = targetPaceSecondsPerKm
        let km = targetDistanceMeters / 1000.0
        self.targetDurationSeconds = km * targetPaceSecondsPerKm
    }
    
    public var formattedTargetDistance: String {
        String(format: "%.2f km", targetDistanceMeters / 1000.0)
    }
    
    public var formattedTargetDuration: String {
        let mins = Int(targetDurationSeconds) / 60
        let secs = Int(targetDurationSeconds) % 60
        let hrs = mins / 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins % 60, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }
    
    public var formattedTargetPace: String {
        guard targetPaceSecondsPerKm > 0 else { return "-:--" }
        let min = Int(targetPaceSecondsPerKm) / 60
        let sec = Int(targetPaceSecondsPerKm) % 60
        return String(format: "%d:%02d /km", min, sec)
    }
    
    // MARK: - Presets
    public static let sub20_5K = PacingTarget(targetDistanceMeters: 5_000, targetDurationSeconds: 20 * 60)
    public static let sub25_5K = PacingTarget(targetDistanceMeters: 5_000, targetDurationSeconds: 25 * 60)
    public static let sub50_10K = PacingTarget(targetDistanceMeters: 10_000, targetDurationSeconds: 50 * 60)
    public static let sub1h45_HalfMarathon = PacingTarget(targetDistanceMeters: 21_097.5, targetDurationSeconds: 105 * 60)
    public static let sub4h_Marathon = PacingTarget(targetDistanceMeters: 42_195, targetDurationSeconds: 240 * 60)
}

/// Dynamic feedback from the pacing coach evaluating current athlete pace vs target pace.
public struct PacingCoachFeedback: Sendable, Equatable {
    public let deltaSeconds: Double // Positive = ahead of target, Negative = behind target
    public let currentPaceSecondsPerKm: Double
    public let targetPaceSecondsPerKm: Double
    public let isAhead: Bool
    public let localizedAnnouncement: String
    
    public init(
        deltaSeconds: Double,
        currentPaceSecondsPerKm: Double,
        targetPaceSecondsPerKm: Double,
        isAhead: Bool,
        localizedAnnouncement: String
    ) {
        self.deltaSeconds = deltaSeconds
        self.currentPaceSecondsPerKm = currentPaceSecondsPerKm
        self.targetPaceSecondsPerKm = targetPaceSecondsPerKm
        self.isAhead = isAhead
        self.localizedAnnouncement = localizedAnnouncement
    }
    
    public var formattedDelta: String {
        let absSeconds = abs(deltaSeconds)
        let mins = Int(absSeconds) / 60
        let secs = Int(absSeconds) % 60
        let prefix = deltaSeconds >= 0 ? "+" : "-"
        if mins > 0 {
            return String(format: "%@%d:%02d", prefix, mins, secs)
        } else {
            return String(format: "%@%ds", prefix, secs)
        }
    }
}

