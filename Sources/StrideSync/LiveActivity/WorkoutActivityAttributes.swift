import Foundation

#if os(iOS) && canImport(ActivityKit)
import ActivityKit

/// ActivityKit attributes definition for rendering real-time workout stats on iOS Dynamic Island and Lock Screen.
public struct WorkoutActivityAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public var formattedDistance: String
        public var formattedDuration: String
        public var formattedPace: String
        public var heartRate: Int?
        public var isPaused: Bool
        
        public init(
            formattedDistance: String,
            formattedDuration: String,
            formattedPace: String,
            heartRate: Int? = nil,
            isPaused: Bool = false
        ) {
            self.formattedDistance = formattedDistance
            self.formattedDuration = formattedDuration
            self.formattedPace = formattedPace
            self.heartRate = heartRate
            self.isPaused = isPaused
        }
    }
    
    public var workoutTitle: String
    public var activityTypeRaw: String
    public var activityIconName: String
    
    public init(workoutTitle: String, activityType: ActivityType) {
        self.workoutTitle = workoutTitle
        self.activityTypeRaw = activityType.rawValue
        self.activityIconName = activityType.iconName
    }
}
#endif

