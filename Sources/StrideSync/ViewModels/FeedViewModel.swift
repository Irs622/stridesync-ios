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
    }
    
    public var filteredActivities: [ActivityRecord] {
        guard let filter = selectedFilter else { return activities }
        return activities.filter { $0.activityType == filter }
    }
    
    public func refresh(from modelContext: ModelContext?) {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<ActivityRecord>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        if let persisted = try? context.fetch(descriptor) {
            self.activities = persisted
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
}
