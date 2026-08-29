import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("Personal Records & Best Efforts Detector Tests")
struct PersonalRecordDetectorTests {
    
    @Test("Test Standard Distance Target Metrics")
    func testStandardDistanceTargets() {
        #expect(StandardDistanceCategory.sprint400m.targetDistanceMeters == 400.0)
        #expect(StandardDistanceCategory.km1.targetDistanceMeters == 1000.0)
        #expect(StandardDistanceCategory.km5.targetDistanceMeters == 5000.0)
        #expect(StandardDistanceCategory.km10.targetDistanceMeters == 10000.0)
    }
    
    @Test("Test Best Effort Detection from 5K Telemetry")
    func testBestEffortsDetection() {
        let detector = PersonalRecordDetector()
        var points: [TelemetrySnapshot] = []
        let baseLat = -6.175392
        let baseLon = 106.827153
        let startTime = Date()
        
        // Generate a 5.2 km route (26 points * 200m) with 4:00/km pace (48s per 200m)
        for i in 0...26 {
            points.append(TelemetrySnapshot(
                timestamp: startTime.addingTimeInterval(Double(i) * 48.0),
                latitude: baseLat + (Double(i) * 0.0018),
                longitude: baseLon,
                altitude: 15.0,
                speedMps: 4.16,
                horizontalAccuracy: 5.0
            ))
        }
        
        let records = detector.detectBestEfforts(from: points, activityTitle: "Tempo 5K")
        
        #expect(!records.isEmpty)
        let has400m = records.contains { $0.distanceCategory == .sprint400m }
        let has1K = records.contains { $0.distanceCategory == .km1 }
        let has5K = records.contains { $0.distanceCategory == .km5 }
        
        #expect(has400m == true)
        #expect(has1K == true)
        #expect(has5K == true)
        
        if let rec5K = records.first(where: { $0.distanceCategory == .km5 }) {
            #expect(rec5K.durationSeconds > 0)
            #expect(rec5K.averagePaceSecondsPerKm < 300.0) // Faster than 5:00/km
        }
    }
}

