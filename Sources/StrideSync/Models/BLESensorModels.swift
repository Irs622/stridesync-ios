import Foundation

/// Type of standard external Bluetooth sports hardware sensor.
public enum BLESensorType: String, Codable, Sendable, CaseIterable {
    case heartRate = "Heart Rate Monitor"
    case cyclingCadence = "Cadence Sensor"
    case cyclingSpeed = "Speed Sensor"
    case powerMeter = "Power Meter (Watts)"
    
    public var iconName: String {
        switch self {
        case .heartRate: return "heart.fill"
        case .cyclingCadence: return "arrow.triangle.2.circlepath"
        case .cyclingSpeed: return "speedometer"
        case .powerMeter: return "bolt.fill"
        }
    }
}

/// Discovered or connected Bluetooth LE peripheral device.
public struct BLESensorDevice: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let sensorType: BLESensorType
    public var isConnected: Bool
    public var rssi: Int?
    public var batteryLevel: Int?
    
    public init(
        id: UUID = UUID(),
        name: String,
        sensorType: BLESensorType,
        isConnected: Bool = false,
        rssi: Int? = -65,
        batteryLevel: Int? = 90
    ) {
        self.id = id
        self.name = name
        self.sensorType = sensorType
        self.isConnected = isConnected
        self.rssi = rssi
        self.batteryLevel = batteryLevel
    }
}

/// Live real-time telemetry decoded from BLE GATT packets.
public struct BLETelemetryData: Sendable, Equatable {
    public var heartRateBpm: Int?
    public var cadenceRpm: Int?
    public var powerWatts: Int?
    public var speedMps: Double?
    
    public init(
        heartRateBpm: Int? = nil,
        cadenceRpm: Int? = nil,
        powerWatts: Int? = nil,
        speedMps: Double? = nil
    ) {
        self.heartRateBpm = heartRateBpm
        self.cadenceRpm = cadenceRpm
        self.powerWatts = powerWatts
        self.speedMps = speedMps
    }
}

