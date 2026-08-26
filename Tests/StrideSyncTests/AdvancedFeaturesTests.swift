import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("Advanced Features Tests")
struct AdvancedFeaturesTests {
    
    @Test("Test Heart Rate Zone 1 to 5 Distribution Calculation")
    func testHeartRateZoneDistribution() throws {
        let calculator = HeartRateZoneCalculator(maxHeartRate: 200)
        let now = Date()
        
        let samplePoints: [TelemetrySnapshot] = [
            TelemetrySnapshot(timestamp: now, latitude: 0, longitude: 0, altitude: 10, speedMps: 3, horizontalAccuracy: 5, heartRate: 110), // Z1
            TelemetrySnapshot(timestamp: now.addingTimeInterval(60), latitude: 0, longitude: 0, altitude: 10, speedMps: 3, horizontalAccuracy: 5, heartRate: 130), // Z2
            TelemetrySnapshot(timestamp: now.addingTimeInterval(120), latitude: 0, longitude: 0, altitude: 10, speedMps: 3, horizontalAccuracy: 5, heartRate: 150), // Z3
            TelemetrySnapshot(timestamp: now.addingTimeInterval(180), latitude: 0, longitude: 0, altitude: 10, speedMps: 3, horizontalAccuracy: 5, heartRate: 170), // Z4
            TelemetrySnapshot(timestamp: now.addingTimeInterval(240), latitude: 0, longitude: 0, altitude: 10, speedMps: 3, horizontalAccuracy: 5, heartRate: 195)  // Z5
        ]
        
        let zones = calculator.calculateZones(from: samplePoints)
        #expect(zones.count == 5)
        #expect(zones[0].rangeBpm.lowerBound == 100)
        #expect(zones[4].rangeBpm.upperBound == 200)
    }
    
    @Test("Test Watch Session Manager Initialization and Availability")
    @MainActor
    func testWatchSessionManager() throws {
        let manager = WatchSessionManager.shared
        #expect(manager.isWatchPaired == true)
        #expect(manager.isWatchAppInstalled == true)
    }
}
