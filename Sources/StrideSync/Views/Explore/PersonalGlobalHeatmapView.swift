import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// Interactive dark satellite and vector map displaying athlete's lifetime glowing activity heatmap.
public struct PersonalGlobalHeatmapView: View {
    public var polylines: [[CLLocationCoordinate2D]]
    public var stats: HeatmapExplorationStats
    
    @State private var mapPosition: MapCameraPosition = .automatic
    
    public init(
        polylines: [[CLLocationCoordinate2D]] = Self.sampleHeatmapRoutes(),
        stats: HeatmapExplorationStats? = nil
    ) {
        self.polylines = polylines
        let engine = HeatmapTileEngine()
        let tiles = engine.aggregateTiles(from: polylines)
        self.stats = stats ?? engine.calculateExplorationStats(uniqueTilesCount: tiles.count, totalActivities: polylines.count)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Dark glowing heatmap canvas
            Map(position: $mapPosition) {
                ForEach(0..<polylines.count, id: \.self) { index in
                    MapPolyline(coordinates: polylines[index])
                        .stroke(StrideTheme.primaryOrange.opacity(0.85), lineWidth: 4)
                }
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: .excludingAll))
            .ignoresSafeArea(edges: .bottom)
            
            // Exploration HUD Stats Banner
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(StrideTheme.primaryOrange.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: stats.badge.iconName)
                            .font(.title3)
                            .foregroundStyle(StrideTheme.primaryOrange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stats.badge.rawValue)
                            .font(.system(.subheadline, design: .rounded, weight: .heavy))
                            .foregroundStyle(Color.white)
                        Text("\(stats.totalUniqueTiles) Petak Area • \(stats.formattedArea) Dijelajahi")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(stats.totalActivitiesMapped)")
                            .font(.system(.title3, design: .rounded, weight: .heavy))
                            .foregroundStyle(StrideTheme.primaryOrange)
                        Text("Aktivitas")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.gray)
                    }
                }
                .padding(14)
                .background(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 10, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
        .navigationTitle("Heatmap Global Pribadi")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    public static func sampleHeatmapRoutes() -> [[CLLocationCoordinate2D]] {
        [
            // Route 1 (Monas loop)
            [
                CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272),
                CLLocationCoordinate2D(latitude: -6.1760, longitude: 106.8285),
                CLLocationCoordinate2D(latitude: -6.1775, longitude: 106.8280),
                CLLocationCoordinate2D(latitude: -6.1770, longitude: 106.8265),
                CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272)
            ],
            // Route 2 (GBK Senayan)
            [
                CLLocationCoordinate2D(latitude: -6.2185, longitude: 106.8025),
                CLLocationCoordinate2D(latitude: -6.2195, longitude: 106.8040),
                CLLocationCoordinate2D(latitude: -6.2210, longitude: 106.8035),
                CLLocationCoordinate2D(latitude: -6.2200, longitude: 106.8015),
                CLLocationCoordinate2D(latitude: -6.2185, longitude: 106.8025)
            ],
            // Route 3 (Sudirman Car Free Day)
            [
                CLLocationCoordinate2D(latitude: -6.1950, longitude: 106.8230),
                CLLocationCoordinate2D(latitude: -6.2050, longitude: 106.8210),
                CLLocationCoordinate2D(latitude: -6.2150, longitude: 106.8180),
                CLLocationCoordinate2D(latitude: -6.2250, longitude: 106.8100)
            ]
        ]
    }
}

