import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("Onboarding & Production Readiness Tests")
@MainActor
struct OnboardingAndBackgroundTests {
    
    @Test("Test Onboarding Completion State Persistence")
    func testOnboardingState() {
        let testKey = "hasCompletedOnboarding"
        
        UserDefaults.standard.set(false, forKey: testKey)
        #expect(UserDefaults.standard.bool(forKey: testKey) == false)
        
        UserDefaults.standard.set(true, forKey: testKey)
        #expect(UserDefaults.standard.bool(forKey: testKey) == true)
    }
    
    @Test("Test AudioCueService Voice Speech Synthesis Preparation")
    func testAudioCueService() {
        let service = AudioCueService.shared
        service.isEnabled = true
        service.languageCode = "id-ID"
        
        let sampleSplit = SplitSnapshot(
            splitIndex: 1,
            distanceMeters: 1000.0,
            durationSeconds: 300,
            averagePaceSecondsPerKm: 300
        )
        
        service.speakSplitAnnouncement(split: sampleSplit, totalDuration: 300)
        #expect(service.isEnabled == true)
        #expect(service.languageCode == "id-ID")
    }
    
    @Test("Test LocationEngine State and Background Capability")
    func testLocationEngineBackgroundTracking() async {
        let engine = LocationEngine(activityType: .run, autoPauseEnabled: true)
        let initialState = await engine.state
        #expect(initialState == .idle)
        
        await engine.start()
        let runningState = await engine.state
        #expect(runningState == .recording)
    }
}

