import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// Explore screen for discovering nearby running routes, cycling segments, and community courses.
public struct ExploreView: View {
    public var segments: [Segment]
    @State private var selectedActivityType: ActivityType? = nil
    
    public init(segments: [Segment] = []) {
        self.segments = segments.isEmpty ? Self.sampleSegments() : segments
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Interactive Map View
                Map {
                    ForEach(segments) { segment in
                        Marker(segment.name, coordinate: CLLocationCoordinate2D(latitude: segment.startLatitude, longitude: segment.startLongitude))
                            .tint(StrideTheme.primaryOrange)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea(edges: .top)
                
                // Top Floating Category Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterPill(title: "Semua Segmen", icon: "map.fill", isSelected: selectedActivityType == nil) {
                            selectedActivityType = nil
                        }
                        ForEach(ActivityType.allCases) { type in
                            filterPill(title: type.rawValue, icon: type.iconName, isSelected: selectedActivityType == type) {
                                selectedActivityType = type
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // Bottom Segments Cards Carousel
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Segmen Populer Terdekat")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            Spacer()
                            Text("\(segments.count) Lokasi")
                                .font(.caption.bold())
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(segments) { segment in
                                    NavigationLink(destination: SegmentLeaderboardView(segment: segment)) {
                                        segmentPreviewCard(segment: segment)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 16, y: -4)
                }
            }
            .navigationTitle("Eksplorasi")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        PersonalGlobalHeatmapView()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "map.fill")
                                .font(.subheadline)
                            Text("Heatmap")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(StrideTheme.primaryOrange)
                    }
                }
            }
        }
    }
    
    private func filterPill(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2.bold())
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? StrideTheme.primaryOrange : StrideTheme.cardBackground)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func segmentPreviewCard(segment: Segment) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: segment.activityType.iconName)
                        .font(.caption.bold())
                    Text(segment.activityType.rawValue)
                        .font(.caption.bold())
                }
                .foregroundStyle(StrideTheme.primaryOrange)
                
                Spacer()
                
                if let kom = segment.komTimeSeconds {
                    let min = Int(kom) / 60
                    let sec = Int(kom) % 60
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.yellow)
                        Text(String(format: "%d:%02d", min, sec))
                            .font(.caption2.bold())
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            
            Text(segment.name)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .lineLimit(1)
            
            HStack(spacing: 16) {
                statItem(label: "JARAK", value: String(format: "%.1f km", segment.distanceMeters / 1000.0))
                statItem(label: "GRADE", value: String(format: "%.1f%%", segment.averageGradePercent))
                statItem(label: "ELEVASI", value: String(format: "%.0f m", segment.elevationGainMeters))
            }
        }
        .padding(16)
        .frame(width: 240)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
            Text(value)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
        }
    }
    
    public static func sampleSegments() -> [Segment] {
        [
            Segment(
                name: "Monas Loop Sprint",
                activityType: .run,
                distanceMeters: 1200.0,
                elevationGainMeters: 4.0,
                averageGradePercent: 0.3,
                startCoordinate: CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153),
                endCoordinate: CLLocationCoordinate2D(latitude: -6.170000, longitude: 106.827153),
                komTimeSeconds: 225.0,
                komAthleteName: "Budi Santoso",
                totalEffortsCount: 142
            ),
            Segment(
                name: "Sudirman Hill Climb",
                activityType: .ride,
                distanceMeters: 2800.0,
                elevationGainMeters: 48.0,
                averageGradePercent: 3.2,
                startCoordinate: CLLocationCoordinate2D(latitude: -6.210000, longitude: 106.820000),
                endCoordinate: CLLocationCoordinate2D(latitude: -6.230000, longitude: 106.815000),
                komTimeSeconds: 380.0,
                komAthleteName: "Reza Rahardian",
                totalEffortsCount: 89
            ),
            Segment(
                name: "GBK Outer Ring Trail",
                activityType: .run,
                distanceMeters: 950.0,
                elevationGainMeters: 2.0,
                averageGradePercent: 0.1,
                startCoordinate: CLLocationCoordinate2D(latitude: -6.218500, longitude: 106.802000),
                endCoordinate: CLLocationCoordinate2D(latitude: -6.215000, longitude: 106.804000),
                komTimeSeconds: 168.0,
                komAthleteName: "Dian Sastro",
                totalEffortsCount: 310
            )
        ]
    }
}
