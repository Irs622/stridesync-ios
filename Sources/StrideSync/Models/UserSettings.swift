import Foundation
import SwiftUI

/// User settings and preferences model for workout tracking, privacy, units, and notifications.
@Observable
@MainActor
public final class UserSettingsManager {
    public static let shared = UserSettingsManager()
    
    // User Profile
    public var fullName: String = "Budi Santoso"
    public var username: String = "budisport"
    public var bio: String = "Marathon runner in training 🏃‍♂️ | 5K PB: 19:42 | Jakarta, Indonesia"
    public var location: String = "Jakarta, Indonesia"
    public var weightKg: Double = 68.0
    public var heightCm: Double = 175.0
    public var gender: String = "Pria"
    
    // Tracking & Sensors
    public var defaultActivityType: ActivityType = .run
    public var isMetricUnits: Bool = true
    public var autoPauseEnabled: Bool = true
    public var autoPauseThresholdSpeed: Double = 0.8
    public var healthKitSyncEnabled: Bool = true
    public var appleWatchSyncEnabled: Bool = true
    
    // Audio Cues
    public var isAudioCueEnabled: Bool = true
    public var audioCueLanguage: String = "id-ID"
    public var audioCueIntervalMeters: Double = 1000.0
    public var announceSplitPace: Bool = true
    public var announceTotalTime: Bool = true
    public var announceHeartRate: Bool = true
    
    // Privacy & Security
    public var defaultVisibility: VisibilityType = .publicVisibility
    public var hideHeartRateData: Bool = false
    public var hideStartFinishPoints: Bool = true
    public var privacyRadiusMeters: Double = 500.0
    public var privacyZones: [PrivacyZone] = [
        PrivacyZone(name: "Rumah", latitude: -6.175392, longitude: 106.827153, radiusMeters: 500.0),
        PrivacyZone(name: "Kantor", latitude: -6.210000, longitude: 106.820000, radiusMeters: 300.0)
    ]
    
    // Notifications
    public var notifyKudos: Bool = true
    public var notifyComments: Bool = true
    public var notifyWeeklyDigest: Bool = true
    public var notifyClubEvents: Bool = true
    public var notifySegmentLoss: Bool = true
    
    public init() {}
    
    public func addPrivacyZone(name: String, latitude: Double, longitude: Double, radiusMeters: Double) {
        let zone = PrivacyZone(name: name, latitude: latitude, longitude: longitude, radiusMeters: radiusMeters)
        privacyZones.append(zone)
    }
    
    public func removePrivacyZone(at indexSet: IndexSet) {
        privacyZones.remove(atOffsets: indexSet)
    }
}

