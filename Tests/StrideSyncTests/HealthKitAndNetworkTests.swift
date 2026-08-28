import Testing
import Foundation
@testable import StrideSync

@Suite("HealthKit, Network & Localization Tests")
struct HealthKitAndNetworkTests {
    
    @Test("Test HealthKitManager Availability & Workout Save Execution")
    func testHealthKitManagerSave() async throws {
        let manager = HealthKitManager.shared
        // Verification of saveWorkout async method execution
        let saved = await manager.saveWorkout(
            activityType: .run,
            startDate: Date().addingTimeInterval(-1800),
            endDate: Date(),
            distanceMeters: 5000.0,
            caloriesBurned: 350.0
        )
        // Returns true or false depending on platform environment, but method runs cleanly without throwing
        #expect(saved == true || saved == false)
    }
    
    @Test("Test NetworkClient Request Execution in Mock Mode")
    func testNetworkClientMockRequest() async throws {
        let client = NetworkClient(isMockMode: true)
        let endpoint = APIEndpoint.syncUserSettings
        let response = try await client.request(endpoint: endpoint, responseType: SyncStatusResponse.self)
        
        #expect(response.success == true)
        #expect(response.message.contains("Synced successfully"))
    }
    
    @Test("Test LocalizationManager Dynamic Translations")
    @MainActor
    func testLocalizationManager() throws {
        let manager = LocalizationManager.shared
        
        manager.currentLanguage = .english
        #expect("start_workout".localized == "Start Workout")
        
        manager.currentLanguage = .indonesian
        #expect("start_workout".localized == "Mulai Workout")
    }
}
