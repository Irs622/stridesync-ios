import SwiftUI
import MapKit

/// Full comprehensive post-activity deep-dive screen featuring interactive charts, gradient maps, splits, and weather.
public struct ActivityDetailView: View {
    public let activity: ActivityRecord
    public let telemetryPoints: [TelemetrySnapshot]
    public let splits: [SplitSnapshot]
    
    @State private var showingShareSheet: Bool = false
    @State private var showingCreateSegmentSheet: Bool = false
    @State private var showingGPXExportedAlert: Bool = false
    @State private var exportedGPXString: String = ""
    
    public init(
        activity: ActivityRecord,
        telemetryPoints: [TelemetrySnapshot] = [],
        splits: [SplitSnapshot] = []
    ) {
        self.activity = activity
        self.telemetryPoints = telemetryPoints.isEmpty ? Self.sampleTelemetry() : telemetryPoints
        self.splits = splits.isEmpty ? SplitCalculator().calculateSplits(from: self.telemetryPoints) : splits
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Info
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Multi-color Speed Gradient Map
                GradientRouteMapView(telemetryPoints: telemetryPoints)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                
                // Weather Conditions Widget
                weatherCard
                    .padding(.horizontal, 16)
                
                // Hero Metrics Grid
                metricsGrid
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
        HStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.title)
                .foregroundStyle(Color.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Cerah Berawan • 24°C")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Text("Kelembaban 72% • Angin 8 km/h Barat Daya")
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

