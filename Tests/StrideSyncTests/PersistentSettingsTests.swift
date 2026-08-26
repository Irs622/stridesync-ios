import Testing
import Foundation
@testable import StrideSync

@Suite("Persistent UserSettings Tests")
@MainActor
struct PersistentSettingsTests {
    
    @Test("Test User Settings Persists Changes to UserDefaults")
    func testSettingsPersistence() throws {
        let manager = UserSettingsManager.shared
        
        let testBio = "Testing persistence \(UUID().uuidString)"
        manager.bio = testBio
        
        // Load fresh instance to verify persistence from UserDefaults
        let newManager = UserSettingsManager()
        #expect(newManager.bio == testBio)
        
        // Add Privacy Zone
        let initialCount = newManager.privacyZones.count
        newManager.addPrivacyZone(name: "Test Park", latitude: -6.200000, longitude: 106.800000, radiusMeters: 350.0)
        
        let thirdManager = UserSettingsManager()
        #expect(thirdManager.privacyZones.count == initialCount + 1)
        #expect(thirdManager.privacyZones.contains(where: { $0.name == "Test Park" }))
    }
}

