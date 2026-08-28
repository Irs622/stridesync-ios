import Testing
import Foundation
@testable import StrideSync

@Suite("Pacing Coach & Target Split Tests")
struct PacingCoachTests {
    
    @Test("Test Pacing Target initialization and presets")
    func testPacingTargetPresets() {
        let sub25 = PacingTarget.sub25_5K
        #expect(sub25.targetDistanceMeters == 5000.0)
        #expect(sub25.targetDurationSeconds == 1500.0)
        #expect(sub25.targetPaceSecondsPerKm == 300.0) // 5:00/km
        #expect(sub25.formattedTargetPace == "5:00 /km")
        
        let sub50 = PacingTarget.sub50_10K
        #expect(sub50.targetPaceSecondsPerKm == 300.0)
        #expect(sub50.formattedTargetDistance == "10.00 km")
    }
    
    @Test("Test Pacing Coach ahead and behind evaluation")
    func testPacingCoachEvaluation() {
        let coach = PacingCoachService(target: .sub25_5K, languageCode: "id-ID")
        
        // At 2.5km, target time is 12.5 mins (750s).
        // Case 1: Athlete is at 720s (30s ahead)
        let aheadFeedback = coach.evaluate(
            distanceMeters: 2500.0,
            elapsedTimeSeconds: 720.0,
            currentPaceSecondsPerKm: 288.0
        )
        #expect(aheadFeedback != nil)
        #expect(aheadFeedback?.isAhead == true)
        #expect(aheadFeedback?.deltaSeconds == 30.0)
        #expect(aheadFeedback?.formattedDelta == "+30s")
        #expect(aheadFeedback?.localizedAnnouncement.contains("lebih cepat") == true)
        
        // Case 2: Athlete is at 780s (30s behind)
        let behindFeedback = coach.evaluate(
            distanceMeters: 2500.0,
            elapsedTimeSeconds: 780.0,
            currentPaceSecondsPerKm: 312.0
        )
        #expect(behindFeedback != nil)
        #expect(behindFeedback?.isAhead == false)
        #expect(behindFeedback?.deltaSeconds == -30.0)
        #expect(behindFeedback?.formattedDelta == "-30s")
        #expect(behindFeedback?.localizedAnnouncement.contains("di belakang") == true)
    }
    
    @Test("Test Pacing Coach periodic voice announcement triggers")
    func testPacingCoachVoiceTriggers() {
        let coach = PacingCoachService(target: .sub25_5K)
        coach.announcementIntervalMeters = 500.0
        
        #expect(coach.shouldTriggerVoiceAnnouncement(currentDistanceMeters: 200.0) == false)
        #expect(coach.shouldTriggerVoiceAnnouncement(currentDistanceMeters: 500.0) == true)
        #expect(coach.shouldTriggerVoiceAnnouncement(currentDistanceMeters: 600.0) == false)
        #expect(coach.shouldTriggerVoiceAnnouncement(currentDistanceMeters: 1000.0) == true)
    }
}

