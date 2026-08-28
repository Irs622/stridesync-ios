import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("Personal Global Heatmap & Spatial Tile Tests")
struct HeatmapTileTests {
    
    @Test("Test WGS84 Lat/Lon conversion to Slippy Map Tile")
    func testCoordinateToTile() {
        // Jakarta Monas (-6.1754, 106.8272) at Zoom 14
        let tile = HeatmapTileEngine.coordinateToTile(latitude: -6.1754, longitude: 106.8272, zoom: 14)
        #expect(tile.zoom == 14)
        #expect(tile.x > 0)
        #expect(tile.y > 0)
    }
    
    @Test("Test aggregation of unique tiles and exploration badges")
    func testHeatmapAggregation() {
        let engine = HeatmapTileEngine(defaultZoom: 14)
        let routes = [
            [
                CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272),
                CLLocationCoordinate2D(latitude: -6.1764, longitude: 106.8282)
            ]
        ]
        
        let uniqueTiles = engine.aggregateTiles(from: routes)
        #expect(!uniqueTiles.isEmpty)
        
        let stats = engine.calculateExplorationStats(uniqueTilesCount: uniqueTiles.count, totalActivities: 1)
        #expect(stats.totalActivitiesMapped == 1)
        #expect(stats.totalUniqueTiles == uniqueTiles.count)
        #expect(stats.estimatedExploredSquareKm > 0.0)
    }
}

