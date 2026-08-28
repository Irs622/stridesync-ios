import Foundation
import CoreLocation

/// Spatial tile calculation and aggregation engine powering the athlete's lifetime Personal Global Heatmap.
public struct HeatmapTileEngine: Sendable {
    public let defaultZoom: Int
    
    public init(defaultZoom: Int = 14) {
        self.defaultZoom = defaultZoom
    }
    
    /// Converts a WGS84 coordinate (Latitude/Longitude) into Web Mercator Slippy Map Tile Coordinate at specified zoom level.
    public static func coordinateToTile(
        latitude: Double,
        longitude: Double,
        zoom: Int = 14
    ) -> MapTileCoordinate {
        let n = pow(2.0, Double(zoom))
        let latRad = latitude * .pi / 180.0
        
        let x = Int(floor((longitude + 180.0) / 360.0 * n))
        let y = Int(floor((1.0 - asinh(tan(latRad)) / .pi) / 2.0 * n))
        
        return MapTileCoordinate(x: x, y: y, zoom: zoom)
    }
    
    /// Ingests an array of route polylines and returns the unique set of explored map tiles.
    public func aggregateTiles(from routePolylines: [[CLLocationCoordinate2D]]) -> Set<MapTileCoordinate> {
        var visitedTiles = Set<MapTileCoordinate>()
        for polyline in routePolylines {
            for coord in polyline {
                let tile = Self.coordinateToTile(latitude: coord.latitude, longitude: coord.longitude, zoom: defaultZoom)
                visitedTiles.insert(tile)
            }
        }
        return visitedTiles
    }
    
    /// Calculates exploration statistics and badges based on unique visited tiles.
    public func calculateExplorationStats(
        uniqueTilesCount: Int,
        totalActivities: Int
    ) -> HeatmapExplorationStats {
        // At zoom 14 at equator, 1 tile is approximately ~2.4 sq km (1.55 km x 1.55 km)
        let areaPerTileKm2 = 2.40
        let totalArea = Double(uniqueTilesCount) * areaPerTileKm2
        
        let badge: ExplorationBadge
        if totalArea > 150.0 {
            badge = .globetrotter
        } else if totalArea > 50.0 {
            badge = .pioneer
        } else if totalArea > 15.0 {
            badge = .explorer
        } else {
            badge = .scout
        }
        
        return HeatmapExplorationStats(
            totalUniqueTiles: uniqueTilesCount,
            estimatedExploredSquareKm: totalArea,
            totalActivitiesMapped: totalActivities,
            badge: badge
        )
    }
}

