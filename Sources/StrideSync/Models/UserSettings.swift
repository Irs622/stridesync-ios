import Foundation
import SwiftUI

/// Persistent DTO representing all serializable user preferences.
public struct UserSettingsData: Codable, Sendable {
    public var fullName: String = "Budi Santoso"
    public var username: String = "budisport"
    public var bio: String = "Marathon runner in training 🏃‍♂️ | 5K PB: 19:42 | Jakarta, Indonesia"
    public var location: String = "Jakarta, Indonesia"
    public var weightKg: Double = 68.0
    public var heightCm: Double = 175.0
    public var gender: String = "Pria"
    
    public var defaultActivityType: ActivityType = .run
    public var isMetricUnits: Bool = true
    public var autoPauseEnabled: Bool = true
    public var autoPauseThresholdSpeed: Double = 0.8
    public var healthKitSyncEnabled: Bool = true
    public var appleWatchSyncEnabled: Bool = true
    
    public var isAudioCueEnabled: Bool = true
    public var audioCueLanguage: String = "id-ID"
    public var audioCueIntervalMeters: Double = 1000.0
    public var announceSplitPace: Bool = true
    public var announceTotalTime: Bool = true
    public var announceHeartRate: Bool = true
    
    public var defaultVisibility: VisibilityType = .publicVisibility
    public var hideHeartRateData: Bool = false
    public var hideStartFinishPoints: Bool = true
    public var privacyRadiusMeters: Double = 500.0
    public var privacyZones: [PrivacyZone] = [
        PrivacyZone(name: "Rumah", latitude: -6.175392, longitude: 106.827153, radiusMeters: 500.0),
        PrivacyZone(name: "Kantor", latitude: -6.210000, longitude: 106.820000, radiusMeters: 300.0)
    ]
    
    public var notifyKudos: Bool = true
    public var notifyComments: Bool = true
    public var notifyWeeklyDigest: Bool = true
    public var notifyClubEvents: Bool = true
    public var notifySegmentLoss: Bool = true
    
    public init() {}
}

/// User settings and preferences manager with automatic UserDefaults persistence.
@Observable
@MainActor
public final class UserSettingsManager {
    public static let shared = UserSettingsManager()
    private static let userDefaultsKey = "com.stridesync.userSettings.v1"
    
    // User Profile
    public var fullName: String { didSet { save() } }
    public var username: String { didSet { save() } }
    public var bio: String { didSet { save() } }
    public var location: String { didSet { save() } }
    public var weightKg: Double { didSet { save() } }
    public var heightCm: Double { didSet { save() } }
    public var gender: String { didSet { save() } }
    
    // Tracking & Sensors
    public var defaultActivityType: ActivityType { didSet { save() } }
    public var isMetricUnits: Bool { didSet { save() } }
    public var autoPauseEnabled: Bool { didSet { save() } }
    public var autoPauseThresholdSpeed: Double { didSet { save() } }
    public var healthKitSyncEnabled: Bool { didSet { save() } }
    public var appleWatchSyncEnabled: Bool { didSet { save() } }
    
    // Audio Cues
    public var isAudioCueEnabled: Bool { didSet { save() } }
    public var audioCueLanguage: String { didSet { save() } }
    public var audioCueIntervalMeters: Double { didSet { save() } }
    public var announceSplitPace: Bool { didSet { save() } }
    public var announceTotalTime: Bool { didSet { save() } }
    public var announceHeartRate: Bool { didSet { save() } }
    
    // Privacy & Security
    public var defaultVisibility: VisibilityType { didSet { save() } }
    public var hideHeartRateData: Bool { didSet { save() } }
    public var hideStartFinishPoints: Bool { didSet { save() } }
    public var privacyRadiusMeters: Double { didSet { save() } }
    public var privacyZones: [PrivacyZone] { didSet { save() } }
    
    // Notifications
    public var notifyKudos: Bool { didSet { save() } }
    public var notifyComments: Bool { didSet { save() } }
    public var notifyWeeklyDigest: Bool { didSet { save() } }
    public var notifyClubEvents: Bool { didSet { save() } }
    public var notifySegmentLoss: Bool { didSet { save() } }
    
    private var isSavingDisabled: Bool = false
    
    public init() {
        let initialData: UserSettingsData
        if let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserSettingsData.self, from: data) {
            initialData = decoded
        } else {
            initialData = UserSettingsData()
        }
        
        self.fullName = initialData.fullName
        self.username = initialData.username
        self.bio = initialData.bio
        self.location = initialData.location
        self.weightKg = initialData.weightKg
        self.heightCm = initialData.heightCm
        self.gender = initialData.gender
        
        self.defaultActivityType = initialData.defaultActivityType
        self.isMetricUnits = initialData.isMetricUnits
        self.autoPauseEnabled = initialData.autoPauseEnabled
        self.autoPauseThresholdSpeed = initialData.autoPauseThresholdSpeed
        self.healthKitSyncEnabled = initialData.healthKitSyncEnabled
        self.appleWatchSyncEnabled = initialData.appleWatchSyncEnabled
        
        self.isAudioCueEnabled = initialData.isAudioCueEnabled
        self.audioCueLanguage = initialData.audioCueLanguage
        self.audioCueIntervalMeters = initialData.audioCueIntervalMeters
        self.announceSplitPace = initialData.announceSplitPace
        self.announceTotalTime = initialData.announceTotalTime
        self.announceHeartRate = initialData.announceHeartRate
        
        self.defaultVisibility = initialData.defaultVisibility
        self.hideHeartRateData = initialData.hideHeartRateData
        self.hideStartFinishPoints = initialData.hideStartFinishPoints
        self.privacyRadiusMeters = initialData.privacyRadiusMeters
        self.privacyZones = initialData.privacyZones
        
        self.notifyKudos = initialData.notifyKudos
        self.notifyComments = initialData.notifyComments
        self.notifyWeeklyDigest = initialData.notifyWeeklyDigest
        self.notifyClubEvents = initialData.notifyClubEvents
        self.notifySegmentLoss = initialData.notifySegmentLoss
    }
    
    public func save() {
        guard !isSavingDisabled else { return }
        var data = UserSettingsData()
        data.fullName = fullName
        data.username = username
        data.bio = bio
        data.location = location
        data.weightKg = weightKg
        data.heightCm = heightCm
        data.gender = gender
        
        data.defaultActivityType = defaultActivityType
        data.isMetricUnits = isMetricUnits
        data.autoPauseEnabled = autoPauseEnabled
        data.autoPauseThresholdSpeed = autoPauseThresholdSpeed
        data.healthKitSyncEnabled = healthKitSyncEnabled
        data.appleWatchSyncEnabled = appleWatchSyncEnabled
        
        data.isAudioCueEnabled = isAudioCueEnabled
        data.audioCueLanguage = audioCueLanguage
        data.audioCueIntervalMeters = audioCueIntervalMeters
        data.announceSplitPace = announceSplitPace
        data.announceTotalTime = announceTotalTime
        data.announceHeartRate = announceHeartRate
        
        data.defaultVisibility = defaultVisibility
        data.hideHeartRateData = hideHeartRateData
        data.hideStartFinishPoints = hideStartFinishPoints
        data.privacyRadiusMeters = privacyRadiusMeters
        data.privacyZones = privacyZones
        
        data.notifyKudos = notifyKudos
        data.notifyComments = notifyComments
        data.notifyWeeklyDigest = notifyWeeklyDigest
        data.notifyClubEvents = notifyClubEvents
        data.notifySegmentLoss = notifySegmentLoss
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        }
    }
    
    public func addPrivacyZone(name: String, latitude: Double, longitude: Double, radiusMeters: Double) {
        let zone = PrivacyZone(name: name, latitude: latitude, longitude: longitude, radiusMeters: radiusMeters)
        privacyZones.append(zone)
    }
    
    public func removePrivacyZone(at indexSet: IndexSet) {
        privacyZones.remove(atOffsets: indexSet)
    }
    
    public func resetToDefaults() {
        isSavingDisabled = true
        let defaultData = UserSettingsData()
        self.fullName = defaultData.fullName
        self.username = defaultData.username
        self.bio = defaultData.bio
        self.location = defaultData.location
        self.weightKg = defaultData.weightKg
        self.heightCm = defaultData.heightCm
        self.gender = defaultData.gender
        self.defaultActivityType = defaultData.defaultActivityType
        self.isMetricUnits = defaultData.isMetricUnits
        self.autoPauseEnabled = defaultData.autoPauseEnabled
        self.autoPauseThresholdSpeed = defaultData.autoPauseThresholdSpeed
        self.healthKitSyncEnabled = defaultData.healthKitSyncEnabled
        self.appleWatchSyncEnabled = defaultData.appleWatchSyncEnabled
        self.isAudioCueEnabled = defaultData.isAudioCueEnabled
        self.audioCueLanguage = defaultData.audioCueLanguage
        self.audioCueIntervalMeters = defaultData.audioCueIntervalMeters
        self.announceSplitPace = defaultData.announceSplitPace
        self.announceTotalTime = defaultData.announceTotalTime
        self.announceHeartRate = defaultData.announceHeartRate
        self.defaultVisibility = defaultData.defaultVisibility
        self.hideHeartRateData = defaultData.hideHeartRateData
        self.hideStartFinishPoints = defaultData.hideStartFinishPoints
        self.privacyRadiusMeters = defaultData.privacyRadiusMeters
        self.privacyZones = defaultData.privacyZones
        self.notifyKudos = defaultData.notifyKudos
        self.notifyComments = defaultData.notifyComments
        self.notifyWeeklyDigest = defaultData.notifyWeeklyDigest
        self.notifyClubEvents = defaultData.notifyClubEvents
        self.notifySegmentLoss = defaultData.notifySegmentLoss
        isSavingDisabled = false
        save()
    }
}

