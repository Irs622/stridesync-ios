import Foundation
import SwiftUI

/// Represents one of the 5 physiological training Heart Rate Zones.
public struct HeartRateZoneInfo: Identifiable, Sendable {
    public let id: Int // 1 to 5
    public let name: String
    public let description: String
    public let rangeBpm: ClosedRange<Int>
    public let durationSeconds: TimeInterval
    public let percentage: Double
    
    public var color: Color {
        switch id {
        case 1: return Color.blue
        case 2: return Color.green
        case 3: return Color.yellow
        case 4: return Color.orange
        case 5: return Color.red
        default: return Color.gray
        }
    }
    
    public var formattedDuration: String {
        let mins = Int(durationSeconds) / 60
        let secs = Int(durationSeconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

/// Calculator for partitioning workout telemetry into 5 Heart Rate training zones.
public struct HeartRateZoneCalculator: Sendable {
    public let maxHeartRate: Int
    
    public init(maxHeartRate: Int = 190) {
        self.maxHeartRate = maxHeartRate
    }
    
    public func calculateZones(from points: [TelemetrySnapshot]) -> [HeartRateZoneInfo] {
        guard !points.isEmpty else { return [] }
        
        let z1Range = Int(Double(maxHeartRate) * 0.50)...Int(Double(maxHeartRate) * 0.60)
        let z2Range = Int(Double(maxHeartRate) * 0.60 + 1)...Int(Double(maxHeartRate) * 0.70)
        let z3Range = Int(Double(maxHeartRate) * 0.70 + 1)...Int(Double(maxHeartRate) * 0.80)
        let z4Range = Int(Double(maxHeartRate) * 0.80 + 1)...Int(Double(maxHeartRate) * 0.90)
        let z5Range = Int(Double(maxHeartRate) * 0.90 + 1)...maxHeartRate
        
        var z1Time: TimeInterval = 0
        var z2Time: TimeInterval = 0
        var z3Time: TimeInterval = 0
        var z4Time: TimeInterval = 0
        var z5Time: TimeInterval = 0
        
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            guard let hr = curr.heartRate ?? prev.heartRate else { continue }
            let dt = max(0, curr.timestamp.timeIntervalSince(prev.timestamp))
            
            if hr <= z1Range.upperBound {
                z1Time += dt
            } else if hr <= z2Range.upperBound {
                z2Time += dt
            } else if hr <= z3Range.upperBound {
                z3Time += dt
            } else if hr <= z4Range.upperBound {
                z4Time += dt
            } else {
                z5Time += dt
            }
        }
        
        let total = z1Time + z2Time + z3Time + z4Time + z5Time
        let safeTotal = total > 0 ? total : 1.0
        
        return [
            HeartRateZoneInfo(id: 1, name: "Z1 Recovery", description: "Pemulihan & Pemanasan (50-60%)", rangeBpm: z1Range, durationSeconds: z1Time, percentage: z1Time / safeTotal),
            HeartRateZoneInfo(id: 2, name: "Z2 Aerobic", description: "Bakar Lemak & Ketahanan (60-70%)", rangeBpm: z2Range, durationSeconds: z2Time, percentage: z2Time / safeTotal),
            HeartRateZoneInfo(id: 3, name: "Z3 Tempo", description: "Meningkatkan Kapasitas Aerobik (70-80%)", rangeBpm: z3Range, durationSeconds: z3Time, percentage: z3Time / safeTotal),
            HeartRateZoneInfo(id: 4, name: "Z4 Threshold", description: "Ambang Laktat & Kecepatan (80-90%)", rangeBpm: z4Range, durationSeconds: z4Time, percentage: z4Time / safeTotal),
            HeartRateZoneInfo(id: 5, name: "Z5 Anaerobic", description: "Performa Maksimal & Sprint (90-100%)", rangeBpm: z5Range, durationSeconds: z5Time, percentage: z5Time / safeTotal)
        ]
    }
}

