import Testing
import Foundation
@testable import StrideSync

@Suite("FITService Tests")
struct FITServiceTests {
    
    @Test("Test FIT Encoding and Decoding")
    func testFITEncodeAndDecode() throws {
        let service = FITService.shared
        let now = Date()
        
        let activity = ActivityRecord(
            title: "Speed Interval Lari",
            activityType: .run,
            startTime: now,
            endTime: now.addingTimeInterval(1200),
            distanceMeters: 3000.0,
            durationSeconds: 1200,
            movingTimeSeconds: 1180,
            totalElevationGainMeters: 25.0,
            averageSpeedMps: 2.5
        )
        
        let points = [
            TelemetrySnapshot(timestamp: now, latitude: -6.175392, longitude: 106.827153, altitude: 10.0, speedMps: 2.5, heartRate: 150),
            TelemetrySnapshot(timestamp: now.addingTimeInterval(5), latitude: -6.175400, longitude: 106.827160, altitude: 11.0, speedMps: 2.8, heartRate: 155)
        ]
        
        let encodedData = service.encode(activity: activity, snapshots: points)
        #expect(encodedData.count > 14)
        
        let decoded = try service.decode(fitData: encodedData)
        #expect(decoded.telemetryPoints.count == 2)
        #expect(abs(decoded.distanceMeters - 3000.0) < 1.0)
        #expect(decoded.activityType == .run)
    }
}
