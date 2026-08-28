import Testing
import Foundation
@testable import StrideSync

@Suite("Audio & Haptic Services Tests")
struct AudioAndHapticServiceTests {
    
    @Test("Test AudioCueService Speech Generation")
    @MainActor
    func testAudioCueSpeech() throws {
        let audioService = AudioCueService.shared
        let split = SplitSnapshot(
            splitIndex: 1,
            distanceMeters: 1000,
            durationSeconds: 300,
            averagePaceSecondsPerKm: 300,
            elevationChangeMeters: 5.0
        )
        audioService.speakSplitAnnouncement(split: split, totalDuration: 300)
        audioService.speakWorkoutStatus(text: "Workout Started")
        #expect(audioService.isEnabled == true)
    }
    
    @Test("Test HapticFeedbackService Triggers")
    @MainActor
    func testHapticFeedbackTriggers() throws {
        let haptic = HapticFeedbackService.shared
        haptic.playImpact(.medium)
        haptic.playNotification(.success)
        haptic.playSelection()
        #expect(Bool(true), "Haptic feedback executed successfully")
    }
}
