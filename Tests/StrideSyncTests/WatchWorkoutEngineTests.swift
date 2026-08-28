import Testing
import Foundation
@testable import StrideSync

@Suite("Standalone watchOS Workout Engine Tests")
struct WatchWorkoutEngineTests {
    
    @Test("Test Watch workout lifecycle and calculations")
    @MainActor
    func testWatchWorkoutLifecycle() {
        let engine = WatchWorkoutEngine.shared
        #expect(engine.state == .notStarted)
        
        engine.startStandaloneWorkout(activityType: .run)
        #expect(engine.state == .running)
        
        engine.updateDistance(5000.0)
        #expect(engine.distanceMeters == 5000.0)
        
        engine.updateHeartRate(162)
        #expect(engine.heartRateBpm == 162)
        
        engine.pauseStandaloneWorkout()
        #expect(engine.state == .paused)
        
        engine.resumeStandaloneWorkout()
        #expect(engine.state == .running)
        
        let summary = engine.finishStandaloneWorkout()
        #expect(summary.distance == 5000.0)
        #expect(engine.state == .notStarted)
    }
}

