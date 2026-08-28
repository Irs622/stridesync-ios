import Testing
import Foundation
@testable import StrideSync

@Suite("Analytics & Background Sync Tests")
struct AnalyticsAndBackgroundSyncTests {
    
    @Test("Test AnalyticsService Event Logging")
    func testAnalyticsEventLogging() throws {
        let analytics = AnalyticsService.shared
        let initialCount = analytics.totalEventsLogged
        
        analytics.logEvent(.workoutStarted(activityType: .run))
        analytics.logEvent(.gpxExported(recordID: UUID()))
        analytics.logScreenView(screenName: "RecordHUDView")
        
        #expect(analytics.totalEventsLogged == initialCount + 2)
    }
    
    @Test("Test BackgroundSyncManager Queue Management")
    func testBackgroundSyncQueue() async throws {
        let syncManager = BackgroundSyncManager.shared
        let testID = UUID()
        
        syncManager.enqueueForUpload(recordID: testID)
        #expect(syncManager.pendingQueueCount >= 1)
        
        let processed = await syncManager.processPendingUploads()
        #expect(processed >= 0)
    }
}
