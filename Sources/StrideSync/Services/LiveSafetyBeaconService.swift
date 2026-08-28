import Foundation
import CoreLocation

/// Service managing Live Safety Beacon web sharing and real-time telemetry streaming to contacts.
@Observable
@MainActor
public final class LiveSafetyBeaconService {
    public static let shared = LiveSafetyBeaconService()
    
    public var currentSession: LiveBeaconSession?
    public var emergencyContacts: [EmergencyContact] = []
    public var isBeaconActive: Bool = false
    public var lastBroadcastTime: Date?
    
    public init() {
        self.emergencyContacts = Self.defaultEmergencyContacts()
    }
    
    /// Starts a new live safety beacon session with an encrypted token link.
    public func startBeacon(
        athleteName: String = "Budi Santoso",
        activityType: ActivityType = .run,
        privacyLevel: BeaconPrivacyLevel = .exactPosition
    ) -> LiveBeaconSession {
        let randomSuffix = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(10).lowercased()
        let session = LiveBeaconSession(
            beaconCode: String(randomSuffix),
            athleteName: athleteName,
            activityType: activityType,
            isLive: true,
            startTime: Date(),
            lastUpdated: Date(),
            batteryLevelPercent: 95,
            privacyLevel: privacyLevel,
            emergencyStatusActive: false
        )
        self.currentSession = session
        self.isBeaconActive = true
        self.lastBroadcastTime = Date()
        
        // Notify auto-enabled emergency contacts
        for contact in emergencyContacts where contact.autoNotifyOnStart {
            print("[SafetyBeacon] SMS sent to \(contact.name) (\(contact.phoneNumber)): 'Atlet \(athleteName) memulai latihan. Pantau live di \(session.shareableURLString)'")
        }
        
        return session
    }
    
    /// Updates live location and athlete telemetry to be broadcasted to viewers.
    public func updateTelemetry(
        coordinate: CLLocationCoordinate2D,
        distanceMeters: Double,
        heartRateBpm: Int?,
        batteryPercent: Int = 90
    ) {
        guard var session = currentSession, session.isLive else { return }
        
        session.currentCoordinate = coordinate
        session.totalDistanceMeters = distanceMeters
        session.currentHeartRateBpm = heartRateBpm
        session.batteryLevelPercent = batteryPercent
        session.lastUpdated = Date()
        
        self.currentSession = session
        self.lastBroadcastTime = Date()
    }
    
    /// Triggers an emergency incident alert broadcast to all emergency contacts.
    public func triggerEmergencyAlert(at coordinate: CLLocationCoordinate2D) {
        guard var session = currentSession else { return }
        session.emergencyStatusActive = true
        session.currentCoordinate = coordinate
        session.lastUpdated = Date()
        self.currentSession = session
        
        for contact in emergencyContacts {
            print("[EMERGENCY SOS] Alert sent to \(contact.name) (\(contact.phoneNumber)): 'DARURAT! Terdeteksi insiden/jatuh keras pada atlet \(session.athleteName) di lokasi (lat: \(coordinate.latitude), lon: \(coordinate.longitude)). Buka: \(session.shareableURLString)'")
        }
    }
    
    /// Stops the live beacon session.
    public func stopBeacon() {
        currentSession?.isLive = false
        isBeaconActive = false
    }
    
    public static func defaultEmergencyContacts() -> [EmergencyContact] {
        [
            EmergencyContact(name: "Siti Rahmawati", phoneNumber: "+62 812-3456-7890", relationship: "Pasangan", autoNotifyOnStart: true),
            EmergencyContact(name: "Dr. Budi Utomo", phoneNumber: "+62 811-9876-5432", relationship: "Dokter Keluarga", autoNotifyOnStart: false)
        ]
    }
}
