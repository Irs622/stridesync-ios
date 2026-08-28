import Testing
@testable import StrideSync

@Suite("Virtual Ghost Runner Tests")
struct GhostRunnerTests {
    
    @Test("Test Ghost Runner Ahead and Behind Evaluation")
    func testGhostRunnerDelta() {
        // Target Pace: 5:00/km = 300 seconds per km
        let engine = GhostRunnerEngine(source: .customTargetPace(paceSecondsPerKm: 300.0))
        
        // Scenario 1: Running faster than 5:00/km (e.g. 1000m in 270s) -> Ahead
        let deltaAhead = engine.evaluate(
            athleteDistanceMeters: 1000.0,
            athleteElapsedTimeSeconds: 270.0,
            athleteCurrentPaceSecondsPerKm: 270.0
        )
        #expect(deltaAhead.isAhead == true)
        #expect(deltaAhead.distanceSeparationMeters > 0)
        #expect(deltaAhead.timeDeltaSeconds == 30.0) // 300 - 270 = +30s ahead
        #expect(deltaAhead.formattedDistanceDelta.contains("di Depan"))
        
        // Scenario 2: Running slower than 5:00/km (e.g. 1000m in 330s) -> Behind
        let deltaBehind = engine.evaluate(
            athleteDistanceMeters: 1000.0,
            athleteElapsedTimeSeconds: 330.0,
            athleteCurrentPaceSecondsPerKm: 330.0
        )
        #expect(deltaBehind.isAhead == false)
        #expect(deltaBehind.distanceSeparationMeters < 0)
        #expect(deltaBehind.timeDeltaSeconds == -30.0)
        #expect(deltaBehind.formattedDistanceDelta.contains("di Belakang"))
    }
}
