import Foundation
import SwiftUI
import CoreLocation

/// Search filter scopes for narrowing down discovery queries.
public enum SearchScope: String, CaseIterable, Identifiable {
    case all = "Semua"
    case athletes = "Atlet"
    case activities = "Aktivitas"
    case segments = "Segmen"
    case clubs = "Klub"
    
    public var id: String { rawValue }
}

/// Community Club entity for group runs, cycling pelotons, and events.
public struct ClubItem: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let sportType: ActivityType
    public let memberCount: Int
    public let location: String
    public let description: String
    public var isJoined: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        sportType: ActivityType,
        memberCount: Int,
        location: String,
        description: String,
        isJoined: Bool = false
    ) {
        self.id = id
        self.name = name
        self.sportType = sportType
        self.memberCount = memberCount
        self.location = location
        self.description = description
        self.isJoined = isJoined
    }
}

/// ViewModel powering global search across athletes, activities, segments, and clubs.
@Observable
@MainActor
public final class SearchViewModel {
    public var searchQuery: String = ""
    public var selectedScope: SearchScope = .all
    public var recentSearches: [String] = ["Monas", "Sudirman", "GBK Runners", "Sarah", "10K"]
    
    public var allAthletes: [AthleteProfile] = []
    public var allActivities: [ActivityRecord] = []
    public var allSegments: [Segment] = []
    public var allClubs: [ClubItem] = []
    
    public init() {
        self.allAthletes = Self.sampleAthletes()
        self.allActivities = Self.sampleActivities()
        self.allSegments = ExploreView.sampleSegments()
        self.allClubs = Self.sampleClubs()
    }
    
    // MARK: - Search Results Filtering
    
    public var filteredAthletes: [AthleteProfile] {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return allAthletes.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchQuery) ||
            $0.username.localizedCaseInsensitiveContains(searchQuery) ||
            ($0.bio?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
    
    public var filteredActivities: [ActivityRecord] {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return allActivities.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            ($0.notes?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
            $0.activityType.rawValue.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public var filteredSegments: [Segment] {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return allSegments.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.activityType.rawValue.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public var filteredClubs: [ClubItem] {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return allClubs.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.location.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public var hasResults: Bool {
        !filteredAthletes.isEmpty || !filteredActivities.isEmpty || !filteredSegments.isEmpty || !filteredClubs.isEmpty
    }
    
    public func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !recentSearches.contains(trimmed) {
            recentSearches.insert(trimmed, at: 0)
            if recentSearches.count > 8 {
                recentSearches.removeLast()
            }
        }
    }
    
    public func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
    }
    
    public func clearRecentSearches() {
        recentSearches.removeAll()
    }
    
    // MARK: - Sample Data
    
    private static func sampleAthletes() -> [AthleteProfile] {
        [
            AthleteProfile(username: "sarahj", fullName: "Sarah Jenkins", bio: "Ultra trail runner 🏔️ | Chasing 100 miler", totalDistanceMeters: 840_000, totalActivitiesCount: 92, followersCount: 420, followingCount: 230),
            AthleteProfile(username: "davidc", fullName: "David Chen", bio: "Road cyclist & Coffee enthusiast 🚴‍♂️☕️", totalDistanceMeters: 2_150_000, totalActivitiesCount: 140, followersCount: 890, followingCount: 310),
            AthleteProfile(username: "elenar", fullName: "Elena Rostova", bio: "Track & Field athlete | Sub 18min 5K ⚡️", totalDistanceMeters: 520_000, totalActivitiesCount: 65, followersCount: 610, followingCount: 180),
            AthleteProfile(username: "marcusv", fullName: "Marcus Vance", bio: "Triathlete in training 🏊‍♂️🚴‍♂️🏃‍♂️", totalDistanceMeters: 1_400_000, totalActivitiesCount: 115, followersCount: 740, followingCount: 412)
        ]
    }
    
    private static func sampleActivities() -> [ActivityRecord] {
        let now = Date()
        let act1 = ActivityRecord(
            title: "Morning 10K Tempo Run 🏃‍♂️🔥",
            activityType: .run,
            startTime: now.addingTimeInterval(-3600),
            distanceMeters: 10250.0,
            durationSeconds: 2650,
            movingTimeSeconds: 2650,
            totalElevationGainMeters: 85.0,
            averageSpeedMps: 3.86,
            notes: "Felt strong throughout! Perfect chilly morning air."
        )
        act1.kudosCount = 24
        act1.commentsCount = 3
        
        let act2 = ActivityRecord(
            title: "Weekend Hill Climb Cycling 🚴‍♀️⛰️",
            activityType: .ride,
            startTime: now.addingTimeInterval(-86400),
            distanceMeters: 45300.0,
            durationSeconds: 6800,
            movingTimeSeconds: 6800,
            totalElevationGainMeters: 620.0,
            averageSpeedMps: 6.66,
            notes: "Steep climbs on the south loop, rewarding descent!"
        )
        act2.kudosCount = 42
        act2.commentsCount = 5
        
        return [act1, act2]
    }
    
    private static func sampleClubs() -> [ClubItem] {
        [
            ClubItem(name: "Jakarta Runners Club", sportType: .run, memberCount: 1420, location: "Jakarta, Indonesia", description: "Komunitas lari terbesar di Jakarta untuk semua tingkatan."),
            ClubItem(name: "Sudirman Peloton Cycling", sportType: .ride, memberCount: 860, location: "Jakarta, Indonesia", description: "Gowes bersama setiap Selasa & Kamis subuh keliling Sudirman-Thamrin."),
            ClubItem(name: "Trail Seekers Indonesia", sportType: .hike, memberCount: 540, location: "Bogor & Bandung", description: "Petualangan lari gunung dan hiking akhir pekan.")
        ]
    }
}

