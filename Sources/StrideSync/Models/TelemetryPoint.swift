import Foundation
import SwiftData
import CoreLocation

/// Individual GPS and sensor measurement logged along the activity route.
@Model
public final class TelemetryPoint {
    public var timestamp: Date
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double
    public var speedMps: Double
    public var horizontalAccuracy: Double
    public var heartRate: Int?
    public var cadence: Int?
    
    public init(
        timestamp: Date = Date(),
        latitude: Double,
        longitude: Double,
        altitude: Double = 0.0,
        speedMps: Double = 0.0,
        horizontalAccuracy: Double = 0.0,
        heartRate: Int? = nil,
        cadence: Int? = nil
    ) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speedMps = speedMps
        self.horizontalAccuracy = horizontalAccuracy
        self.heartRate = heartRate
        self.cadence = cadence
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Sendable lightweight struct snapshot of a telemetry point for actor computations.
public struct TelemetrySnapshot: Codable, Sendable, Identifiable {
    public var id: UUID
    public var timestamp: Date
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double
    public var speedMps: Double
    public var horizontalAccuracy: Double
    public var heartRate: Int?
    public var cadence: Int?
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        latitude: Double,
        longitude: Double,
        altitude: Double = 0.0,
        speedMps: Double = 0.0,
        horizontalAccuracy: Double = 0.0,
        heartRate: Int? = nil,
        cadence: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speedMps = speedMps
        self.horizontalAccuracy = horizontalAccuracy
        self.heartRate = heartRate
        self.cadence = cadence
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var altitudeMeters: Double {
        altitude
    }
    
    public var clLocation: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: 5.0,
            course: 0.0,
            speed: speedMps,
            timestamp: timestamp
        )
    }
}

