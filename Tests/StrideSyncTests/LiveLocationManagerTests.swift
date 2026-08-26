import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("LiveLocationManager & SocialModel Tests")
struct LiveLocationManagerTests {
    
    @Test("Test LiveLocationManager Initialization and Update Callback")
    @MainActor
    func testLocationManagerInitialization() throws {
        let manager = LiveLocationManager()
        #expect(manager.isLocationServicesEnabled == true)
        
        var receivedLocation: CLLocation?
        manager.onLocationUpdate = { location in
            receivedLocation = location
        }
        
        let testLoc = CLLocation(latitude: -6.175392, longitude: 106.827153)
        manager.onLocationUpdate?(testLoc)
        
        #expect(receivedLocation?.coordinate.latitude == -6.175392)
    }
    
    @Test("Test Gear Life Remaining Calculation")
    func testGearItemCalculation() throws {
        let runningShoe = GearItem(
            name: "Alphafly 3",
            brand: "Nike",
            maxLifeDistanceMeters: 500_000, // 500 km
            currentDistanceMeters: 250_000, // 250 km
            activityType: .run
        )
        
        #expect(runningShoe.lifeRemainingPercentage == 50.0)
    }
    
    @Test("Test Challenge Progress Fraction and Completion")
    func testChallengeModel() throws {
        let challenge = Challenge(
            title: "March 100K",
            subtitle: "Run 100km",
            targetDistanceMeters: 100_000.0,
            currentProgressMeters: 100_000.0,
            activityType: .run,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400)
        )
        
        #expect(challenge.progressFraction == 1.0)
        #expect(challenge.isCompleted == true)
    }
}

