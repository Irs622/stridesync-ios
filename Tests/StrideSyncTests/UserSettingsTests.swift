import Testing
import Foundation
@testable import StrideSync

@Suite("UserSettings Tests")
struct UserSettingsTests {
    
    @Test("Test User Settings Manager Initial Values and Privacy Zone Management")
    @MainActor
    func testUserSettingsManager() throws {
        let settings = UserSettingsManager()
        
        #expect(settings.isMetricUnits == true)
        #expect(settings.autoPauseEnabled == true)
        #expect(settings.isAudioCueEnabled == true)
        
        let initialZoneCount = settings.privacyZones.count
        settings.addPrivacyZone(name: "Gym", latitude: -6.220000, longitude: 106.810000, radiusMeters: 400.0)
        
        #expect(settings.privacyZones.count == initialZoneCount + 1)
        #expect(settings.privacyZones.last?.name == "Gym")
    }
}

