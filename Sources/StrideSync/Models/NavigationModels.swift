import Foundation
import CoreLocation

/// Type of directional maneuver for turn-by-turn navigation guidance.
public enum NavigationManeuver: String, Codable, Sendable {
    case start = "Mulai Rute"
    case keepStraight = "Lurus Terus"
    case turnLeft = "Belok Kiri"
    case turnRight = "Belok Kanan"
    case slightLeft = "Serong Kiri"
    case slightRight = "Serong Kanan"
    case sharpLeft = "Belok Tajam Kiri"
    case sharpRight = "Belok Tajam Kanan"
    case uTurn = "Putar Balik"
    case offCourse = "Keluar Jalur"
    case arrive = "Tiba di Tujuan"
    
    public var iconName: String {
        switch self {
        case .start: return "play.circle.fill"
        case .keepStraight: return "arrow.up"
        case .turnLeft: return "arrow.turn.up.left"
        case .turnRight: return "arrow.turn.up.right"
        case .slightLeft: return "arrow.up.left"
        case .slightRight: return "arrow.up.right"
        case .sharpLeft: return "arrow.uturn.backward"
        case .sharpRight: return "arrow.uturn.forward"
        case .uTurn: return "arrow.uturn.down"
        case .offCourse: return "exclamationmark.triangle.fill"
        case .arrive: return "flag.checkered.circle.fill"
        }
    }
}

/// A specific turn-by-turn waypoint step in a navigation course.
public struct NavigationStep: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let coordinate: CLLocationCoordinate2D
    public let maneuver: NavigationManeuver
    public let distanceAlongRouteMeters: Double
    public let instruction: String
    
    public init(
        id: UUID = UUID(),
        coordinate: CLLocationCoordinate2D,
        maneuver: NavigationManeuver,
        distanceAlongRouteMeters: Double,
        instruction: String
    ) {
        self.id = id
        self.coordinate = coordinate
        self.maneuver = maneuver
        self.distanceAlongRouteMeters = distanceAlongRouteMeters
        self.instruction = instruction
    }
    
    public static func == (lhs: NavigationStep, rhs: NavigationStep) -> Bool {
        lhs.id == rhs.id
    }
}

/// Live real-time guidance feedback for the navigation HUD.
public struct NavigationGuidance: Sendable, Equatable {
    public let currentManeuver: NavigationManeuver
    public let instruction: String
    public let distanceToManeuverMeters: Double
    public let remainingRouteDistanceMeters: Double
    public let isOffCourse: Bool
    public let crossTrackDistanceMeters: Double
    
    public init(
        currentManeuver: NavigationManeuver,
        instruction: String,
        distanceToManeuverMeters: Double,
        remainingRouteDistanceMeters: Double,
        isOffCourse: Bool,
        crossTrackDistanceMeters: Double
    ) {
        self.currentManeuver = currentManeuver
        self.instruction = instruction
        self.distanceToManeuverMeters = distanceToManeuverMeters
        self.remainingRouteDistanceMeters = remainingRouteDistanceMeters
        self.isOffCourse = isOffCourse
        self.crossTrackDistanceMeters = crossTrackDistanceMeters
    }
    
    public var formattedDistanceToManeuver: String {
        if distanceToManeuverMeters < 1000 {
            return String(format: "%.0f m", distanceToManeuverMeters)
        } else {
            return String(format: "%.1f km", distanceToManeuverMeters / 1000.0)
        }
    }
    
    public var formattedRemainingDistance: String {
        String(format: "%.2f km", remainingRouteDistanceMeters / 1000.0)
    }
}

