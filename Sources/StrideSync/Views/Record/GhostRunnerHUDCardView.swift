import SwiftUI

/// Floating HUD banner on live tracking screen displaying distance and time separation from Virtual Ghost Runner.
public struct GhostRunnerHUDCardView: View {
    public let delta: GhostRunnerDelta
    public let sourceLabel: String
    
    public init(
        delta: GhostRunnerDelta,
        sourceLabel: String = "Rekor Pribadi (PR)"
    ) {
        self.delta = delta
        self.sourceLabel = sourceLabel
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Ghost / Runner Icon Status
            ZStack {
                Circle()
                    .fill(delta.isAhead ? StrideTheme.athleticGreen.opacity(0.2) : Color.purple.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: delta.isAhead ? "figure.run" : "figure.walk")
                    .font(.title3.bold())
                    .foregroundStyle(delta.isAhead ? StrideTheme.athleticGreen : Color.purple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("👻 GHOST PACER")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(delta.isAhead ? StrideTheme.athleticGreen : Color.purple)
                    
                    Text("• \(sourceLabel)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Text(delta.formattedDistanceDelta)
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color.white)
            }
            
            Spacer()
            
            // Time Delta Pill
            VStack(alignment: .trailing, spacing: 2) {
                Text(delta.formattedTimeDelta)
                    .font(.system(.subheadline, design: .rounded, weight: .black))
                    .foregroundStyle(delta.isAhead ? StrideTheme.athleticGreen : Color.red)
                
                Text("Target \(formattedPace(delta.ghostPaceSecondsPerKm))")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(delta.isAhead ? StrideTheme.athleticGreen.opacity(0.4) : Color.purple.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 10, y: 4)
    }
    
    private func formattedPace(_ secondsPerKm: TimeInterval) -> String {
        let min = Int(secondsPerKm) / 60
        let sec = Int(secondsPerKm) % 60
        return String(format: "%d:%02d", min, sec)
    }
}

