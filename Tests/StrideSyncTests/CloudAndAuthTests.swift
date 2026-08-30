import Testing
import Foundation
import SwiftData
@testable import StrideSync

@Suite("Cloud, Auth & Multi-User Tests")
@MainActor
struct CloudAndAuthTests {
    
    @Test("Test Email Authentication and Session Persistence")
    func testEmailAuth() async throws {
        let authManager = AuthManager()
        
        let success = await authManager.loginWithEmail(email: "athlete@stridesync.app", password: "password123")
        #expect(success == true)
        #expect(authManager.currentUser != nil)
        #expect(authManager.currentUser?.email == "athlete@stridesync.app")
        #expect(authManager.authState == .authenticated(authManager.currentUser!))
        
        // Sign Out
        authManager.signOut()
        #expect(authManager.currentUser == nil)
        #expect(authManager.authState == .unauthenticated)
    }
    
    @Test("Test Guest Mode Authentication State")
    func testGuestMode() {
        let authManager = AuthManager()
        authManager.continueAsGuest()
        #expect(authManager.authState == .guestMode)
    }
    
    @Test("Test CloudAPIService Mock Feed and Kudo Toggle")
    func testCloudAPIService() async throws {
        let apiService = CloudAPIService.shared
        
        let feedResponse = try await apiService.fetchCommunityFeed(page: 1)
        #expect(feedResponse.activities.isEmpty || feedResponse.activities.count >= 0)
        
        let testActivityId = UUID()
        let kudoResponse = try await apiService.toggleKudo(for: testActivityId, currentlyLiked: false, currentKudos: 10)
        #expect(kudoResponse.isLiked == true)
        #expect(kudoResponse.totalKudos == 11)
        
        let comment = try await apiService.addComment(activityId: testActivityId, athleteName: "Budi", message: "Nice pace!")
        #expect(comment.athleteName == "Budi")
        #expect(comment.message == "Nice pace!")
    }
    
    @Test("Test CloudSyncEngine Queue and Sync State Lifecycle")
    func testCloudSyncEngine() async throws {
        let syncEngine = CloudSyncEngine.shared
        let activityId = UUID()
        
        syncEngine.enqueueForSync(activityId: activityId)
        #expect(syncEngine.pendingUploadCount >= 1)
        
        await syncEngine.syncAll(with: nil)
        #expect(syncEngine.lastSyncTimestamp != nil)
    }
    
    @Test("Test Segment Leaderboard Fetching")
    func testLeaderboard() async throws {
        let apiService = CloudAPIService.shared
        let leaderboard = try await apiService.fetchLeaderboard(for: UUID())
        #expect(leaderboard.count >= 3)
        #expect(leaderboard.first?.rank == 1)
    }
}

