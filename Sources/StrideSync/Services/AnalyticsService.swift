import Foundation

public enum AnalyticsEvent: Sendable {
    case workoutStarted(activityType: ActivityType)
    case workoutPaused
    case workoutResumed
    case workoutFinished(distanceKm: Double, durationSec: Double)
    case kudosToggled(activityID: UUID, isKudosGiven: Bool)
    case gpxExported(recordID: UUID)
    case fitExported(recordID: UUID)
    case searchExecuted(query: String)
    case custom(name: String, params: [String: String])
    
    public var name: String {
        switch self {
        case .workoutStarted: return "workout_started"
        case .workoutPaused: return "workout_paused"
        case .workoutResumed: return "workout_resumed"
        case .workoutFinished: return "workout_finished"
        case .kudosToggled: return "kudos_toggled"
        case .gpxExported: return "gpx_exported"
        case .fitExported: return "fit_exported"
        case .searchExecuted: return "search_executed"
        case .custom(let name, _): return name
        }
    }
}

/// Centralized analytics service supporting telemetry event logging and screen view tracking.
public final class AnalyticsService: @unchecked Sendable {
    public static let shared = AnalyticsService()
    
    private let lock = NSLock()
    private var loggedEventsCount: Int = 0
    public var isEnabled: Bool = true
    
    public init() {}
    
    public func logEvent(_ event: AnalyticsEvent) {
        guard isEnabled else { return }
        lock.withLock {
            loggedEventsCount += 1
        }
        #if DEBUG
        print("[Analytics] Event logged: \(event.name)")
        #endif
    }
    
    public func logScreenView(screenName: String) {
        guard isEnabled else { return }
        #if DEBUG
        print("[Analytics] Screen viewed: \(screenName)")
        #endif
    }
    
    public var totalEventsLogged: Int {
        lock.withLock { loggedEventsCount }
    }
}
