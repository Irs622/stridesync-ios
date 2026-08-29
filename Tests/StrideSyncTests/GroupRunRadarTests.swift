import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("Group Run & Live Buddy Radar Tests")
struct GroupRunRadarTests {
    
    @Test("Test Bearing Calculation North and East")
    func testBearingCalculation() {
        let engine = GroupRunRadarEngine()
        
        let start = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let north = CLLocationCoordinate2D(latitude: 1.0, longitude: 0.0)
        let east = CLLocationCoordinate2D(latitude: 0.0, longitude: 1.0)
        
        let bearingNorth = engine.calculateBearing(from: start, to: north)
        #expect(abs(bearingNorth - 0.0) < 1.0)
        
        let bearingEast = engine.calculateBearing(from: start, to: east)
        #expect(abs(bearingEast - 90.0) < 1.0)
    }
    
    @Test("Test Radar Scanning and Relative Ping Filtering")
    func testRadarScanning() {
        let athleteCoord = CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153)
        let closeBuddy = BuddyRunner(
            name: "Alex",
            latitude: athleteCoord.latitude + 0.002,
            longitude: athleteCoord.longitude,
            activityType: .run
        )
        let farBuddy = BuddyRunner(
            name: "Far Away Runner",
            latitude: athleteCoord.latitude + 0.05, // ~5.5km away
            longitude: athleteCoord.longitude,
            activityType: .run
        )
        
        let engine = GroupRunRadarEngine(initialBuddies: [closeBuddy, farBuddy])
        engine.radarRangeMeters = 1000.0 // 1km range
        
        let pings = engine.scanRadar(currentCoordinate: athleteCoord, activityType: .run)
        #expect(pings.count == 1)
        #expect(pings.first?.buddy.name == "Alex")
        #expect(pings.first?.compassDirection == "N")
    }
}

