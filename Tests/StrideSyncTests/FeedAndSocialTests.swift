import Testing
import Foundation
import SwiftData
@testable import StrideSync

@Suite("Feed & Social Tests")
@MainActor
struct FeedAndSocialTests {
    
    @Test("Test Toggle Kudos Increments and Decrements Count")
    func testToggleKudos() throws {
        let feedVM = FeedViewModel()
        guard let firstActivity = feedVM.activities.first else {
            Issue.record("Feed should have sample activities")
            return
        }
        
        let initialKudos = firstActivity.kudosCount
        let initialLiked = firstActivity.isLikedByCurrentUser
        
        feedVM.toggleKudos(for: firstActivity)
        #expect(firstActivity.isLikedByCurrentUser == !initialLiked)
        #expect(firstActivity.kudosCount == (initialLiked ? initialKudos - 1 : initialKudos + 1))
        
        // Toggle back
        feedVM.toggleKudos(for: firstActivity)
        #expect(firstActivity.isLikedByCurrentUser == initialLiked)
        #expect(firstActivity.kudosCount == initialKudos)
    }
    
    @Test("Test Adding Comment to Activity")
    func testAddComment() throws {
        let feedVM = FeedViewModel()
        guard let firstActivity = feedVM.activities.first else {
            Issue.record("Feed should have sample activities")
            return
        }
        
        let initialCount = firstActivity.commentsCount
        feedVM.addComment(to: firstActivity, athleteName: "Coach Dave", message: "Great pacing!")
        
        #expect(firstActivity.commentsCount == initialCount + 1)
        let comments = feedVM.commentsByActivityId[firstActivity.id] ?? []
        #expect(comments.contains(where: { $0.athleteName == "Coach Dave" && $0.message == "Great pacing!" }))
    }
    
    @Test("Test Filtering Feed by ActivityType")
    func testFeedFilter() throws {
        let feedVM = FeedViewModel()
        feedVM.selectedFilter = .run
        #expect(feedVM.filteredActivities.allSatisfy { $0.activityType == .run })
        
        feedVM.selectedFilter = .ride
        #expect(feedVM.filteredActivities.allSatisfy { $0.activityType == .ride })
        
        feedVM.selectedFilter = nil
        #expect(feedVM.filteredActivities.count == feedVM.activities.count)
    }
}

