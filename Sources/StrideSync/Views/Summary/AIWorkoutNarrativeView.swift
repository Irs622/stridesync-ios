import SwiftUI

/// View presenting AI-generated workout storytelling recap with dynamic tone switching.
public struct AIWorkoutNarrativeView: View {
    public let activity: ActivityRecord
    
    @State private var selectedTone: AIStoryTone = .motivatingCoach
    @State private var currentNarrative: WorkoutNarrative?
    @State private var isRegenerating: Bool = false
    
    public init(activity: ActivityRecord) {
        self.activity = activity
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with AI Sparkles
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(StrideTheme.primaryOrange)
                    Text("Ulasan Narasi AI Pintar")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                Spacer()
                
                Text("On-Device AI")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(StrideTheme.primaryOrange.opacity(0.12))
                    .foregroundStyle(StrideTheme.primaryOrange)
                    .clipShape(Capsule())
            }
            
            // Tone Selector Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AIStoryTone.allCases) { tone in
                        Button {
                            withAnimation(.snappy) {
                                selectedTone = tone
                                generateNarrative()
                            }
                        } label: {
                            Text(tone.rawValue)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTone == tone ? StrideTheme.primaryOrange : Color.primary.opacity(0.06))
                                .foregroundStyle(selectedTone == tone ? Color.white : Color.primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Narrative Card Content
            if let narrative = currentNarrative {
                VStack(alignment: .leading, spacing: 12) {
                    Text(narrative.headline)
                        .font(.system(.subheadline, design: .rounded, weight: .heavy))
                        .foregroundStyle(StrideTheme.primaryOrange)
                    
                    Text(narrative.storyBody)
                        .font(.subheadline)
                        .foregroundStyle(Color.primary.opacity(0.85))
                        .lineSpacing(4)
                    
                    Divider()
                    
                    // Highlights Bullets
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sorotan Utama:")
                            .font(.caption.bold())
                            .foregroundStyle(Color.secondary)
                        
                        ForEach(narrative.keyHighlights, id: \.self) { highlight in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.caption.bold())
                                    .foregroundStyle(StrideTheme.primaryOrange)
                                Text(highlight)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    
                    // Recovery Advice
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundStyle(StrideTheme.athleticGreen)
                        Text(narrative.recoveryAdvice)
                            .font(.caption.bold())
                            .foregroundStyle(StrideTheme.athleticGreen)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(StrideTheme.athleticGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(16)
                .background(StrideTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
            }
        }
        .padding(18)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
        .onAppear {
            generateNarrative()
        }
    }
    
    private func generateNarrative() {
        let storyteller = AIWorkoutStoryteller()
        self.currentNarrative = storyteller.generateStory(
            activityTitle: activity.title,
            activityType: activity.activityType,
            distanceMeters: activity.distanceMeters,
            durationSeconds: activity.durationSeconds,
            averageSpeedMps: activity.averageSpeedMps,
            elevationGainMeters: activity.totalElevationGainMeters,
            averageHeartRate: activity.averageHeartRate,
            rpeScore: activity.rpe,
            tone: selectedTone
        )
    }
}
