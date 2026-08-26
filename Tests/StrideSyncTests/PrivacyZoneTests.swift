import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("PrivacyZone Tests")
struct PrivacyZoneTests {
    
    @Test("Test Privacy Zone Filter strips points within home radius")
    func testPrivacyZoneSanitization() throws {
        let homeCoord = CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153)
        let homeZone = PrivacyZone(
            name: "Home",
            latitude: homeCoord.latitude,
            longitude: homeCoord.longitude,
            radiusMeters: 500.0
        )
        
        let service = PrivacyZoneService(zones: [homeZone])
        
        let pointInsideHome = CLLocationCoordinate2D(latitude: -6.175400, longitude: 106.827160) // ~10m from home
        let pointOutsideHome = CLLocationCoordinate2D(latitude: -6.190000, longitude: 106.827153) // ~1600m from home
        
        let sanitized = service.sanitizeCoordinates([pointInsideHome, pointOutsideHome])
        
        #expect(sanitized.count == 1)
        #expect(sanitized[0].latitude == pointOutsideHome.latitude)
    }
}

