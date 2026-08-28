import SwiftUI

/// Floating navigation banner overlay shown in the live recording HUD during active GPX course navigation.
public struct NavigationHUDCardView: View {
    public let guidance: NavigationGuidance
    public var onDismissRoute: (() -> Void)?
    
    public init(
        guidance: NavigationGuidance,
        onDismissRoute: (() -> Void)? = nil
    ) {
        self.guidance = guidance
        self.onDismissRoute = onDismissRoute
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Maneuver Icon
            ZStack {
                Circle()
                    .fill(guidance.isOffCourse ? Color.red.opacity(0.2) : StrideTheme.primaryOrange.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: guidance.currentManeuver.iconName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(guidance.isOffCourse ? Color.red : StrideTheme.primaryOrange)
            }
            
            // Instruction and remaining distance
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(guidance.currentManeuver.rawValue.uppercased())
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(guidance.isOffCourse ? Color.red : StrideTheme.primaryOrange)
                        .tracking(1.0)
                    
                    Spacer()
                    
                    Text("Sisa: \(guidance.formattedRemainingDistance)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.gray)
                }
                
                Text(guidance.instruction)
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
            }
            
            if let onDismiss = onDismissRoute {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.gray.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(red: 0.12, green: 0.12, blue: 0.14).opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(guidance.isOffCourse ? Color.red.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 10, y: 4)
    }
}

