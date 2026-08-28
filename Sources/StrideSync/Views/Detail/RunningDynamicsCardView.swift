import SwiftUI

/// Detailed biomechanics analytics card displaying Cadence SPM, Vertical Oscillation, GCT, and Stride Length.
public struct RunningDynamicsCardView: View {
    public let metrics: RunningDynamicsMetrics
    
    public init(metrics: RunningDynamicsMetrics = RunningDynamicsMetrics()) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "figure.run.motion")
                        .foregroundStyle(StrideTheme.primaryOrange)
                    Text("Running Dynamics & Biomekanika")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                Spacer()
                Text(metrics.cadenceZone.rawValue)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(StrideTheme.athleticGreen.opacity(0.15))
                    .foregroundStyle(StrideTheme.athleticGreen)
                    .clipShape(Capsule())
            }
            
            // 4-Grid Biomechanics Matrix
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                dynamicsCell(
                    title: "IRAMA LANGKAH (CADENCE)",
                    value: metrics.formattedCadence,
                    icon: "metronome.fill",
                    subtext: "Max: \(metrics.maxCadenceSpm) SPM"
                )
                
                dynamicsCell(
                    title: "OSILASI VERTIKAL",
                    value: metrics.formattedOscillation,
                    icon: "arrow.up.and.down.circle.fill",
                    subtext: "Rasio Vertikal: \(metrics.formattedVerticalRatio)"
                )
                
                dynamicsCell(
                    title: "WAKTU KONTAK TANAH",
                    value: metrics.formattedGroundContact,
                    icon: "shoeprints.fill",
                    subtext: "Efisiensi Melangkah"
                )
                
                dynamicsCell(
                    title: "PANJANG LANGKAH",
                    value: metrics.formattedStrideLength,
                    icon: "ruler.fill",
                    subtext: "Rata-rata per Langkah"
                )
            }
        }
        .padding(18)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
    }
    
    private func dynamicsCell(title: String, value: String, icon: String, subtext: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(StrideTheme.primaryOrange)
                Text(title)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
            
            Text(subtext)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
