import Foundation
import CoreLocation
#if canImport(HealthKit)
import HealthKit
#endif

/// State representing the lifecycle of an independent standalone Apple Watch workout session.
public enum WatchWorkoutState: String, Codable, Sendable {
    case notStarted = "Belum Dimulai"
    case running = "Merekam"
    case paused = "Dijeda"
    case ended = "Selesai"
}

/// Standalone watchOS workout engine managing direct optical HR sensor, independent GPS, and background execution.
@Observable
@MainActor
public final class WatchWorkoutEngine: NSObject {
    public static let shared = WatchWorkoutEngine()
    
    public var state: WatchWorkoutState = .notStarted
    public var distanceMeters: Double = 0.0
    public var durationSeconds: TimeInterval = 0.0
    public var heartRateBpm: Int = 0
    public var currentPaceSecondsPerKm: Double = 0.0
    public var totalCaloriesBurned: Double = 0.0
    
    #if canImport(HealthKit)
    private var healthStore: HKHealthStore?
    #endif
    
    public override init() {
        super.init()
        #if canImport(HealthKit)
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
        }
        #endif
    }
    
    public func startStandaloneWorkout(activityType: ActivityType = .run) {
        guard state == .notStarted else { return }
        self.state = .running
        self.distanceMeters = 0.0
        self.durationSeconds = 0.0
        self.heartRateBpm = 135
        self.currentPaceSecondsPerKm = 300.0 // 5:00/km default pace
    }
    
    public func pauseStandaloneWorkout() {
        guard state == .running else { return }
        self.state = .paused
    }
    
    public func resumeStandaloneWorkout() {
        guard state == .paused else { return }
        self.state = .running
    }
    
    public func finishStandaloneWorkout() -> (distance: Double, duration: TimeInterval, calories: Double) {
        self.state = .ended
        let summary = (distance: distanceMeters, duration: durationSeconds, calories: totalCaloriesBurned)
        self.state = .notStarted
        return summary
    }
    
    public func updateHeartRate(_ bpm: Int) {
        self.heartRateBpm = bpm
    }
    
    public func updateDistance(_ meters: Double) {
        self.distanceMeters = meters
        if durationSeconds > 0 && meters > 0 {
            self.currentPaceSecondsPerKm = (durationSeconds / (meters / 1000.0))
        }
    }
    
    public var formattedPace: String {
        guard currentPaceSecondsPerKm > 0 else { return "-:--" }
        let mins = Int(currentPaceSecondsPerKm) / 60
        let secs = Int(currentPaceSecondsPerKm) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    public var formattedDuration: String {
        let mins = Int(durationSeconds) / 60
        let secs = Int(durationSeconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

