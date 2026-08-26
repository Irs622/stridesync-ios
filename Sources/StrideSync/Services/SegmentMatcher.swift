import Foundation
import CoreLocation

/// Service for matching GPS activity traces against registered Segment courses and calculating leaderboards.
public struct SegmentMatcher: Sendable {
    public let gateRadiusMeters: Double
    
    public init(gateRadiusMeters: Double = 30.0) {
        self.gateRadiusMeters = gateRadiusMeters
    }
    
    /// Matches an activity's telemetry points against a list of segments and returns any completed efforts.
    public func matchSegments(
        activityPoints: [TelemetrySnapshot],
        segments: [Segment],
        athleteId: UUID,
        athleteName: String
    ) -> [SegmentEffort] {
        guard activityPoints.count >= 5 else { return [] }
        
        var efforts: [SegmentEffort] = []
        
        for segment in segments {
            let startCoord = CLLocation(latitude: segment.startLatitude, longitude: segment.startLongitude)
            let endCoord = CLLocation(latitude: segment.endLatitude, longitude: segment.endLongitude)
            
            var startIndex: Int?
            var endIndex: Int?
            
            // 1. Find entry gate
            for (index, point) in activityPoints.enumerated() {
                let loc = CLLocation(latitude: point.latitude, longitude: point.longitude)
                if loc.distance(from: startCoord) <= gateRadiusMeters {
                    startIndex = index
                    break
                }
            }
            
            guard let sIdx = startIndex else { continue }
            
            // 2. Find exit gate (must occur after entry gate)
            for index in (sIdx + 1)..<activityPoints.count {
                let point = activityPoints[index]
                let loc = CLLocation(latitude: point.latitude, longitude: point.longitude)
                if loc.distance(from: endCoord) <= gateRadiusMeters {
                    endIndex = index
                    break
                }
            }
            
            guard let eIdx = endIndex, eIdx > sIdx else { continue }
            
            // 3. Calculate effort metrics
            let startPoint = activityPoints[sIdx]
            let endPoint = activityPoints[eIdx]
            let effortDuration = max(1.0, endPoint.timestamp.timeIntervalSince(startPoint.timestamp))
            let avgSpeed = segment.distanceMeters / effortDuration
            
            // Extract average HR across segment interval
            let effortPoints = activityPoints[sIdx...eIdx]
            let hrList = effortPoints.compactMap { $0.heartRate }
            let avgHr = hrList.isEmpty ? nil : (hrList.reduce(0, +) / hrList.count)
            
            let isKom = (segment.komTimeSeconds == nil) || (effortDuration < (segment.komTimeSeconds ?? 0))
            
            let effort = SegmentEffort(
                segmentId: segment.id,
                segmentName: segment.name,
                athleteId: athleteId,
                athleteName: athleteName,
                elapsedTimeSeconds: effortDuration,
                averageSpeedMps: avgSpeed,
                averageHeartRate: avgHr,
                dateAchieved: endPoint.timestamp,
                isKOM: isKom,
                isPersonalRecord: true
            )
            
            efforts.append(effort)
        }
        
        return efforts
    }
}

