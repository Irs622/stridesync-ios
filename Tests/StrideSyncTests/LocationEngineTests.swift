import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("LocationEngine Tests")
struct LocationEngineTests {
    
    @Test("Test Starting and Ingesting Valid GPS Coordinates")
    func testLocationIngestionAndDistance() async throws {
        let engine = LocationEngine(activityType: .run, autoPauseEnabled: false)
        
        await engine.start()
        let state = await engine.state
        #expect(state == .recording)
        
        let baseTime = Date()
        
        // Point 1 (Monas, Jakarta)
        let loc1 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153),
            altitude: 15.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0,
            speed: 3.5,
            timestamp: baseTime
        )
        
        let m1 = await engine.processLocation(loc1)
        #expect(m1.distanceMeters == 0.0)
        
        // Point 2 (100 meters north)
        let loc2 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -6.174500, longitude: 106.827153),
            altitude: 18.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0,
            speed: 3.8,
            timestamp: baseTime.addingTimeInterval(25)
        )
        
        let m2 = await engine.processLocation(loc2)
        #expect(m2.distanceMeters > 50.0)
        #expect(m2.totalElevationGainMeters >= 3.0)
        
        let (summary, points) = await engine.finish()
        #expect(summary.distanceMeters > 50.0)
        #expect(points.count == 2)
    }
    
    @Test("Test Accuracy Filtering rejects bad GPS coordinates")
    func testAccuracyFilter() async throws {
        let engine = LocationEngine(activityType: .run, maxAcceptableAccuracyMeters: 25.0)
        await engine.start()
        
        // Bad accuracy point (> 25m)
        let badLoc = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153),
            altitude: 10.0,
            horizontalAccuracy: 65.0, // bad
            verticalAccuracy: 10.0,
            timestamp: Date()
        )
        
        let metrics = await engine.processLocation(badLoc)
        let snapshots = await engine.telemetrySnapshots
        #expect(snapshots.isEmpty)
        #expect(metrics.distanceMeters == 0.0)
    }
}

