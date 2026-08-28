import Foundation

/// Engine that tracks and computes real-time distance and time separation against a Virtual Ghost Runner.
public final class GhostRunnerEngine: Sendable {
    public let source: GhostPaceSource
    public let targetPaceSecondsPerKm: TimeInterval
    
    public init(source: GhostPaceSource) {
        self.source = source
        switch source {
        case .pastPersonalRecord(_, let totalTime):
            // Assumes standard 5K baseline if total distance unspecified, or pace derived
            self.targetPaceSecondsPerKm = max(120.0, totalTime / 5.0)
        case .segmentKOM(_, let komTime, _):
            self.targetPaceSecondsPerKm = max(120.0, komTime / 1.0)
        case .customTargetPace(let pace):
            self.targetPaceSecondsPerKm = max(120.0, pace)
        }
    }
    
    /// Evaluates real-time distance separation (meters) and time delta against the ghost runner.
    public func evaluate(
        athleteDistanceMeters: Double,
        athleteElapsedTimeSeconds: TimeInterval,
        athleteCurrentPaceSecondsPerKm: TimeInterval
    ) -> GhostRunnerDelta {
        // Ghost's simulated progress at this exact elapsed time
        let ghostSpeedMps = 1000.0 / targetPaceSecondsPerKm
        let ghostDistanceMeters = ghostSpeedMps * athleteElapsedTimeSeconds
        
        let distanceSeparation = athleteDistanceMeters - ghostDistanceMeters
        
        // Time gap: How much time is the athlete ahead (+) or behind (-) for their current distance
        let expectedTimeAtCurrentDistance = (athleteDistanceMeters / 1000.0) * targetPaceSecondsPerKm
        let timeDelta = expectedTimeAtCurrentDistance - athleteElapsedTimeSeconds
        
        return GhostRunnerDelta(
            distanceSeparationMeters: (distanceSeparation * 10.0).rounded() / 10.0,
            timeDeltaSeconds: timeDelta,
            ghostPaceSecondsPerKm: targetPaceSecondsPerKm,
            athleteCurrentPaceSecondsPerKm: athleteCurrentPaceSecondsPerKm
        )
    }
}
