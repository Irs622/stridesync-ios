import SwiftUI

/// Profile view presenting aerobic VO2 Max capacity gauge, age-group percentile, and projected race finish times.
public struct VO2MaxPredictorView: View {
    public let vo2Score: VO2MaxScore
    
    public init(vo2Score: VO2MaxScore? = nil) {
        if let score = vo2Score {
            self.vo2Score = score
        } else {
            let calculator = VO2MaxCalculator(restingHeartRate: 56, maxHeartRate: 192, age: 27, isMale: true)
            self.vo2Score = calculator.estimateVO2Max(averageSpeedMps: 4.16, averageHeartRate: 154)
        }
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Score Circular Gauge Card
                scoreHeroCard
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Race Predictions 4-Grid
                racePredictionsSection
                    .padding(.horizontal, 16)
                
                // Fitness Advice Card
                adviceCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
        }
        .background(StrideTheme.groupedBackground)
        .navigationTitle("VO2 Max & Prediksi Lomba")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private var scoreHeroCard: some View {
        VStack(spacing: 16) {
            Text("KAPASITAS AEROBIK MAKSIMAL")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(Color.secondary)
            
            // Circular Score Dial
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 16)
                    .frame(width: 170, height: 170)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(1.0, (vo2Score.score - 25.0) / 55.0)))
                    .stroke(
                        LinearGradient(
                            colors: [StrideTheme.primaryOrange, StrideTheme.athleticGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 170, height: 170)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text(vo2Score.formattedScore)
                        .font(.system(size: 46, weight: .black, design: .rounded))
                    Text("ml/kg/min")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.secondary)
                }
            }
            
            // Category & Percentile Badges
            HStack(spacing: 12) {
                Text(vo2Score.category.rawValue)
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(StrideTheme.primaryOrange.opacity(0.15))
                    .foregroundStyle(StrideTheme.primaryOrange)
                    .clipShape(Capsule())
                
                Text("Top \(100 - vo2Score.ageGroupPercentile)% Seusiamu 🏆")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(StrideTheme.athleticGreen.opacity(0.15))
                    .foregroundStyle(StrideTheme.athleticGreen)
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
    }
    
    private var racePredictionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Proyeksi Waktu Balapan")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Spacer()
                Text("Berdasarkan VO2 Max")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(vo2Score.predictions) { prediction in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(prediction.raceDistance.rawValue)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(StrideTheme.primaryOrange)
                        
                        Text(prediction.formattedTime)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.caption2)
                            Text(prediction.formattedPace)
                                .font(.caption.bold())
                        }
                        .foregroundStyle(Color.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var adviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.yellow)
                Text("Analisis Pelatih Cerdas")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
            }
            
            Text(vo2Score.category.adviceDescription)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .lineSpacing(3)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

