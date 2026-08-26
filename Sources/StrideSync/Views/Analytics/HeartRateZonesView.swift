import SwiftUI

/// Detailed visualization of the 5 physiological Heart Rate training zones.
public struct HeartRateZonesView: View {
    public let zones: [HeartRateZoneInfo]
    
    public init(zones: [HeartRateZoneInfo] = []) {
        if zones.isEmpty {
            self.zones = HeartRateZoneCalculator().calculateZones(from: [])
        } else {
            self.zones = zones
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.red)
                Text("Zona Denyut Jantung (Heart Rate Zones)")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Spacer()
            }
            
            // Visual Stacked Distribution Bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(zones) { zone in
                        let width = max(4, geo.size.width * CGFloat(zone.percentage))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(zone.color)
                            .frame(width: width, height: 12)
                    }
                }
            }
            .frame(height: 12)
            
            // Detailed Zones List
            VStack(spacing: 8) {
                ForEach(zones) { zone in
                    HStack {
                        Circle()
                            .fill(zone.color)
                            .frame(width: 10, height: 10)
                        
                        Text(zone.name)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        
                        Text("(\(zone.rangeBpm.lowerBound)-\(zone.rangeBpm.upperBound) bpm)")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                        
                        Spacer()
                        
                        Text(zone.formattedDuration)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                        
                        Text(String(format: "%.0f%%", zone.percentage * 100))
                            .font(.caption.bold())
                            .frame(width: 38, alignment: .trailing)
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.vertical, 2)
                    
                    if zone.id != zones.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

