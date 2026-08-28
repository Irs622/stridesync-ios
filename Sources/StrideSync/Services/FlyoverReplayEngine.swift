import Foundation
import CoreLocation

/// Engine responsible for calculating dynamic 3D camera trajectory, pitch, heading, and milestone events for aerial flyover replays.
public final class FlyoverReplayEngine: Sendable {
    public let configuration: FlyoverConfiguration
    
    public init(configuration: FlyoverConfiguration = FlyoverConfiguration()) {
        self.configuration = configuration
    }
    
    /// Generates keyframe camera angles smoothly interpolated along the route polyline.
    public func generateCameraFrames(from coordinates: [CLLocationCoordinate2D]) -> [FlyoverCameraAngle] {
        guard coordinates.count >= 2 else {
            return coordinates.map { FlyoverCameraAngle(centerCoordinate: $0) }
        }
        
        var frames: [FlyoverCameraAngle] = []
        
        for i in 0..<(coordinates.count - 1) {
            let current = coordinates[i]
            let next = coordinates[i + 1]
            
            let heading = calculateBearing(from: current, to: next)
            let frame = FlyoverCameraAngle(
                centerCoordinate: current,
                altitudeMeters: configuration.cameraFollowDistanceMeters,
                pitchDegrees: 60.0,
                headingDegrees: heading
            )
            frames.append(frame)
        }
        
        if let last = coordinates.last {
            let prevHeading = frames.last?.headingDegrees ?? 0.0
            frames.append(FlyoverCameraAngle(
                centerCoordinate: last,
                altitudeMeters: configuration.cameraFollowDistanceMeters,
                pitchDegrees: 60.0,
                headingDegrees: prevHeading
            ))
        }
        
        return frames
    }
    
    /// Generates milestone event markers (Start, Kilometer splits, Peak Elevation, Finish).
    public func generateMilestones(
        from points: [TelemetrySnapshot],
        totalDistanceMeters: Double
    ) -> [FlyoverMilestone] {
        guard !points.isEmpty else { return [] }
        var milestones: [FlyoverMilestone] = []
        
        // 1. Start Milestone
        milestones.append(FlyoverMilestone(
            title: "Start Line 🏁",
            subtitle: "Pemberangkatan",
            coordinate: points[0].coordinate,
            progressFraction: 0.0,
            iconName: "flag.checkered"
        ))
        
        // 2. Kilometer Splits (1km, 2km, 3km...)
        var nextTargetKm = 1000.0
        var currentAccumulatedDistance = 0.0
        
        for i in 1..<points.count {
            let prev = points[i - 1].clLocation
            let curr = points[i].clLocation
            let delta = curr.distance(from: prev)
            currentAccumulatedDistance += delta
            
            if currentAccumulatedDistance >= nextTargetKm && currentAccumulatedDistance <= totalDistanceMeters {
                let kmNumber = Int(nextTargetKm / 1000.0)
                let fraction = min(1.0, currentAccumulatedDistance / max(1.0, totalDistanceMeters))
                
                milestones.append(FlyoverMilestone(
                    title: "KM \(kmNumber) ⚡️",
                    subtitle: String(format: "Pace: %.1f km/h", points[i].speedMps * 3.6),
                    coordinate: points[i].coordinate,
                    progressFraction: fraction,
                    iconName: "\(kmNumber).circle.fill"
                ))
                nextTargetKm += 1000.0
            }
        }
        
        // 3. Peak Altitude Milestone
        if let peakPoint = points.max(by: { $0.altitudeMeters < $1.altitudeMeters }), peakPoint.altitudeMeters > 0 {
            let fraction = Double(points.firstIndex(where: { $0.timestamp == peakPoint.timestamp }) ?? 0) / Double(max(1, points.count - 1))
            milestones.append(FlyoverMilestone(
                title: "Titik Tertinggi ⛰️",
                subtitle: String(format: "+%.0fm DPL", peakPoint.altitudeMeters),
                coordinate: peakPoint.coordinate,
                progressFraction: fraction,
                iconName: "mountain.2.fill"
            ))
        }
        
        // 4. Finish Milestone
        if let last = points.last {
            milestones.append(FlyoverMilestone(
                title: "Finish Line 🏆",
                subtitle: String(format: "Total: %.2f km", totalDistanceMeters / 1000.0),
                coordinate: last.coordinate,
                progressFraction: 1.0,
                iconName: "trophy.fill"
            ))
        }
        
        return milestones.sorted(by: { $0.progressFraction < $1.progressFraction })
    }
    
    private func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let lat1 = start.latitude * .pi / 180.0
        let lon1 = start.longitude * .pi / 180.0
        let lat2 = end.latitude * .pi / 180.0
        let lon2 = end.longitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radians = atan2(y, x)
        let degrees = radians * 180.0 / .pi
        return (degrees + 360.0).truncatingRemainder(dividingBy: 360.0)
    }
}

