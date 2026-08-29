import Foundation
import CoreLocation

/// Fast rolling-window search engine detecting Personal Best (PR) efforts across standard race distances from GPS telemetry.
public final class PersonalRecordDetector: Sendable {
    public init() {}
    
    /// Detects the fastest continuous segment for each standard distance category from a recorded telemetry stream.
    public func detectBestEfforts(
        from points: [TelemetrySnapshot],
        activityTitle: String = "Latihan",
        achievedDate: Date = Date()
    ) -> [PersonalRecordEffort] {
        guard points.count >= 2 else { return [] }
        
        // Precalculate cumulative distances and timestamps
        var cumulativeDistances: [Double] = [0.0]
        var totalDist = 0.0
        
        for i in 0..<(points.count - 1) {
            let p1 = points[i]
            let p2 = points[i + 1]
            let loc1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
            let loc2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
            let d = loc1.distance(from: loc2)
            totalDist += d
            cumulativeDistances.append(totalDist)
        }
        
        var bestEfforts: [PersonalRecordEffort] = []
        
        for category in StandardDistanceCategory.allCases {
            let targetDistance = category.targetDistanceMeters
            guard totalDist >= targetDistance else { continue }
            
            var minDuration: TimeInterval = .infinity
            var right = 0
            
            for left in 0..<points.count {
                while right < points.count && (cumulativeDistances[right] - cumulativeDistances[left]) < targetDistance {
                    right += 1
                }
                
                if right < points.count {
                    let segmentDist = cumulativeDistances[right] - cumulativeDistances[left]
                    let duration = points[right].timestamp.timeIntervalSince(points[left].timestamp)
                    
                    if duration > 0 && segmentDist >= targetDistance {
                        // Normalize duration to exact target distance
                        let exactDuration = duration * (targetDistance / segmentDist)
                        if exactDuration < minDuration {
                            minDuration = exactDuration
                        }
                    }
                }
            }
            
            if minDuration < .infinity && minDuration > 0 {
                let paceSecPerKm = minDuration / (targetDistance / 1000.0)
                let effort = PersonalRecordEffort(
                    distanceCategory: category,
                    durationSeconds: minDuration,
                    averagePaceSecondsPerKm: paceSecPerKm,
                    achievedDate: achievedDate,
                    activityTitle: activityTitle,
                    isNewRecord: true
                )
                bestEfforts.append(effort)
            }
        }
        
        return bestEfforts
    }
}

