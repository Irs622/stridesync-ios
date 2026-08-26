import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// Colored route slice representing speed variation across the workout polyline.
public struct RouteSlice: Identifiable {
    public let id = UUID()
    public let coordinates: [CLLocationCoordinate2D]
    public let color: Color
}

/// MapKit route view with multi-colored speed/pace gradient lines and start/finish pins.
public struct GradientRouteMapView: View {
    public let slices: [RouteSlice]
    public let startCoordinate: CLLocationCoordinate2D?
    public let finishCoordinate: CLLocationCoordinate2D?
    
    public init(telemetryPoints: [TelemetrySnapshot] = []) {
        var calculatedSlices: [RouteSlice] = []
        
        if telemetryPoints.count >= 2 {
            let speeds = telemetryPoints.map { $0.speedMps }
            let avgSpeed = speeds.reduce(0, +) / Double(speeds.count)
            let fastThreshold = avgSpeed * 1.15
            let slowThreshold = avgSpeed * 0.85
            
            for i in 0..<(telemetryPoints.count - 1) {
                let p1 = telemetryPoints[i]
                let p2 = telemetryPoints[i + 1]
                let speed = (p1.speedMps + p2.speedMps) / 2.0
                
                let color: Color
                if speed >= fastThreshold {
                    color = StrideTheme.athleticGreen // Fast
                } else if speed <= slowThreshold {
                    color = Color.red // Slow / steep climb
                } else {
                    color = StrideTheme.primaryOrange // Tempo / Moderate
                }
                
                calculatedSlices.append(RouteSlice(
                    coordinates: [p1.coordinate, p2.coordinate],
                    color: color
                ))
            }
        }
        
        self.slices = calculatedSlices
        self.startCoordinate = telemetryPoints.first?.coordinate
        self.finishCoordinate = telemetryPoints.last?.coordinate
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map {
                ForEach(slices) { slice in
                    MapPolyline(coordinates: slice.coordinates)
                        .stroke(slice.color, lineWidth: 6)
                }
                
                if let start = startCoordinate {
                    Marker("Start", coordinate: start)
                        .tint(Color.green)
                }
                
                if let finish = finishCoordinate {
                    Marker("Finish", coordinate: finish)
                        .tint(Color.red)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            
            // Map Pace Legend Pill
            HStack(spacing: 8) {
                legendItem(color: StrideTheme.athleticGreen, label: "Cepat")
                legendItem(color: StrideTheme.primaryOrange, label: "Sedang")
                legendItem(color: Color.red, label: "Lambat")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(12)
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 10, weight: .bold))
        }
    }
}

