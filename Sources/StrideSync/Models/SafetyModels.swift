import Foundation
import CoreLocation

/// Level of detail shared through the Live Safety Beacon web link.
public enum BeaconPrivacyLevel: String, Sendable, Codable, CaseIterable, Identifiable {
    case exactPosition = "Posisi Tepat (Real-Time)"
    case approximate = "Area Perkiraan (Radius 200m)"
    case statusOnly = "Status & Baterai Saja"
    
    public var id: String { rawValue }
}

/// An emergency contact who receives the live tracking link or incident alert.
public struct EmergencyContact: Identifiable, Sendable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var phoneNumber: String
    public var relationship: String // e.g. "Pasangan", "Orang Tua", "Sahabat"
    public var autoNotifyOnStart: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        phoneNumber: String,
        relationship: String = "Keluarga",
        autoNotifyOnStart: Bool = true
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.autoNotifyOnStart = autoNotifyOnStart
    }
}

/// Live Safety Beacon active tracking session data.
public struct LiveBeaconSession: Identifiable, Sendable, Codable {
    public var id: UUID
    public var beaconCode: String
    public var athleteName: String
    public var activityType: ActivityType
    public var isLive: Bool
    public var startTime: Date
    public var lastUpdated: Date
    public var currentCoordinate: CLLocationCoordinate2D?
    public var batteryLevelPercent: Int
    public var currentHeartRateBpm: Int?
    public var totalDistanceMeters: Double
    public var privacyLevel: BeaconPrivacyLevel
    public var emergencyStatusActive: Bool
    
    public var shareableURLString: String {
        "https://beacon.stridesync.app/live/\(beaconCode)"
    }
    
    public init(
        id: UUID = UUID(),
        beaconCode: String = UUID().uuidString.prefix(12).lowercased(),
        athleteName: String = "Atlet StrideSync",
        activityType: ActivityType = .run,
        isLive: Bool = true,
        startTime: Date = Date(),
        lastUpdated: Date = Date(),
        currentCoordinate: CLLocationCoordinate2D? = nil,
        batteryLevelPercent: Int = 100,
        currentHeartRateBpm: Int? = nil,
        totalDistanceMeters: Double = 0.0,
        privacyLevel: BeaconPrivacyLevel = .exactPosition,
        emergencyStatusActive: Bool = false
    ) {
        self.id = id
        self.beaconCode = beaconCode
        self.athleteName = athleteName
        self.activityType = activityType
        self.isLive = isLive
        self.startTime = startTime
        self.lastUpdated = lastUpdated
        self.currentCoordinate = currentCoordinate
        self.batteryLevelPercent = batteryLevelPercent
        self.currentHeartRateBpm = currentHeartRateBpm
        self.totalDistanceMeters = totalDistanceMeters
        self.privacyLevel = privacyLevel
        self.emergencyStatusActive = emergencyStatusActive
    }
    
    enum CodingKeys: String, CodingKey {
        case id, beaconCode, athleteName, activityType, isLive, startTime, lastUpdated
        case latitude, longitude, batteryLevelPercent, currentHeartRateBpm, totalDistanceMeters, privacyLevel, emergencyStatusActive
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.beaconCode = try container.decode(String.self, forKey: .beaconCode)
        self.athleteName = try container.decode(String.self, forKey: .athleteName)
        self.activityType = try container.decode(ActivityType.self, forKey: .activityType)
        self.isLive = try container.decode(Bool.self, forKey: .isLive)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        if let lat = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let lon = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            self.currentCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            self.currentCoordinate = nil
        }
        self.batteryLevelPercent = try container.decode(Int.self, forKey: .batteryLevelPercent)
        self.currentHeartRateBpm = try container.decodeIfPresent(Int.self, forKey: .currentHeartRateBpm)
        self.totalDistanceMeters = try container.decode(Double.self, forKey: .totalDistanceMeters)
        self.privacyLevel = try container.decode(BeaconPrivacyLevel.self, forKey: .privacyLevel)
        self.emergencyStatusActive = try container.decode(Bool.self, forKey: .emergencyStatusActive)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(beaconCode, forKey: .beaconCode)
        try container.encode(athleteName, forKey: .athleteName)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(isLive, forKey: .isLive)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encodeIfPresent(currentCoordinate?.latitude, forKey: .latitude)
        try container.encodeIfPresent(currentCoordinate?.longitude, forKey: .longitude)
        try container.encode(batteryLevelPercent, forKey: .batteryLevelPercent)
        try container.encodeIfPresent(currentHeartRateBpm, forKey: .currentHeartRateBpm)
        try container.encode(totalDistanceMeters, forKey: .totalDistanceMeters)
        try container.encode(privacyLevel, forKey: .privacyLevel)
        try container.encode(emergencyStatusActive, forKey: .emergencyStatusActive)
    }
}

/// Incident or hard fall event detected during an activity.
public struct IncidentEvent: Identifiable, Sendable, Codable {
    public var id: UUID
    public var timestamp: Date
    public var coordinate: CLLocationCoordinate2D
    public var peakGForce: Double
    public var isResolvedByUser: Bool
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        coordinate: CLLocationCoordinate2D,
        peakGForce: Double,
        isResolvedByUser: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.coordinate = coordinate
        self.peakGForce = peakGForce
        self.isResolvedByUser = isResolvedByUser
    }
    
    enum CodingKeys: String, CodingKey {
        case id, timestamp, latitude, longitude, peakGForce, isResolvedByUser
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lon = try container.decode(Double.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.peakGForce = try container.decode(Double.self, forKey: .peakGForce)
        self.isResolvedByUser = try container.decode(Bool.self, forKey: .isResolvedByUser)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(peakGForce, forKey: .peakGForce)
        try container.encode(isResolvedByUser, forKey: .isResolvedByUser)
    }
}
