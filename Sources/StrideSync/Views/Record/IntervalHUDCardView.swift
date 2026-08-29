import SwiftUI

/// Compact HUD card showing live interval step progress, circular gauge, and next step preview.
public struct IntervalHUDCardView: View {
    public let progress: IntervalStepProgress
    public var onSkipStep: (() -> Void)?
    
    public init(progress: IntervalStepProgress, onSkipStep: (() -> Void)? = nil) {
        self.progress = progress
        self.onSkipStep = onSkipStep
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Circular Progress Indicator
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 4)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress.progressFraction))
                    .stroke(
                        progress.step.stepType == .intervalWork ? StrideTheme.primaryOrange : (progress.step.stepType == .recoveryRest ? StrideTheme.athleticGreen : Color.blue),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 44, height: 44)
                    .animation(.easeInOut(duration: 0.2), value: progress.progressFraction)
                
                Image(systemName: progress.step.stepType.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            
            // Step Info & Remaining Target
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("STEP \(progress.currentStepIndex + 1)/\(progress.totalSteps)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(StrideTheme.primaryOrange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(StrideTheme.primaryOrange.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text(progress.step.stepType.rawValue)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.white)
                }
                
                Text(progress.formattedRemaining)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                if let targetPace = progress.step.formattedTargetPace {
                    Text("Target: \(targetPace)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Skip Step Button
            Button {
                HapticFeedbackService.shared.playImpact(.medium)
                onSkipStep?()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(10)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(StrideTheme.primaryOrange.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 8, y: 3)
    }
}

