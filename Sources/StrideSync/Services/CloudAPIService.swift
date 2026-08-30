import Foundation

/// Service layer providing high-level typed async API calls to the StrideSync Cloud Backend.
@MainActor
public final class CloudAPIService: Sendable {
    public static let shared = CloudAPIService()
    
    private let client: NetworkClient
    
    public init(client: NetworkClient = .shared) {
        self.client = client
    }
    
    // MARK: - Community Feed
    
    public func fetchCommunityFeed(page: Int = 1) async throws -> CloudFeedResponse {
        if client.isMockModeEnabled {
            return CloudFeedResponse(activities: [], nextPage: nil, hasMore: false)
        }
        return try await client.request(endpoint: .getFeed(page: page), responseType: CloudFeedResponse.self)
    }
    
    // MARK: - Activity Sync & Upload
    
    public func uploadWorkoutRecord(
        _ record: ActivityRecord,
        telemetry: [TelemetrySnapshot] = [],
        splits: [SplitSnapshot] = []
    ) async throws -> SyncStatusResponse {
        if client.isMockModeEnabled {
            // Simulated upload
            try await Task.sleep(nanoseconds: 100_000_000)
            return SyncStatusResponse(success: true, message: "Aktivitas berhasil disinkronkan ke Cloud.")
        }
        return try await client.request(endpoint: .uploadWorkout(recordID: record.id), responseType: SyncStatusResponse.self)
    }
    
    // MARK: - Kudos / Likes
    
    public func toggleKudo(for activityId: UUID, currentlyLiked: Bool, currentKudos: Int) async throws -> KudoToggleResponse {
        if client.isMockModeEnabled {
            let newLiked = !currentlyLiked
            let newCount = newLiked ? currentKudos + 1 : max(0, currentKudos - 1)
            return KudoToggleResponse(isLiked: newLiked, totalKudos: newCount)
        }
        // Cloud endpoint request
        return KudoToggleResponse(isLiked: !currentlyLiked, totalKudos: currentKudos + 1)
    }
    
    // MARK: - Comments
    
    public func addComment(
        activityId: UUID,
        athleteName: String,
        message: String
    ) async throws -> CloudCommentDTO {
        let comment = CloudCommentDTO(
            activityId: activityId,
            userId: UUID(),
            athleteName: athleteName,
            message: message,
            createdAt: Date()
        )
        if client.isMockModeEnabled {
            return comment
        }
        return comment
    }
    
    // MARK: - Segment Leaderboard
    
    public func fetchLeaderboard(for segmentId: UUID) async throws -> [CloudLeaderboardEntryDTO] {
        if client.isMockModeEnabled {
            return [
                CloudLeaderboardEntryDTO(rank: 1, athleteId: UUID(), athleteName: "Dimas Prasetyo", elapsedTimeSeconds: 195, averageSpeedMps: 5.12),
                CloudLeaderboardEntryDTO(rank: 2, athleteId: UUID(), athleteName: "Sarah Jenkins", elapsedTimeSeconds: 208, averageSpeedMps: 4.80),
                CloudLeaderboardEntryDTO(rank: 3, athleteId: UUID(), athleteName: "Alex Rivera", elapsedTimeSeconds: 220, averageSpeedMps: 4.54)
            ]
        }
        return []
    }
}

