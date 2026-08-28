import SwiftUI
import Charts
import CoreLocation

/// Data point for plotting on the workout elevation and pace interactive chart.
public struct ChartDataPoint: Identifiable {
    public let id = UUID()
    public let distanceKm: Double
    public let altitudeMeters: Double
    public let speedKmh: Double
    public let heartRate: Int?
}

/// Interactive elevation and speed chart with touch scrubbing and gradient area fill.
public struct ElevationPaceChartView: View {
    public let points: [ChartDataPoint]
    @State private var selectedPoint: ChartDataPoint?
    
    public init(telemetryPoints: [TelemetrySnapshot] = []) {
        var runningDistance: Double = 0.0
        var chartPoints: [ChartDataPoint] = []
        
        for i in 0..<telemetryPoints.count {
            let pt = telemetryPoints[i]
            if i > 0 {
                let prev = telemetryPoints[i - 1]
                let loc1 = CLLocation(latitude: pt.latitude, longitude: pt.longitude)
                let loc2 = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
                runningDistance += loc1.distance(from: loc2)
            }
            chartPoints.append(ChartDataPoint(
                distanceKm: runningDistance / 1000.0,
                altitudeMeters: pt.altitude,
                speedKmh: pt.speedMps * 3.6,
                heartRate: pt.heartRate
            ))
        }
        
        if chartPoints.isEmpty {
            self.points = Self.samplePoints()
        } else {
            self.points = chartPoints
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header & Hover/Scrubbed Value Inspector
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Profil Elevasi & Kecepatan")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    
                    if let selected = selectedPoint {
                        HStack(spacing: 12) {
                            Text(String(format: "📍 %.2f km", selected.distanceKm))
                                .font(.caption.bold())
                                .foregroundStyle(StrideTheme.primaryOrange)
                            Text(String(format: "⛰️ %.0f m", selected.altitudeMeters))
                                .font(.caption.bold())
                                .foregroundStyle(Color.primary)
                            Text(String(format: "⚡️ %.1f km/h", selected.speedKmh))
                                .font(.caption.bold())
                                .foregroundStyle(Color.blue)
                            if let hr = selected.heartRate {
                                Text("❤️ \(hr) bpm")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.red)
                            }
                        }
                    } else {
                        Text("Sentuh & geser grafik untuk melihat detail titik rute")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
                Spacer()
            }
            
            // Swift Chart
            Chart {
                ForEach(points) { item in
                    // Elevation Area with Gradient Fill
                    AreaMark(
                        x: .value("Jarak (km)", item.distanceKm),
                        y: .value("Elevasi (m)", item.altitudeMeters)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [StrideTheme.primaryOrange.opacity(0.35), StrideTheme.primaryOrange.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Elevation Stroke Line
                    LineMark(
                        x: .value("Jarak (km)", item.distanceKm),
                        y: .value("Elevasi (m)", item.altitudeMeters)
                    )
                    .foregroundStyle(StrideTheme.primaryOrange)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                
                // Scrubbing Rule Mark
                if let selected = selectedPoint {
                    RuleMark(x: .value("Selected", selected.distanceKm))
                        .foregroundStyle(Color.secondary.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    
                    PointMark(
                        x: .value("Selected", selected.distanceKm),
                        y: .value("Elevasi", selected.altitudeMeters)
                    )
                    .foregroundStyle(StrideTheme.primaryOrange)
                    .symbolSize(80)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .automatic)
            }
            .frame(height: 180)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    guard let plotFrame = proxy.plotFrame else { return }
                                    let x = value.location.x - geo[plotFrame].origin.x
                                    if let distance: Double = proxy.value(atX: x) {
                                        selectedPoint = points.min(by: { abs($0.distanceKm - distance) < abs($1.distanceKm - distance) })
                                    }
                                }
                                .onEnded { _ in
                                    selectedPoint = nil
                                }
                        )
                }
            }
        }
        .padding(16)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private static func samplePoints() -> [ChartDataPoint] {
        var pts: [ChartDataPoint] = []
        for i in 0...20 {
            let dist = Double(i) * 0.25
            let alt = 20.0 + sin(Double(i) * 0.4) * 15.0 + Double(i) * 1.5
            let speed = 12.0 + cos(Double(i) * 0.5) * 3.0
            pts.append(ChartDataPoint(distanceKm: dist, altitudeMeters: alt, speedKmh: speed, heartRate: 145 + i))
        }
        return pts
    }
}

