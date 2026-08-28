import Testing
import CoreLocation
@testable import StrideSync

@Suite("Safety Beacon and Fall Detection Tests")
struct SafetyBeaconAndFallTests {
    
    @Test("Test Live Safety Beacon Session Creation and URL Generation")
    @MainActor
    func testLiveBeaconSession() {
        let service = LiveSafetyBeaconService()
        let session = service.startBeacon(athleteName: "Alex Rivera", activityType: .run)
        
        #expect(service.isBeaconActive == true)
        #expect(!session.beaconCode.isEmpty)
        #expect(session.shareableURLString.contains("https://beacon.stridesync.app/live/"))
        
        service.updateTelemetry(
            coordinate: CLLocationCoordinate2D(latitude: -6.175, longitude: 106.827),
            distanceMeters: 3500.0,
            heartRateBpm: 162
        )
        
        #expect(service.currentSession?.totalDistanceMeters == 3500.0)
        #expect(service.currentSession?.currentHeartRateBpm == 162)
        
        service.stopBeacon()
        #expect(service.isBeaconActive == false)
    }
    
    @Test("Test Fall Detection G-Force Spike and Countdown Trigger")
    @MainActor
    func testFallDetectionTrigger() {
        let engine = FallDetectionEngine()
        engine.startMonitoring()
        #expect(engine.isMonitoring == true)
        
        let testCoord = CLLocationCoordinate2D(latitude: -6.175, longitude: 106.827)
        
        // Low acceleration (< 3.5g) -> No trigger
        engine.evaluateAcceleration(x: 5.0, y: 5.0, z: 9.8, currentCoordinate: testCoord)
        #expect(engine.isCountdownActive == false)
        
        // High spike (e.g. 40 m/s² ≈ 4.07g) -> Trigger countdown
        engine.evaluateAcceleration(x: 25.0, y: 25.0, z: 25.0, currentCoordinate: testCoord)
        #expect(engine.isCountdownActive == true)
        #expect(engine.countdownSecondsRemaining == 30)
        #expect(engine.detectedIncident != nil)
        
        // User dismisses incident -> Cancelled
        engine.dismissIncident()
        #expect(engine.isCountdownActive == false)
        #expect(engine.detectedIncident?.isResolvedByUser == true)
    }
}
