import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// Manager facilitating bidirectional communication and workout telemetry sync between iPhone and Apple Watch.
@MainActor
@Observable
public final class WatchSessionManager: NSObject {
    public static let shared = WatchSessionManager()
    
    public var isWatchPaired: Bool = true
    public var isWatchAppInstalled: Bool = true
    public var isReachable: Bool = true
    public var lastSyncTimestamp: Date? = nil
    
    public override init() {
        super.init()
        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        #endif
    }
    
    public func sendWorkoutToWatch(activity: ActivityRecord) {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.activationState == .activated {
            let payload: [String: Any] = [
                "title": activity.title,
                "distance": activity.distanceMeters,
                "duration": activity.durationSeconds,
                "pace": activity.formattedAveragePace
            ]
            session.transferUserInfo(payload)
            self.lastSyncTimestamp = Date()
        }
        #endif
    }
}

#if canImport(WatchConnectivity)
extension WatchSessionManager: WCSessionDelegate {
    public nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation state
    }
    
    #if os(iOS)
    public nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    public nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
    public nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        // Receive workout telemetry from Apple Watch
    }
}
#endif
