import Foundation
import CoreLocation

/// Calculates distance splits (e.g. per kilometer or per mile) from telemetry points.
public struct SplitCalculator: Sendable {
    public let splitIntervalMeters: Double
    
    public init(splitIntervalMeters: Double = 1000.0) {
        self.splitIntervalMeters = splitIntervalMeters
    }
    
    /// Computes array of `SplitSnapshot` from sequential telemetry points.
    public func calculateSplits(from points: [TelemetrySnapshot]) -> [SplitSnapshot] {
        guard points.count >= 2 else { return [] }
        
        var splits: [SplitSnapshot] = []
        var currentSplitIndex = 1
        var currentSplitAccumulatedDistance = 0.0
        var currentSplitStartTime = points[0].timestamp
        var currentSplitStartAltitude = points[0].altitude
        var currentSplitHeartRates: [Int] = []
        
        for i in 1..<points.count {
            let prevPoint = points[i - 1]
            let currPoint = points[i]
            
            let prevLoc = CLLocation(latitude: prevPoint.latitude, longitude: prevPoint.longitude)
            let currLoc = CLLocation(latitude: currPoint.latitude, longitude: currPoint.longitude)
            let stepDist = currLoc.distance(from: prevLoc)
            
            currentSplitAccumulatedDistance += stepDist
            if let hr = currPoint.heartRate {
                currentSplitHeartRates.append(hr)
            }
            
            // Check if we hit the interval threshold (1000m)
            if currentSplitAccumulatedDistance >= splitIntervalMeters {
                let splitDuration = currPoint.timestamp.timeIntervalSince(currentSplitStartTime)
                let paceSeconds = currentSplitAccumulatedDistance > 0 ? (splitDuration / (currentSplitAccumulatedDistance / 1000.0)) : 0.0
                let elevChange = currPoint.altitude - currentSplitStartAltitude
                let avgHr = currentSplitHeartRates.isEmpty ? nil : (currentSplitHeartRates.reduce(0, +) / currentSplitHeartRates.count)
                
                let split = SplitSnapshot(
                    splitIndex: currentSplitIndex,
                    distanceMeters: currentSplitAccumulatedDistance,
                    durationSeconds: splitDuration,
                    averagePaceSecondsPerKm: paceSeconds,
                    elevationChangeMeters: elevChange,
                    averageHeartRate: avgHr
                )
                splits.append(split)
                
                // Reset for next split
                currentSplitIndex += 1
                currentSplitAccumulatedDistance = 0.0
                currentSplitStartTime = currPoint.timestamp
                currentSplitStartAltitude = currPoint.altitude
                currentSplitHeartRates.removeAll()
            }
        }
        
        // Add final partial split if there is remaining distance (> 50m)
        if currentSplitAccumulatedDistance > 50.0, let lastPoint = points.last {
            let splitDuration = lastPoint.timestamp.timeIntervalSince(currentSplitStartTime)
            let paceSeconds = currentSplitAccumulatedDistance > 0 ? (splitDuration / (currentSplitAccumulatedDistance / 1000.0)) : 0.0
            let elevChange = lastPoint.altitude - currentSplitStartAltitude
            let avgHr = currentSplitHeartRates.isEmpty ? nil : (currentSplitHeartRates.reduce(0, +) / currentSplitHeartRates.count)
            
            let split = SplitSnapshot(
                splitIndex: currentSplitIndex,
                distanceMeters: currentSplitAccumulatedDistance,
                durationSeconds: max(1.0, splitDuration),
                averagePaceSecondsPerKm: paceSeconds,
                elevationChangeMeters: elevChange,
                averageHeartRate: avgHr
            )
            splits.append(split)
        }
        
        return splits
    }
}

