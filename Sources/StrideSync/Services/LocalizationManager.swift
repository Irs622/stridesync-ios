import Foundation

public enum AppLanguage: String, CaseIterable, Codable, Sendable {
    case english = "en"
    case indonesian = "id"
}

/// Centralized manager for dynamic localization (i18n) across English and Indonesian languages.
public final class LocalizationManager: @unchecked Sendable {
    public static let shared = LocalizationManager()
    
    private let lock = NSLock()
    private var _currentLanguage: AppLanguage
    
    public var currentLanguage: AppLanguage {
        get {
            lock.withLock { _currentLanguage }
        }
        set {
            lock.withLock {
                _currentLanguage = newValue
                UserDefaults.standard.set(newValue.rawValue, forKey: "app_language_preference")
            }
        }
    }
    
    public init() {
        if let savedLang = UserDefaults.standard.string(forKey: "app_language_preference"),
           let lang = AppLanguage(rawValue: savedLang) {
            self._currentLanguage = lang
        } else {
            self._currentLanguage = .english
        }
    }
    
    private let translations: [AppLanguage: [String: String]] = [
        .english: [
            "start_workout": "Start Workout",
            "pause_workout": "Pause",
            "resume_workout": "Resume",
            "finish_workout": "Finish Workout",
            "distance": "Distance",
            "duration": "Duration",
            "moving_time": "Moving Time",
            "average_pace": "Avg Pace",
            "elevation_gain": "Elevation Gain",
            "heart_rate": "Heart Rate",
            "feed_title": "Activity Feed",
            "explore_title": "Explore & Segments",
            "challenges_title": "Monthly Challenges",
            "profile_title": "Athlete Profile",
            "kudos": "Kudos",
            "comments": "Comments",
            "gear_tracker": "Gear Tracker",
            "export_gpx": "Export GPX",
            "export_fit": "Export FIT"
        ],
        .indonesian: [
            "start_workout": "Mulai Workout",
            "pause_workout": "Jeda",
            "resume_workout": "Lanjutkan",
            "finish_workout": "Selesaikan Workout",
            "distance": "Jarak",
            "duration": "Durasi",
            "moving_time": "Waktu Bergerak",
            "average_pace": "Pace Rata-rata",
            "elevation_gain": "Elevasi Naik",
            "heart_rate": "Detak Jantung",
            "feed_title": "Feed Aktivitas",
            "explore_title": "Jelajah & Segmen",
            "challenges_title": "Tantangan Bulanan",
            "profile_title": "Profil Atlet",
            "kudos": "Kudos",
            "comments": "Komentar",
            "gear_tracker": "Manajemen Perangkat",
            "export_gpx": "Ekspor GPX",
            "export_fit": "Ekspor FIT"
        ]
    ]
    
    public func localizedString(for key: String) -> String {
        let lang = currentLanguage
        return translations[lang]?[key] ?? translations[.english]?[key] ?? key
    }
}

public extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}
