import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// Tool allowing athletes to create custom virtual segments from their completed activity routes.
public struct CreateSegmentView: View {
    public let telemetryPoints: [TelemetrySnapshot]
    public var onSegmentCreated: ((Segment) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var segmentName: String = ""
    @State private var startIndex: Double = 0
    @State private var endIndex: Double = 1
    
    public init(telemetryPoints: [TelemetrySnapshot] = [], onSegmentCreated: ((Segment) -> Void)? = nil) {
        self.telemetryPoints = telemetryPoints.isEmpty ? Self.sampleRoute() : telemetryPoints
        self.onSegmentCreated = onSegmentCreated
        self._endIndex = State(initialValue: Double(max(1, (telemetryPoints.isEmpty ? Self.sampleRoute() : telemetryPoints).count - 1)))
    }
    
    private var validStartIndex: Int {
        min(Int(startIndex), Int(endIndex))
    }
    
    private var validEndIndex: Int {
        max(Int(startIndex), min(Int(endIndex), telemetryPoints.count - 1))
    }
    
    private var selectedSegmentCoordinates: [CLLocationCoordinate2D] {
        guard telemetryPoints.count >= 2 else { return [] }
        let slice = telemetryPoints[validStartIndex...validEndIndex]
        return slice.map { $0.coordinate }
    }
    
    private var segmentDistanceMeters: Double {
        guard selectedSegmentCoordinates.count >= 2 else { return 0 }
        var dist = 0.0
        for i in 0..<(selectedSegmentCoordinates.count - 1) {
            let c1 = selectedSegmentCoordinates[i]
            let c2 = selectedSegmentCoordinates[i + 1]
            let loc1 = CLLocation(latitude: c1.latitude, longitude: c1.longitude)
            let loc2 = CLLocation(latitude: c2.latitude, longitude: c2.longitude)
            dist += loc1.distance(from: loc2)
        }
        return dist
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Interactive Map with Segment Selection Highlight
                Map {
                    if telemetryPoints.count >= 2 {
                        MapPolyline(coordinates: telemetryPoints.map { $0.coordinate })
                            .stroke(Color.gray.opacity(0.4), lineWidth: 4)
                    }
                    
                    if selectedSegmentCoordinates.count >= 2 {
                        MapPolyline(coordinates: selectedSegmentCoordinates)
                            .stroke(StrideTheme.primaryOrange, lineWidth: 6)
                    }
                    
                    if let start = selectedSegmentCoordinates.first {
                        Marker("Start Segmen", coordinate: start)
                            .tint(Color.green)
                    }
                    if let end = selectedSegmentCoordinates.last {
                        Marker("Finish Segmen", coordinate: end)
                            .tint(Color.red)
                    }
                }
                .frame(height: 250)
                
                Form {
                    Section("Nama Segmen") {
                        TextField("Contoh: Sprint Monas Utara, Tanjakan Sudirman", text: $segmentName)
                    }
                    
                    Section("Titik Awal & Akhir Segmen") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Titik Awal (Start): Titik \(validStartIndex + 1)")
                                .font(.caption.bold())
                            Slider(value: $startIndex, in: 0...Double(max(1, telemetryPoints.count - 2)), step: 1)
                                .tint(Color.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Titik Akhir (Finish): Titik \(validEndIndex + 1)")
                                .font(.caption.bold())
                            Slider(value: $endIndex, in: Double(validStartIndex + 1)...Double(max(1, telemetryPoints.count - 1)), step: 1)
                                .tint(Color.red)
                        }
                    }
                    
                    Section("Estimasi Metrik Segmen") {
                        HStack {
                            Text("Panjang Segmen")
                            Spacer()
                            Text(String(format: "%.2f km", segmentDistanceMeters / 1000.0))
                                .font(.headline.bold())
                                .foregroundStyle(StrideTheme.primaryOrange)
                        }
                    }
                }
            }
            .navigationTitle("Buat Segmen Baru")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Buat") {
                        if let startCoord = selectedSegmentCoordinates.first, let endCoord = selectedSegmentCoordinates.last {
                            let newSegment = Segment(
                                name: segmentName.isEmpty ? "Segmen Baru" : segmentName,
                                activityType: .run,
                                distanceMeters: segmentDistanceMeters,
                                elevationGainMeters: 10.0,
                                averageGradePercent: 1.2,
                                startCoordinate: startCoord,
                                endCoordinate: endCoord
                            )
                            onSegmentCreated?(newSegment)
                            dismiss()
                        }
                    }
                    .disabled(segmentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private static func sampleRoute() -> [TelemetrySnapshot] {
        let baseLat = -6.175392
        let baseLon = 106.827153
        var list: [TelemetrySnapshot] = []
        for i in 0..<20 {
            list.append(TelemetrySnapshot(
                timestamp: Date().addingTimeInterval(Double(i) * 30),
                latitude: baseLat + Double(i) * 0.001,
                longitude: baseLon,
                altitude: 15.0 + Double(i) * 0.5,
                speedMps: 4.0,
                horizontalAccuracy: 5.0,
                heartRate: 150
            ))
        }
        return list
    }
}

