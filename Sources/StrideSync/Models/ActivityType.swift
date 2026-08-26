import Foundation

/// Types of sports and physical activities supported by StrideSync.
public enum ActivityType: String, Codable, CaseIterable, Sendable, Identifiable {
    case run = "Run"
    case ride = "Ride"
    case walk = "Walk"
    case hike = "Hike"
    case trailRun = "Trail Run"
    case indoorRun = "Indoor Run"
    
    public var id: String { rawValue }
    
    /// SF Symbol icon name for the activity.
    public var iconName: String {
        switch self {
        case .run:
            return "figure.run"
        case .ride:
            return "figure.outdoor.cycle"
        case .walk:
            return "figure.walk"
        case .hike:
            return "figure.hiking"
        case .trailRun:
            return "figure.run.circle.fill"
        case .indoorRun:
            return "figure.run.treadmill"
        }
    }
    
    /// Default unit preference: pace (min/km) for running/walking, speed (km/h) for cycling.
    public var prefersPaceFormat: Bool {
        switch self {
        case .run, .walk, .hike, .trailRun, .indoorRun:
            return true
        case .ride:
            return false
        }
    }
}

/// Privacy visibility level for activities and user profiles.
public enum VisibilityType: String, Codable, CaseIterable, Sendable, Identifiable {
    case publicVisibility = "Public"
    case followersOnly = "Followers Only"
    case privateVisibility = "Only You"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .publicVisibility:
            return "globe"
        case .followersOnly:
            return "person.2.fill"
        case .privateVisibility:
            return "lock.fill"
        }
    }
}

/// Lifecycle states of a live workout session.
public enum TrackingState: String, Codable, Sendable {
    case idle
    case recording
    case paused
    case autoPaused
    case finished
}

