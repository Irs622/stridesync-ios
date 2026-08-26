import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("SegmentMatcher Tests")
struct SegmentMatcherTests {
    
    @Test("Test Matching Route against Virtual Segment Course")
    func testSegmentMatching() throws {
        let matcher = SegmentMatcher(gateRadiusMeters: 35.0)
        
        let startCoord = CLLocationCoordinate2D(latitude: -6.175000, longitude: 106.827000)
        let endCoord = CLLocationCoordinate2D(latitude: -6.170000, longitude: 106.827000)
        
        let segment = Segment(
            name: "Monas North Sprint",
            activityType: .run,
            distanceMeters: 550.0,
            elevationGainMeters: 5.0,
            startCoordinate: startCoord,
            endCoordinate: endCoord,
            komTimeSeconds: 120.0,
            komAthleteName: "Fast Runner"
        )
        
        let baseTime = Date()
        var telemetry: [TelemetrySnapshot] = []
        
        // Before segment
        telemetry.append(TelemetrySnapshot(timestamp: baseTime, latitude: -6.176000, longitude: 106.827000))
        
        // Pass start gate
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(30), latitude: -6.175000, longitude: 106.827000, heartRate: 160))
        
        // Midpoint
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(60), latitude: -6.172500, longitude: 106.827000, heartRate: 165))
        
        // Pass end gate (Effort duration = 60s -> beats KOM 120s!)
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(90), latitude: -6.170000, longitude: 106.827000, heartRate: 172))
        
        // After segment
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(120), latitude: -6.169000, longitude: 106.827000))
        
        let athleteId = UUID()
        let efforts = matcher.matchSegments(
            activityPoints: telemetry,
            segments: [segment],
            athleteId: athleteId,
            athleteName: "Speedy User"
        )
        
        #expect(efforts.count == 1)
        let effort = efforts[0]
        #expect(effort.segmentName == "Monas North Sprint")
        #expect(effort.elapsedTimeSeconds == 60.0)
        #expect(effort.isKOM == true) // 60s is faster than 120s!
    }
}

