import Testing
@testable import StrideSync

@Suite("On-Device AI Workout Storyteller Tests")
struct AIWorkoutStorytellerTests {
    
    @Test("Test AI Narrative Generation across different Tones")
    func testStoryGeneration() {
        let storyteller = AIWorkoutStoryteller()
        
        for tone in AIStoryTone.allCases {
            let story = storyteller.generateStory(
                activityTitle: "Morning Tempo Run",
                activityType: .run,
                distanceMeters: 10000.0,
                durationSeconds: 2700.0, // 45:00
                averageSpeedMps: 3.70, // ~4:30 /km
                elevationGainMeters: 45.0,
                averageHeartRate: 158,
                rpeScore: 8,
                tone: tone
            )
            
            #expect(!story.headline.isEmpty)
            #expect(!story.storyBody.isEmpty)
            #expect(story.keyHighlights.count >= 2)
            #expect(!story.recoveryAdvice.isEmpty)
            #expect(story.tone == tone)
        }
    }
}
