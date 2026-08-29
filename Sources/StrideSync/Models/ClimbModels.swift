import Foundation
import CoreLocation

/// Official UCI / Strava climb classification categories based on difficulty score (Distance * Grade^2).
public enum ClimbCategory: String, Codable, Sendable, CaseIterable {
    case hc = "Hors Catégorie (HC)"
    case cat1 = "Kategori 1"
    case cat2 = "Kategori 2"
    case cat3 = "Kategori 3"
    case cat4 = "Kategori 4"
    case uncategorized = "Tanjakan Ringan"
    
    public var shortLabel: String {
        switch self {
        case .hc: return "HC"
        case .cat1: return "Cat 1"
        case .cat2: return "Cat 2"
        case .cat3: return "Cat 3"
        case .cat4: return "Cat 4"
        case .uncategorized: return "Hill"
        }
    }
    
    public var badgeColorHex: String {
        switch self {
        case .hc: return "#D32F2F" // Intense Red
        case .cat1: return "#F57C00" // Dark Orange
        case .cat2: return "#FFA000" // Amber
        case .cat3: return "#FBC02D" // Yellow
        case .cat4: return "#388E3C" // Green
        case .uncategorized: return "#757575" // Gray
        }
    }
}

/// Model representing an identified uphill climb segment along an activity route.
public struct ClimbSegment: Identifiable, Sendable {
    public var id: UUID
    public var startIndex: Int
    public var endIndex: Int
    public var distanceMeters: Double
    public var elevationGainMeters: Double
    public var averageGradePercent: Double
    public var maxGradePercent: Double
    public var category: ClimbCategory
    public var score: Double
    public var startCoordinate: CLLocationCoordinate2D
    public var endCoordinate: CLLocationCoordinate2D
    
    public init(
        id: UUID = UUID(),
        startIndex: Int,
        endIndex: Int,
        distanceMeters: Double,
        elevationGainMeters: Double,
        averageGradePercent: Double,
        maxGradePercent: Double,
        category: ClimbCategory,
        score: Double,
        startCoordinate: CLLocationCoordinate2D,
        endCoordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.distanceMeters = distanceMeters
        self.elevationGainMeters = elevationGainMeters
        self.averageGradePercent = averageGradePercent
        self.maxGradePercent = maxGradePercent
        self.category = category
        self.score = score
        self.startCoordinate = startCoordinate
        self.endCoordinate = endCoordinate
    }
    
    public var formattedDistance: String {
        if distanceMeters >= 1000 {
            return String(format: "%.2f km", distanceMeters / 1000.0)
        } else {
            return String(format: "%.0f m", distanceMeters)
        }
    }
    
    public var formattedElevationGain: String {
        String(format: "+%.0f m", elevationGainMeters)
    }
    
    public var formattedAverageGrade: String {
        String(format: "%.1f%% avg", averageGradePercent)
    }
    
    public var formattedMaxGrade: String {
        String(format: "%.1f%% max", maxGradePercent)
    }
}

