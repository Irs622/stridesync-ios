import Foundation
import CoreLocation

/// Represents camera parameters for rendering a dynamic 3D flyover viewpoint over a GPS route.
public struct FlyoverCameraAngle: Sendable, Codable {
    public var centerCoordinate: CLLocationCoordinate2D
    public var altitudeMeters: Double
    public var pitchDegrees: Double // Angle from ground (e.g. 60° for dramatic bird's-eye view)
    public var headingDegrees: Double // Compass direction (0°-360°)
    
    public init(
        centerCoordinate: CLLocationCoordinate2D,
        altitudeMeters: Double = 450.0,
        pitchDegrees: Double = 60.0,
        headingDegrees: Double = 0.0
    ) {
        self.centerCoordinate = centerCoordinate
        self.altitudeMeters = altitudeMeters
        self.pitchDegrees = pitchDegrees
        self.headingDegrees = headingDegrees
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitudeMeters
        case pitchDegrees
        case headingDegrees
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.altitudeMeters = try container.decode(Double.self, forKey: .altitudeMeters)
        self.pitchDegrees = try container.decode(Double.self, forKey: .pitchDegrees)
        self.headingDegrees = try container.decode(Double.self, forKey: .headingDegrees)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(centerCoordinate.latitude, forKey: .latitude)
        try container.encode(centerCoordinate.longitude, forKey: .longitude)
        try container.encode(altitudeMeters, forKey: .altitudeMeters)
        try container.encode(pitchDegrees, forKey: .pitchDegrees)
        try container.encode(headingDegrees, forKey: .headingDegrees)
    }
}

/// A milestone event highlighted during the 3D flyover replay (e.g. Kilometer split, Peak Altitude, Sprint segment).
public struct FlyoverMilestone: Identifiable, Sendable, Codable {
    public var id: UUID
    public var title: String
    public var subtitle: String
    public var coordinate: CLLocationCoordinate2D
    public var progressFraction: Double // 0.0 to 1.0 along the route
    public var iconName: String
    
    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        coordinate: CLLocationCoordinate2D,
        progressFraction: Double,
        iconName: String = "flag.fill"
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.progressFraction = progressFraction
        self.iconName = iconName
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, latitude, longitude, progressFraction, iconName
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.progressFraction = try container.decode(Double.self, forKey: .progressFraction)
        self.iconName = try container.decode(String.self, forKey: .iconName)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(progressFraction, forKey: .progressFraction)
        try container.encode(iconName, forKey: .iconName)
    }
}

/// Configuration settings for rendering a 3D Flyover animation or video export.
public struct FlyoverConfiguration: Sendable, Codable {
    public var playbackSpeedMultiplier: Double // 1.0x, 2.0x, 4.0x
    public var showMilestonePopups: Bool
    public var showElevationProfileCard: Bool
    public var showHeartRatePulse: Bool
    public var cameraFollowDistanceMeters: Double
    
    public init(
        playbackSpeedMultiplier: Double = 2.0,
        showMilestonePopups: Bool = true,
        showElevationProfileCard: Bool = true,
        showHeartRatePulse: Bool = true,
        cameraFollowDistanceMeters: Double = 400.0
    ) {
        self.playbackSpeedMultiplier = playbackSpeedMultiplier
        self.showMilestonePopups = showMilestonePopups
        self.showElevationProfileCard = showElevationProfileCard
        self.showHeartRatePulse = showHeartRatePulse
        self.cameraFollowDistanceMeters = cameraFollowDistanceMeters
    }
}

