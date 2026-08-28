import Foundation
#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

/// Manager responsible for scheduling and executing offline workout uploads and background data refreshes.
public final class BackgroundSyncManager: @unchecked Sendable {
    public static let shared = BackgroundSyncManager()
    public static let backgroundSyncTaskIdentifier = "com.stridesync.app.backgroundSync"
    
    private let lock = NSLock()
    private var pendingUploadQueue: [UUID] = []
    
    public init() {}
    
    /// Enqueues a completed workout record ID for background upload.
    public func enqueueForUpload(recordID: UUID) {
        lock.withLock {
            if !pendingUploadQueue.contains(recordID) {
                pendingUploadQueue.append(recordID)
            }
        }
        scheduleBackgroundSync()
    }
    
    /// Schedules a background refresh task with BackgroundTasks framework.
    public func scheduleBackgroundSync() {
        #if os(iOS) && canImport(BackgroundTasks)
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundSyncTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Task scheduling error fallback
        }
        #endif
    }
    
    /// Processes all pending uploads in queue asynchronously.
    public func processPendingUploads() async -> Int {
        var itemsToProcess: [UUID] = []
        lock.withLock {
            itemsToProcess = pendingUploadQueue
        }
        
        var successCount = 0
        for id in itemsToProcess {
            do {
                _ = try await NetworkClient.shared.request(
                    endpoint: .uploadWorkout(recordID: id),
                    responseType: SyncStatusResponse.self
                )
                lock.withLock {
                    pendingUploadQueue.removeAll { $0 == id }
                }
                successCount += 1
            } catch {
                // Keep in queue for next sync attempt
            }
        }
        
        return successCount
    }
    
    public var pendingQueueCount: Int {
        lock.withLock { pendingUploadQueue.count }
    }
}
