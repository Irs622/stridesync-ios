import Testing
import CoreLocation
@testable import StrideSync

@Suite("3D Flyover Replay Engine Tests")
struct FlyoverReplayTests {
    
    @Test("Test 3D Camera Angles and Bearing Calculation")
    func testCameraAngleGeneration() {
        let engine = FlyoverReplayEngine(configuration: FlyoverConfiguration(cameraFollowDistanceMeters: 500.0))
        
        let coords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153),
            CLLocationCoordinate2D(latitude: -6.170000, longitude: 106.827153),
            CLLocationCoordinate2D(latitude: -6.165000, longitude: 106.830000)
        ]
        
        let frames = engine.generateCameraFrames(from: coords)
        #expect(frames.count == 3)
        #expect(frames[0].pitchDegrees == 60.0)
        #expect(frames[0].altitudeMeters == 500.0)
        #expect(frames[0].headingDegrees >= 0.0 && frames[0].headingDegrees <= 360.0)
    }
    
    @Test("Test Milestone Event Generation along Telemetry Path")
    func testMilestoneGeneration() {
        let engine = FlyoverReplayEngine()
        let startTime = Date()
        
        var points: [TelemetrySnapshot] = []
        for i in 0...20 {
            let lat = -6.175392 + (Double(i) * 0.001)
            let snap = TelemetrySnapshot(
                timestamp: startTime.addingTimeInterval(Double(i * 30)),
                latitude: lat,
                longitude: 106.827153,
                altitude: 10.0 + Double(i * 2),
                speedMps: 3.5,
                horizontalAccuracy: 5.0
            )
            points.append(snap)
        }
        
        let milestones = engine.generateMilestones(from: points, totalDistanceMeters: 2200.0)
        #expect(!milestones.isEmpty)
        #expect(milestones.contains(where: { $0.title.contains("Start") }))
        #expect(milestones.contains(where: { $0.title.contains("Finish") }))
        #expect(milestones.contains(where: { $0.title.contains("KM 1") }))
    }
}
