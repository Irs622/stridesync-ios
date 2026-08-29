import Foundation

#if os(iOS) && canImport(ActivityKit)
import ActivityKit

/// Defines the attributes used by ActivityKit to display live workout information on the iOS Dynamic Island and Lock Screen.
/// Contains metadata about the workout and its real-time state for rendering.
public struct WorkoutActivityAttributes: ActivityAttributes, Sendable {
    /// Represents the live state of the workout content shown during the activity.
    public struct ContentState: Codable, Hashable, Sendable {
        /// The formatted distance string (e.g., "5.2 km").
        public var formattedDistance: String
        /// The formatted duration string (e.g., "00:25:30").
        public var formattedDuration: String
        /// The formatted pace string (e.g., "5:00 min/km").
        public var formattedPace: String
        /// The current heart rate, if available.
        public var heartRate: Int?
        /// Indicates whether the workout is currently paused.
        public var isPaused: Bool
        /// The number of calories burned during the workout, if available.
        public var caloriesBurned: Double?
        
        /// Creates a new instance of ContentState with workout real-time values.
        /// - Parameters:
        ///   - formattedDistance: The formatted distance string.
        ///   - formattedDuration: The formatted duration string.
        ///   - formattedPace: The formatted pace string.
        ///   - heartRate: The current heart rate, optional.
        ///   - isPaused: Flag indicating if the workout is paused.
        ///   - caloriesBurned: The calories burned, optional.
        public init(
            formattedDistance: String,
            formattedDuration: String,
            formattedPace: String,
            heartRate: Int? = nil,
            isPaused: Bool = false,
            caloriesBurned: Double? = nil
        ) {
            self.formattedDistance = formattedDistance
            self.formattedDuration = formattedDuration
            self.formattedPace = formattedPace
            self.heartRate = heartRate
            self.isPaused = isPaused
            self.caloriesBurned = caloriesBurned
        }
    }
    
    /// The title or name of the workout.
    public var workoutTitle: String
    /// The raw string value representing the activity type.
    public var activityTypeRaw: String
    /// The name of the icon associated with the activity type.
    public var activityIconName: String
    
    /// The activity type enum derived from the raw string.
    /// This is a placeholder, assuming an `ActivityType` enum exists.
    public var activityType: ActivityType? {
        // Replace with actual ActivityType enum lookup in your project
        // Example: ActivityType(rawValue: activityTypeRaw)
        return ActivityType(rawValue: activityTypeRaw)
    }
    
    /// Creates a new WorkoutActivityAttributes instance from values.
    /// - Parameters:
    ///   - workoutTitle: The title or name of the workout.
    ///   - activityType: The activity type enum.
    public init(workoutTitle: String, activityType: ActivityType) {
        self.workoutTitle = workoutTitle
        self.activityTypeRaw = activityType.rawValue
        self.activityIconName = activityType.iconName
    }
    
    /// Creates a new WorkoutActivityAttributes instance from raw values.
    /// - Parameters:
    ///   - workoutTitle: The title or name of the workout.
    ///   - activityTypeRaw: The raw string for activity type.
    ///   - activityIconName: The icon name associated with the activity.
    public init(workoutTitle: String, activityTypeRaw: String, activityIconName: String) {
        self.workoutTitle = workoutTitle
        self.activityTypeRaw = activityTypeRaw
        self.activityIconName = activityIconName
    }
}
#endif

