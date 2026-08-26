import Foundation
import SwiftUI
import SwiftData

/// Observable ViewModel managing social community feeds, Kudos reactions, and comments.
@Observable
@MainActor
public final class FeedViewModel {
    public var activities: [ActivityRecord] = []
    public var commentsByActivityId: [UUID: [CommentRecord]] = [:]
    public var selectedFilter: ActivityType? = nil
    public var isLoading: Bool = false
    
    public init(activities: [ActivityRecord] = []) {
        self.activities = activities
        if activities.isEmpty {
            loadMockFeed()
        }
    }
    
    public var filteredActivities: [ActivityRecord] {
        guard let filter = selectedFilter else { return activities }
        return activities.filter { $0.activityType == filter }
    }
    
    public func refresh(from modelContext: ModelContext?) {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<ActivityRecord>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        if let persisted = try? context.fetch(descriptor), !persisted.isEmpty {
            // Keep any community mock activities that don't collide
            var merged = persisted
            for act in activities where !persisted.contains(where: { $0.id == act.id }) {
                merged.append(act)
            }
            self.activities = merged
        }
    }
    
    public func toggleKudos(for activity: ActivityRecord) {
        if activity.isLikedByCurrentUser {
            activity.isLikedByCurrentUser = false
            activity.kudosCount = max(0, activity.kudosCount - 1)
        } else {
            activity.isLikedByCurrentUser = true
            activity.kudosCount += 1
            HapticFeedbackService.shared.playImpact(.light)
        }
    }
    
    public func addComment(to activity: ActivityRecord, athleteName: String, message: String) {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let comment = CommentRecord(
            activityId: activity.id,
            athleteId: UUID(),
            athleteName: athleteName,
            message: message
        )
        if commentsByActivityId[activity.id] != nil {
            commentsByActivityId[activity.id]?.append(comment)
        } else {
            commentsByActivityId[activity.id] = [comment]
        }
        activity.commentsCount += 1
        HapticFeedbackService.shared.playNotification(.success)
    }
    
    public func loadMockFeed() {
        let sample1 = ActivityRecord(
            title: "Morning 10K Tempo Run 🏃‍♂️🔥",
            activityType: .run,
            startTime: Date().addingTimeInterval(-7200),
            endTime: Date().addingTimeInterval(-4500),
            distanceMeters: 10_250.0,
            durationSeconds: 2700,
            movingTimeSeconds: 2650,
            totalElevationGainMeters: 85.0,
            averageSpeedMps: 3.86, // ~4:19 /km
            maxSpeedMps: 4.8,
            averageHeartRate: 162,
            maxHeartRate: 178,
            caloriesBurned: 680,
            notes: "Felt strong throughout! Perfect chilly morning air.",
            visibility: .publicVisibility,
            gearName: "Nike Vaporfly 3"
        )
        sample1.kudosCount = 24
        sample1.commentsCount = 3
        
        let sample2 = ActivityRecord(
            title: "Weekend Hill Climb Cycling 🚴‍♀️⛰️",
            activityType: .ride,
            startTime: Date().addingTimeInterval(-86400),
            endTime: Date().addingTimeInterval(-75600),
            distanceMeters: 45_300.0,
            durationSeconds: 7200,
            movingTimeSeconds: 6800,
            totalElevationGainMeters: 620.0,
            averageSpeedMps: 6.66, // ~24 km/h
            maxSpeedMps: 14.5,
            averageHeartRate: 148,
            maxHeartRate: 172,
            caloriesBurned: 1150,
            notes: "Steep climbs on the south loop, rewarding descent!",
            visibility: .publicVisibility,
            gearName: "Specialized Tarmac SL7"
        )
        sample2.kudosCount = 42
        sample2.commentsCount = 5
        
        self.activities = [sample1, sample2]
        
        self.commentsByActivityId[sample1.id] = [
            CommentRecord(activityId: sample1.id, athleteId: UUID(), athleteName: "Sarah Jenkins", message: "Incredible pace! 🚀"),
            CommentRecord(activityId: sample1.id, athleteId: UUID(), athleteName: "Alex Rivera", message: "Crushing that tempo run!")
        ]
    }
}

