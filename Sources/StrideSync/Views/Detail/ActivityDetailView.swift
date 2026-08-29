import SwiftUI
import MapKit

/// Full comprehensive post-activity deep-dive screen featuring interactive charts, gradient maps, climbs, PR medals, splits, and weather.
public struct ActivityDetailView: View {
    public let activity: ActivityRecord
    public let telemetryPoints: [TelemetrySnapshot]
    public let splits: [SplitSnapshot]
    
    @State private var showingShareSheet: Bool = false
    @State private var showingCreateSegmentSheet: Bool = false
    @State private var showingGPXExportedAlert: Bool = false
    @State private var showingFlyoverSheet: Bool = false
    @State private var exportedGPXString: String = ""
    
    private let weatherConditions: WeatherConditions
    private let detectedClimbs: [ClimbSegment]
    private let bestEfforts: [PersonalRecordEffort]
    
    public init(
        activity: ActivityRecord,
        telemetryPoints: [TelemetrySnapshot] = [],
        splits: [SplitSnapshot] = []
    ) {
        self.activity = activity
        let points = telemetryPoints.isEmpty ? Self.sampleTelemetry() : telemetryPoints
        self.telemetryPoints = points
        self.splits = splits.isEmpty ? SplitCalculator().calculateSplits(from: points) : splits
        
        let startCoord = points.first?.coordinate ?? CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153)
        self.weatherConditions = WeatherIntelligenceService.shared.fetchWeather(for: startCoord, date: activity.startTime)
        self.detectedClimbs = ClimbClassifier().detectClimbs(from: points)
        self.bestEfforts = PersonalRecordDetector().detectBestEfforts(from: points, activityTitle: activity.title, achievedDate: activity.startTime)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Info
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Multi-color Speed Gradient Map with 3D Flyover Action
                ZStack(alignment: .bottomTrailing) {
                    GradientRouteMapView(telemetryPoints: telemetryPoints)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                    
                    Button {
                        showingFlyoverSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "video.fill")
                                .font(.caption.bold())
                            Text("3D Flyover")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.85))
                        .foregroundStyle(StrideTheme.primaryOrange)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(StrideTheme.primaryOrange.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 6, y: 2)
                    }
                    .padding(14)
                }
                .padding(.horizontal, 16)
                
                // Weather Conditions & Environmental Stress Widget
                weatherCard
                    .padding(.horizontal, 16)
                
                // Hero Metrics Grid
                metricsGrid
                    .padding(.horizontal, 16)
                
                // Personal Best Efforts & PR Badges (if detected)
                if !bestEfforts.isEmpty {
                    personalRecordsSection
                        .padding(.horizontal, 16)
                }
                
                // Detected Climbs & Mountain Gradient Section (if detected)
                if !detectedClimbs.isEmpty {
                    climbsBreakdownSection
                        .padding(.horizontal, 16)
                }
                
                // Physiological Recovery & Training Load Gauge
                let trainingMetrics = TrainingLoadCalculator().calculateTrainingMetrics(
                    currentSessionTrimp: TrainingLoadCalculator().calculateSessionTRIMP(
                        durationSeconds: activity.durationSeconds,
                        averageHeartRate: activity.averageHeartRate,
                        rpeScore: activity.rpe
                    )
                )
                RecoveryGaugeView(metrics: trainingMetrics)
                    .padding(.horizontal, 16)
                
                // Running Dynamics & Biomechanics Card
                RunningDynamicsCardView(metrics: RunningDynamicsCalculator().estimateDynamics(averageSpeedMps: activity.averageSpeedMps))
                    .padding(.horizontal, 16)
                
                // Interactive Elevation & Pace Chart
                ElevationPaceChartView(telemetryPoints: telemetryPoints)
                    .padding(.horizontal, 16)
                
                // Heart Rate 5-Zone Breakdown
                HeartRateZonesView(zones: HeartRateZoneCalculator().calculateZones(from: telemetryPoints))
                    .padding(.horizontal, 16)
                
                // Splits Table
                splitsSection
                    .padding(.horizontal, 16)
                
                // On-Device AI Workout Storyteller Narrative
                AIWorkoutNarrativeView(activity: activity)
                    .padding(.horizontal, 16)
                
                // Action Buttons (Create Segment, GPX, Share)
                actionButtonsSection
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 32)
            }
        }
        .background(StrideTheme.groupedBackground)
        .navigationTitle(activity.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(StrideTheme.primaryOrange)
                }
            }
        }
        .sheet(isPresented: $showingFlyoverSheet) {
            FlyoverVideoPlayerView(
                telemetryPoints: telemetryPoints,
                activityTitle: activity.title,
                totalDistanceMeters: activity.distanceMeters
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            NavigationStack {
                ScrollView {
                    SocialShareCardView(activity: activity)
                        .padding(.vertical, 20)
                }
                .navigationTitle("Bagikan Story")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Tutup") { showingShareSheet = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateSegmentSheet) {
            CreateSegmentView(telemetryPoints: telemetryPoints) { newSegment in
                HapticFeedbackService.shared.playNotification(.success)
                showingCreateSegmentSheet = false
            }
        }
        .alert("File GPX Berhasil Dibuat", isPresented: $showingGPXExportedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("File GPX 1.1 XML (\(telemetryPoints.count) titik) telah siap diekspor ke aplikasi lain.")
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: activity.activityType.iconName)
                    .foregroundStyle(StrideTheme.primaryOrange)
                Text(activity.activityType.rawValue.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(StrideTheme.primaryOrange)
                
                Text("•")
                    .foregroundStyle(Color.secondary)
                
                Text(activity.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            
            Text(activity.title)
                .font(.system(.title2, design: .rounded, weight: .heavy))
            
            if let notes = activity.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .padding(.top, 2)
            }
        }
    }
    
    private var weatherCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: weatherConditions.iconName)
                    .font(.title)
                    .foregroundStyle(Color.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(weatherConditions.conditionDescription) • \(weatherConditions.formattedTemperature)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                    Text("Terasa Seperti \(weatherConditions.formattedApparentTemperature) • Kelembaban \(weatherConditions.formattedHumidity) • Angin \(weatherConditions.formattedWind)")
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
            }
            
            let advice = WeatherIntelligenceService.shared.generateWeatherAdvice(conditions: weatherConditions)
            HStack(spacing: 6) {
                Image(systemName: weatherConditions.thermalStressCategory.iconName)
                    .font(.caption.bold())
                    .foregroundStyle(weatherConditions.thermalStressCategory == .normal ? StrideTheme.athleticGreen : StrideTheme.primaryOrange)
                Text(advice)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Color.yellow)
                Text("Rekor Terbaik (Best Efforts)")
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(bestEfforts) { effort in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: effort.distanceCategory.iconName)
                                    .foregroundStyle(StrideTheme.primaryOrange)
                                Text(effort.distanceCategory.rawValue)
                                    .font(.caption.bold())
                                Spacer()
                                Image(systemName: "medal.fill")
                                    .foregroundStyle(Color.yellow)
                            }
                            
                            Text(effort.formattedDuration)
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .monospacedDigit()
                            
                            Text("Pace: \(effort.formattedPace)")
                                .font(.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(12)
                        .frame(width: 160)
                        .background(StrideTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private var climbsBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "mountain.2.fill")
                    .foregroundStyle(Color.purple)
                Text("Tanjakan Terdeteksi (Climb Segments)")
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            
            VStack(spacing: 8) {
                ForEach(detectedClimbs) { climb in
                    HStack(spacing: 12) {
                        Text(climb.category.shortLabel)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: climb.category.badgeColorHex))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(climb.formattedDistance) • \(climb.formattedElevationGain)")
                                .font(.subheadline.bold())
                            Text("\(climb.formattedAverageGrade) (Maks: \(climb.formattedMaxGrade))")
                                .font(.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCell(title: "JARAK", value: activity.formattedDistance, isHero: true)
            statCell(title: "WAKTU", value: activity.formattedMovingTime, isHero: true)
            statCell(title: "PACE", value: activity.formattedAveragePace, isHero: true)
            statCell(title: "ELEVASI", value: activity.formattedElevationGain, isHero: false)
            statCell(title: "KALORI", value: activity.formattedCalories, isHero: false)
            if let rpe = activity.rpe {
                statCell(title: "RPE KELELAHAN", value: "\(rpe)/10 ⚡️", isHero: false)
            } else {
                statCell(title: "MAX SPEED", value: String(format: "%.1f km/h", activity.maxSpeedMps * 3.6), isHero: false)
            }
        }
    }
    
    private func statCell(title: String, value: String, isHero: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
            Text(value)
                .font(.system(size: isHero ? 18 : 15, weight: .heavy, design: .rounded))
                .foregroundStyle(isHero ? StrideTheme.primaryOrange : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Analisis Splits (1 KM)")
                .font(.system(.headline, design: .rounded, weight: .bold))
            
            VStack(spacing: 0) {
                ForEach(splits) { split in
                    HStack {
                        Text("Km \(split.splitIndex)")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .frame(width: 50, alignment: .leading)
                        Text(split.formattedPace)
                            .font(.subheadline.bold())
                            .monospacedDigit()
                        Spacer()
                        Text(split.formattedDuration)
                            .font(.subheadline)
                            .monospacedDigit()
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    
                    if split.id != splits.last?.id {
                        Divider()
                    }
                }
            }
            .background(StrideTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Create Segment Button
            Button {
                showingCreateSegmentSheet = true
            } label: {
                Label("Buat Segmen dari Rute Ini", systemImage: "flag.badge.ellipsis")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(StrideTheme.primaryOrange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(StrideTheme.primaryOrange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            
            // Export GPX Button
            Button {
                let gpx = GPXService().exportToGPX(activity: activity, points: telemetryPoints)
                exportedGPXString = gpx
                showingGPXExportedAlert = true
            } label: {
                Label("Ekspor Format GPX 1.1 XML", systemImage: "arrow.down.doc.fill")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    private static func sampleTelemetry() -> [TelemetrySnapshot] {
        let baseLat = -6.175392
        let baseLon = 106.827153
        var list: [TelemetrySnapshot] = []
        for i in 0..<25 {
            list.append(TelemetrySnapshot(
                timestamp: Date().addingTimeInterval(Double(i) * 45),
                latitude: baseLat + Double(i) * 0.0015,
                longitude: baseLon,
                altitude: 15.0 + Double(i) * 1.2,
                speedMps: i == 12 ? 0.3 : (i % 2 == 0 ? 4.2 : 3.8),
                horizontalAccuracy: 5.0,
                heartRate: 145 + i
            ))
        }
        return list
    }
}

// Extension to support Hex Colors in SwiftUI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
