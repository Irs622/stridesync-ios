import Foundation

/// Persona and tone of voice for AI-generated workout storytelling.
public enum AIStoryTone: String, Sendable, Codable, CaseIterable, Identifiable {
    case motivatingCoach = "Pelatih Penuh Semangat 🔥"
    case tacticalAnalyst = "Analis Taktis & Data 📊"
    case relaxedCasual = "Santai & Menyenangkan ☕️"
    case championHeroic = "Juara Epik 🏆"
    
    public var id: String { rawValue }
}

/// Generated AI narrative story summarizing a workout session.
public struct WorkoutNarrative: Identifiable, Sendable, Codable {
    public var id: UUID
    public var headline: String
    public var storyBody: String
    public var keyHighlights: [String]
    public var recoveryAdvice: String
    public var tone: AIStoryTone
    public var generatedAt: Date
    
    public init(
        id: UUID = UUID(),
        headline: String,
        storyBody: String,
        keyHighlights: [String],
        recoveryAdvice: String,
        tone: AIStoryTone = .motivatingCoach,
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.headline = headline
        self.storyBody = storyBody
        self.keyHighlights = keyHighlights
        self.recoveryAdvice = recoveryAdvice
        self.tone = tone
        self.generatedAt = generatedAt
    }
}
