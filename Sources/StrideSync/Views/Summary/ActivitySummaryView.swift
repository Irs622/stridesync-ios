import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// Post-workout summary screen with splits breakdown, elevation metrics, and iOS native design hierarchy.
public struct ActivitySummaryView: View {
    @Bindable public var activity: ActivityRecord
    public var splits: [SplitSnapshot]
    public var telemetryPoints: [TelemetrySnapshot]
    public var onSave: (() -> Void)?
    public var onShare: (() -> Void)?
    
    public init(
        activity: ActivityRecord,
        splits: [SplitSnapshot] = [],
        telemetryPoints: [TelemetrySnapshot] = [],
        onSave: (() -> Void)? = nil,
        onShare: (() -> Void)? = nil
    ) {
        self.activity = activity
        self.splits = splits.isEmpty ? SplitCalculator().calculateSplits(from: telemetryPoints) : splits
        self.telemetryPoints = telemetryPoints
        self.onSave = onSave
        self.onShare = onShare
    }
    
    private var coordinates: [CLLocationCoordinate2D] {
        telemetryPoints.map { $0.coordinate }
    }
    
    private var fastestSplitIndex: Int? {
        splits.min(by: { $0.averagePaceSecondsPerKm < $1.averagePaceSecondsPerKm })?.splitIndex
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header & Activity Title Input
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: activity.activityType.iconName)
                            .foregroundStyle(StrideTheme.primaryOrange)
                        Text(activity.activityType.rawValue.uppercased())
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(StrideTheme.primaryOrange)
                            .tracking(1.0)
                        
                        Text("•")
                            .foregroundStyle(Color.secondary)
                        
                        Text(activity.startTime.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    TextField("Beri Judul Latihan...", text: $activity.title)
                        .font(.system(.title2, design: .rounded, weight: .heavy))
                        .textFieldStyle(.plain)
                        .padding(.vertical, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Route Map Card Preview
                if !coordinates.isEmpty {
                    Map {
                        MapPolyline(coordinates: coordinates)
                            .stroke(StrideTheme.primaryOrange, lineWidth: 5)
                        
                        if let start = coordinates.first {
                            Marker("Start", coordinate: start)
                                .tint(Color.green)
                        }
                        if let end = coordinates.last {
                            Marker("Finish", coordinate: end)
                                .tint(Color.red)
                        }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                }
                
                // Hero Key Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statCard(title: "JARAK", value: activity.formattedDistance, isHero: true)
                    statCard(title: "WAKTU", value: activity.formattedMovingTime, isHero: true)
                    statCard(title: "PACE", value: activity.formattedAveragePace, isHero: true)
                    statCard(title: "ELEVASI", value: activity.formattedElevationGain, isHero: false)
                    statCard(title: "KALORI", value: activity.formattedCalories, isHero: false)
                    statCard(title: "DETAK JANTUNG", value: activity.averageHeartRate != nil ? "\(activity.averageHeartRate!) bpm" : "--", isHero: false)
                }
                .padding(.horizontal, 16)
                
                // Splits Analysis per Kilometer Table
                if !splits.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Analisis Splits (per Kilometer)")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            ForEach(splits) { split in
                                HStack {
                                    Text("Km \(split.splitIndex)")
                                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Text(split.formattedPace)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .monospacedDigit()
                                        .foregroundStyle(split.splitIndex == fastestSplitIndex ? StrideTheme.athleticGreen : Color.primary)
                                    
                                    Spacer()
                                    
                                    if split.splitIndex == fastestSplitIndex {
                                        Text("TERCEPAT")
                                            .font(.system(size: 9, weight: .bold, design: .rounded))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(StrideTheme.athleticGreen.opacity(0.15))
                                            .foregroundStyle(StrideTheme.athleticGreen)
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text(split.formattedDuration)
                                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                                        .monospacedDigit()
                                        .foregroundStyle(Color.secondary)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                
                                if split.id != splits.last?.id {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .background(StrideTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 16)
                    }
                }
                
                // Notes & Gear Assignment
                VStack(alignment: .leading, spacing: 10) {
                    Text("Catatan & Perlengkapan")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        TextField("Bagaimana perasaanmu selama latihan ini?", text: Binding(
                            get: { activity.notes ?? "" },
                            set: { activity.notes = $0.isEmpty ? nil : $0 }
                        ), axis: .vertical)
                        .lineLimit(3...4)
                        .padding(14)
                        .background(StrideTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 16)
                }
                
                // Action Buttons (Save & Share)
                VStack(spacing: 12) {
                    Button {
                        onSave?()
                    } label: {
                        Text("Simpan Aktivitas")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(StrideTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: StrideTheme.primaryOrange.opacity(0.35), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        onShare?()
                    } label: {
                        Label("Bagikan ke Story Instagram", systemImage: "square.and.arrow.up")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(StrideTheme.primaryOrange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(StrideTheme.primaryOrange.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
        .background(StrideTheme.groupedBackground)
        .navigationTitle("Ringkasan Latihan")
    }
    
    private func statCard(title: String, value: String, isHero: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: isHero ? 18 : 16, weight: .heavy, design: .rounded))
                .foregroundStyle(isHero ? StrideTheme.primaryOrange : Color.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
