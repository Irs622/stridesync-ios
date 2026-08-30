import Testing
import Foundation
import SwiftData
@testable import StrideSync

@Suite("Feed & Social Tests")
@MainActor
struct FeedAndSocialTests {
    
    @Test("Test Toggle Kudos Increments and Decrements Count")
    func testToggleKudos() throws {
        let sampleActivity = ActivityRecord(
            title: "Test Morning Run",
            activityType: .run,
            distanceMeters: 5000.0,
            durationSeconds: 1500,
            averageSpeedMps: 3.33
        )
        sampleActivity.kudosCount = 5
        sampleActivity.isLikedByCurrentUser = false
        
        let feedVM = FeedViewModel(activities: [sampleActivity])
        guard let firstActivity = feedVM.activities.first else {
            Issue.record("Feed should have test activity")
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
        let sampleActivity = ActivityRecord(
            title: "Test Evening Ride",
            activityType: .ride,
            distanceMeters: 20000.0,
            durationSeconds: 3600,
            averageSpeedMps: 5.55
        )
        sampleActivity.commentsCount = 0
        
        let feedVM = FeedViewModel(activities: [sampleActivity])
        guard let firstActivity = feedVM.activities.first else {
            Issue.record("Feed should have test activity")
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
        let runAct = ActivityRecord(title: "Run", activityType: .run, distanceMeters: 5000)
        let rideAct = ActivityRecord(title: "Ride", activityType: .ride, distanceMeters: 15000)
        let feedVM = FeedViewModel(activities: [runAct, rideAct])
        
        feedVM.selectedFilter = .run
        #expect(feedVM.filteredActivities.allSatisfy { $0.activityType == .run })
        #expect(feedVM.filteredActivities.count == 1)
        
        feedVM.selectedFilter = .ride
        #expect(feedVM.filteredActivities.allSatisfy { $0.activityType == .ride })
        #expect(feedVM.filteredActivities.count == 1)
        
        feedVM.selectedFilter = nil
        #expect(feedVM.filteredActivities.count == 2)
    }
}
