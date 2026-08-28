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
    
    @Test("Test Segment Matcher Rejects Excessive Detours")
    func testSegmentMatchingRejectsExcessiveDetour() throws {
        let matcher = SegmentMatcher(gateRadiusMeters: 30.0)
        
        let startCoord = CLLocationCoordinate2D(latitude: -6.175000, longitude: 106.827000)
        let endCoord = CLLocationCoordinate2D(latitude: -6.170000, longitude: 106.827000)
        
        let segment = Segment(
            name: "Direct Sprint",
            activityType: .run,
            distanceMeters: 550.0,
            startCoordinate: startCoord,
            endCoordinate: endCoord
        )
        
        let baseTime = Date()
        var telemetry: [TelemetrySnapshot] = []
        
        // Pass start gate
        telemetry.append(TelemetrySnapshot(timestamp: baseTime, latitude: -6.175000, longitude: 106.827000))
        
        // Massive 5km detour to the east
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(300), latitude: -6.175000, longitude: 106.870000))
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(600), latitude: -6.170000, longitude: 106.870000))
        
        // Pass end gate (Distance traveled is > 10 km vs 550m segment)
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(900), latitude: -6.170000, longitude: 106.827000))
        
        // Add padding points to exceed count >= 5
        telemetry.append(TelemetrySnapshot(timestamp: baseTime.addingTimeInterval(930), latitude: -6.169000, longitude: 106.827000))
        
        let efforts = matcher.matchSegments(
            activityPoints: telemetry,
            segments: [segment],
            athleteId: UUID(),
            athleteName: "Detour Runner"
        )
        
        #expect(efforts.isEmpty, "Massive detour should be rejected")
    }
}

