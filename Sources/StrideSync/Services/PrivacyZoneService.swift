import Foundation
import CoreLocation

/// Represents a geographic zone (e.g. Home, Workplace) where activity tracking points should be hidden from public view.
public struct PrivacyZone: Codable, Sendable, Identifiable {
    public var id: UUID
    public var name: String
    public var latitude: Double
    public var longitude: Double
    public var radiusMeters: Double
    
    public init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 500.0
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Service that sanitizes GPS coordinates to protect user privacy before public sharing.
public struct PrivacyZoneService: Sendable {
    public let zones: [PrivacyZone]
    
    public init(zones: [PrivacyZone] = []) {
        self.zones = zones
    }
    
    /// Filters out any coordinates that fall within the configured privacy zones.
    public func sanitizeCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard !zones.isEmpty else { return coordinates }
        
        return coordinates.filter { coord in
            let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            for zone in zones {
                let zoneLoc = CLLocation(latitude: zone.latitude, longitude: zone.longitude)
                if loc.distance(from: zoneLoc) <= zone.radiusMeters {
                    return false // Within hidden zone
                }
            }
            return true
        }
    }
    
    /// Trims points from start and finish that are inside any privacy zones.
    public func sanitizeTelemetrySnapshots(_ points: [TelemetrySnapshot]) -> [TelemetrySnapshot] {
        guard !zones.isEmpty else { return points }
        
        return points.filter { pt in
            let loc = CLLocation(latitude: pt.latitude, longitude: pt.longitude)
            for zone in zones {
                let zoneLoc = CLLocation(latitude: zone.latitude, longitude: zone.longitude)
                if loc.distance(from: zoneLoc) <= zone.radiusMeters {
                    return false
                }
            }
            return true
        }
    }
}

