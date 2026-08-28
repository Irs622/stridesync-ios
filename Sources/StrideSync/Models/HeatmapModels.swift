import Foundation
import CoreLocation

/// Web Mercator Slippy Map Tile Coordinate representation.
public struct MapTileCoordinate: Hashable, Sendable, Codable {
    public let x: Int
    public let y: Int
    public let zoom: Int
    
    public init(x: Int, y: Int, zoom: Int) {
        self.x = x
        self.y = y
        self.zoom = zoom
    }
}

/// Exploration badge level based on unique square kilometers explored.
public enum ExplorationBadge: String, Codable, Sendable {
    case scout = "Neighborhood Scout"
    case explorer = "City Explorer"
    case pioneer = "District Pioneer"
    case globetrotter = "World Globetrotter"
    
    public var iconName: String {
        switch self {
        case .scout: return "figure.walk.diamond.fill"
        case .explorer: return "map.fill"
        case .pioneer: return "mountain.2.fill"
        case .globetrotter: return "globe.badge.chevron.backward"
        }
    }
}

/// Statistics summarizing athlete's lifetime spatial exploration and heatmap density.
public struct HeatmapExplorationStats: Sendable, Equatable {
    public let totalUniqueTiles: Int
    public let estimatedExploredSquareKm: Double
    public let totalActivitiesMapped: Int
    public let badge: ExplorationBadge
    
    public init(
        totalUniqueTiles: Int,
        estimatedExploredSquareKm: Double,
        totalActivitiesMapped: Int,
        badge: ExplorationBadge
    ) {
        self.totalUniqueTiles = totalUniqueTiles
        self.estimatedExploredSquareKm = estimatedExploredSquareKm
        self.totalActivitiesMapped = totalActivitiesMapped
        self.badge = badge
    }
    
    public var formattedArea: String {
        String(format: "%.1f km²", estimatedExploredSquareKm)
    }
}

