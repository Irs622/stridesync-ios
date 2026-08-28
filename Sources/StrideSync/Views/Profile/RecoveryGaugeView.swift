import SwiftUI

/// Visual circular gauge and recommendation card for athlete recovery readiness and training load.
public struct RecoveryGaugeView: View {
    public let metrics: TrainingLoadMetrics
    
    public init(metrics: TrainingLoadMetrics = Self.sampleMetrics()) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(metrics.readiness.color)
                Text("Status Pemulihan & Kesiapan")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Spacer()
                Text(metrics.readiness.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(metrics.readiness.color.opacity(0.15))
                    .foregroundStyle(metrics.readiness.color)
                    .clipShape(Capsule())
            }
            
            // Gauge & Metrics Duo
            HStack(spacing: 20) {
                // Circular Gauge
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 10)
                        .frame(width: 84, height: 84)
                    
                    let progress = min(1.0, max(0.15, (metrics.chronicTrainingLoad / max(1.0, metrics.acuteTrainingLoad))))
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(metrics.readiness.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 84, height: 84)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Image(systemName: metrics.readiness.iconName)
                            .font(.title3)
                            .foregroundStyle(metrics.readiness.color)
                        Text(metrics.formattedRecoveryHours)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Numbers Breakdown
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Beban Sesi (TRIMP):")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(metrics.formattedTrimp)
                            .font(.caption.bold().monospacedDigit())
                    }
                    
                    HStack {
                        Text("Fitness (CTL 28-hr):")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(String(format: "%.0f", metrics.chronicTrainingLoad))
                            .font(.caption.bold().monospacedDigit())
                    }
                    
                    HStack {
                        Text("Fatigue (ATL 7-hr):")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(String(format: "%.0f", metrics.acuteTrainingLoad))
                            .font(.caption.bold().monospacedDigit())
                    }
                    
                    HStack {
                        Text("Form (TSB):")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(String(format: "%+.0f", metrics.trainingStressBalance))
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(metrics.trainingStressBalance >= 0 ? StrideTheme.athleticGreen : StrideTheme.primaryOrange)
                    }
                }
            }
            .padding(.vertical, 4)
            
            // Advice description
            Text(metrics.readiness.adviceDescription)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(16)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    public static func sampleMetrics() -> TrainingLoadMetrics {
        TrainingLoadCalculator().calculateTrainingMetrics(currentSessionTrimp: 85.0)
    }
}

