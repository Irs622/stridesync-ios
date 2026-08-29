import SwiftUI

/// Compact HUD card displaying nearby community runners detected on the live radar.
public struct BuddyRadarHUDCardView: View {
    public let pings: [RadarTargetPing]
    
    public init(pings: [RadarTargetPing]) {
        self.pings = pings
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.blue)
            }
            
            if let closest = pings.first {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("RADAR TEMAN")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(Color.blue)
                        
                        Text("• \(closest.compassDirection) \(closest.formattedDistance)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.8))
                    }
                    
                    Text("\(closest.buddy.name) (\(closest.buddy.formattedPace))")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                }
            } else {
                Text("Memindai pelari sekitar...")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            
            Spacer()
            
            if pings.count > 1 {
                Text("+\(pings.count - 1)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.4))
                    .clipShape(Capsule())
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

