import Foundation

/// Intelligent Pacing Coach service evaluating real-time splits against target pace and triggering adaptive voice cues.
public final class PacingCoachService: @unchecked Sendable {
    public var target: PacingTarget?
    public var languageCode: String = "id-ID"
    public var announcementIntervalMeters: Double = 500.0 // Give feedback every 500m or 1km
    
    private var lastFeedbackDistanceMeters: Double = 0.0
    
    public init(target: PacingTarget? = nil, languageCode: String = "id-ID") {
        self.target = target
        self.languageCode = languageCode
    }
    
    public func reset() {
        lastFeedbackDistanceMeters = 0.0
    }
    
    /// Evaluates current metrics and produces pacing coach feedback.
    public func evaluate(
        distanceMeters: Double,
        elapsedTimeSeconds: TimeInterval,
        currentPaceSecondsPerKm: Double
    ) -> PacingCoachFeedback? {
        guard let target = target, distanceMeters > 50 else { return nil }
        
        let km = distanceMeters / 1000.0
        let expectedTimeAtCurrentDistance = km * target.targetPaceSecondsPerKm
        let deltaSeconds = expectedTimeAtCurrentDistance - elapsedTimeSeconds // Positive = ahead (took less time), Negative = behind
        let isAhead = deltaSeconds >= 0
        let absSeconds = Int(abs(deltaSeconds))
        
        let announcement: String
        let isIndonesian = languageCode.hasPrefix("id")
        
        if absSeconds < 3 {
            announcement = isIndonesian
                ? "Pace tepat sesuai target!"
                : "Right on target pace!"
        } else if isAhead {
            announcement = isIndonesian
                ? "Kamu \(absSeconds) detik lebih cepat dari target. Pertahankan ritme!"
                : "You are \(absSeconds) seconds ahead of target pace. Keep it up!"
        } else {
            announcement = isIndonesian
                ? "Kamu \(absSeconds) detik di belakang target. Tingkatkan ritme sedikit!"
                : "You are \(absSeconds) seconds behind target pace. Pick up the rhythm!"
        }
        
        return PacingCoachFeedback(
            deltaSeconds: deltaSeconds,
            currentPaceSecondsPerKm: currentPaceSecondsPerKm,
            targetPaceSecondsPerKm: target.targetPaceSecondsPerKm,
            isAhead: isAhead,
            localizedAnnouncement: announcement
        )
    }
    
    /// Checks if a voice announcement should be triggered at the current distance checkpoint.
    public func shouldTriggerVoiceAnnouncement(currentDistanceMeters: Double) -> Bool {
        guard target != nil else { return false }
        if currentDistanceMeters >= (lastFeedbackDistanceMeters + announcementIntervalMeters) {
            lastFeedbackDistanceMeters = currentDistanceMeters
            return true
        }
        return false
    }
}

