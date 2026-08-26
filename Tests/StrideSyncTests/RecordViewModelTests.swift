import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("RecordViewModel Tests")
@MainActor
struct RecordViewModelTests {
    
    @Test("Test Starting Workout Initializes Engine and State")
    func testStartWorkout() async throws {
        let vm = RecordViewModel(activityType: .run)
        #expect(vm.trackingState == .idle)
        #expect(vm.distanceMeters == 0)
        
        vm.startWorkout()
        #expect(vm.trackingState == .recording)
        
        vm.pauseWorkout()
        #expect(vm.trackingState == .paused)
        
        vm.resumeWorkout()
        #expect(vm.trackingState == .recording)
        
        vm.discardWorkout()
        #expect(vm.trackingState == .idle)
    }
    
    @Test("Test GPS Coordinate Ingestion and Live Metrics")
    func testCoordinateIngestion() async throws {
        let vm = RecordViewModel(activityType: .run)
        vm.startWorkout()
        
        let loc1 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153),
            altitude: 15.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0,
            speed: 4.0,
            timestamp: Date()
        )
        
        await vm.ingestLocationAsync(loc1)
        
        let loc2 = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: -6.174000, longitude: 106.827153),
            altitude: 18.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 0,
            speed: 4.2,
            timestamp: Date().addingTimeInterval(30)
        )
        
        await vm.ingestLocationAsync(loc2)
        
        // Update heart rate
        vm.updateHeartRate(155)
        #expect(vm.currentHeartRate == 155)
        
        let result = await vm.finishWorkout()
        #expect(result != nil)
        
        if let (record, points, _, _) = result {
            #expect(record.activityType == .run)
            #expect(points.count >= 2)
            #expect(vm.trackingState == .finished)
        }
    }
}
