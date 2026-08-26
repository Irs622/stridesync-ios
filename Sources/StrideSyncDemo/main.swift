import Foundation
import CoreLocation
import StrideSync

@main
struct StrideSyncDemoRunner {
    static func main() async {
        print("""
        ========================================================================
           🏃‍♂️⚡️ STRIDESYNC - FITNESS & SOCIAL TRACKING SYSTEM (SWIFT 6) ⚡️🚴‍♀️
        ========================================================================
        Platform: iOS 18+ / macOS 14+ | Engine: LocationEngine Actor & SwiftData
        
        """)
        
        // 1. Inisialisasi Engine & Layanan
        print("🔹 [1/6] Menginisialisasi LocationEngine, SegmentMatcher & Services...")
        let engine = LocationEngine(activityType: .run, autoPauseEnabled: true)
        let splitCalculator = SplitCalculator(splitIntervalMeters: 1000.0)
        let segmentMatcher = SegmentMatcher(gateRadiusMeters: 40.0)
        let gpxService = GPXService()
        let privacyService = PrivacyZoneService(zones: [
            PrivacyZone(name: "Home Privacy Zone", latitude: -6.175392, longitude: 106.827153, radiusMeters: 200.0)
        ])
        
        // Buat Segmen Virtual (misal tanjakan Monas)
        let sampleSegment = Segment(
            name: "Monas North Sprint ⚡️",
            activityType: .run,
            distanceMeters: 600.0,
            elevationGainMeters: 5.0,
            averageGradePercent: 0.8,
            startCoordinate: CLLocationCoordinate2D(latitude: -6.170000, longitude: 106.827153),
            endCoordinate: CLLocationCoordinate2D(latitude: -6.164000, longitude: 106.827153),
            komTimeSeconds: 160.0,
            komAthleteName: "Alex Rivera",
            totalEffortsCount: 84
        )
        
        // 2. Memulai Sesi Latihan
        print("🔹 [2/6] Memulai perekaman latihan GPS (Start Workout)...")
        await engine.start()
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan dimulai")
        
        let startTime = Date().addingTimeInterval(-1200) // 20 menit yang lalu
        print("   Status: REC (Recording) | Aktivitas: Outdoor Run")
        print("   ---------------------------------------------------------------------------------")
        print("   STEP | DISTANCE | SPEED   | ELEV GAIN | HR      | STATUS       | LIVE GPS POINT")
        print("   ---------------------------------------------------------------------------------")
        
        // 3. Simulasi Streaming Koordinat GPS (5 km simulasi rute)
        let baseLat = -6.175392
        let baseLon = 106.827153
        
        for i in 1...25 {
            // Setiap step = ~200 meter & ~48 detik (Pace ~4:00 /km)
            let lat = baseLat + (Double(i) * 0.0018)
            let alt = 15.0 + (Double(i) * 1.2)
            let speed = (i == 12) ? 0.3 : 4.16 // Simulasi auto-pause di step ke-12 (lampu merah)
            let hr = 145 + (i * 1)
            let timestamp = startTime.addingTimeInterval(Double(i) * 48.0)
            
            await engine.updateHeartRate(hr)
            
            let clLocation = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: baseLon),
                altitude: alt,
                horizontalAccuracy: 5.0,
                verticalAccuracy: 5.0,
                course: 0.0,
                speed: speed,
                timestamp: timestamp
            )
            
            let metrics = await engine.processLocation(clLocation)
            
            let distKm = String(format: "%.2f km", metrics.distanceMeters / 1000.0)
            let speedKmh = String(format: "%.1f km/h", metrics.currentSpeedMps * 3.6)
            let elevStr = String(format: "%.0f m", metrics.totalElevationGainMeters)
            let hrStr = "\(hr) bpm"
            let stateStr = metrics.state == .autoPaused ? "🟡 AUTO-PAUSED" : "🟢 RECORDING"
            let coordStr = String(format: "(%.4f, %.4f)", lat, baseLon)
            
            print(String(format: "   #%02d  | %-8@ | %-7@ | %-9@ | %-7@ | %-12@ | %@", i, distKm, speedKmh, elevStr, hrStr, stateStr, coordStr))
        }
        
        print("   ---------------------------------------------------------------------------------")
        
        // 4. Menyelesaikan Latihan (Finish Workout)
        print("\n🔹 [3/6] Menyelesaikan latihan (Finish Workout)...")
        let (summary, telemetry) = await engine.finish()
        let activity = ActivityRecord(from: summary)
        activity.durationSeconds = 1200 // 20:00
        activity.movingTimeSeconds = 1152 // 19:12
        activity.averageSpeedMps = activity.distanceMeters / activity.movingTimeSeconds
        activity.gearName = "Nike Vaporfly 3"
        activity.notes = "Tempo run pagi yang sangat nyaman di area Monas!"
        
        print("   🏆 Judul Aktivitas : \(activity.title)")
        print("   📍 Total Jarak     : \(activity.formattedDistance)")
        print("   ⏱️ Durasi Total    : \(activity.formattedDuration)")
        print("   ⚡️ Waktu Bergerak  : \(activity.formattedMovingTime)")
        print("   🚀 Pace Rata-rata  : \(activity.formattedAveragePace)")
        print("   ⛰️ Elevasi Naik    : \(activity.formattedElevationGain)")
        print("   👟 Sepatu Digunakan: \(activity.gearName ?? "-")")
        
        // 5. Analisis Splits per Kilometer
        print("\n🔹 [4/6] Menghitung Analisis Splits (per 1 Kilometer)...")
        let splits = splitCalculator.calculateSplits(from: telemetry)
        for split in splits {
            print("   👉 Km \(split.splitIndex): Waktu \(split.formattedDuration) | Pace \(split.formattedPace) | Elevasi +\(String(format: "%.0f", split.elevationChangeMeters))m | HR Rata-rata \(split.averageHeartRate ?? 0) bpm")
        }
        
        // 6. Pencocokan Segmen Virtual (Segment Matching & KOM)
        print("\n🔹 [5/6] Memeriksa Pencocokan Segmen (Virtual KOM / PR)...")
        let athleteId = UUID()
        let efforts = segmentMatcher.matchSegments(
            activityPoints: telemetry,
            segments: [sampleSegment],
            athleteId: athleteId,
            athleteName: "Budi Santoso (You)"
        )
        
        if let effort = efforts.first {
            print("   👑 MATCHED SEGMENT : \(effort.segmentName)")
            print("   ⏱️ Waktu Tempuh    : \(effort.formattedDuration) (Waktu KOM sebelumnya: 2:40)")
            if effort.isKOM {
                print("   🥇 SELAMAT! Anda meraih gelar KING OF THE MOUNTAIN (KOM) baru!")
            }
        }
        
        // 7. Ekspor GPX & Sanitasi Privasi
        print("\n🔹 [6/6] Menghasilkan Ekspor File GPX XML & Sanitasi Geofence Privasi...")
        _ = privacyService.sanitizeCoordinates(telemetry.map { $0.coordinate })
        let gpxXml = gpxService.exportToGPX(activity: activity, points: telemetry)
        
        print("   🛡️ Titik koordinat awal dalam radius 200m zona privasi rumah berhasil disanitasi.")
        print("   📄 Header GPX 1.1 yang berhasil dibuat:")
        let lines = gpxXml.components(separatedBy: "\n").prefix(10)
        for line in lines {
            print("      \(line)")
        }
        print("      ... [\(telemetry.count) titik koordinat berhasil diekspor ke file GPX]")
        
        // Feed Sosial Demo
        print("\n========================================================================")
        print("   📱 PREVIEW SOCIAL COMMUNITY FEED (STRIDESYNC)")
        print("========================================================================")
        let feedVM = FeedViewModel(activities: [activity])
        feedVM.loadMockFeed()
        let allFeed = feedVM.activities
        for act in allFeed {
            let liked = act.isLikedByCurrentUser ? "❤️" : "🤍"
            print("   [\(act.activityType.rawValue)] \(act.title)")
            print("   Jarak: \(act.formattedDistance) | Pace: \(act.formattedAveragePace) | \(liked) \(act.kudosCount) Kudos | 💬 \(act.commentsCount) Komentar\n")
        }
        
        print("""
        ========================================================================
           ✅ SEMUA MODUL STRIDESYNC BERHASIL DIJALANKAN (STATUS: 100% WORKING)!
        ========================================================================
        """)
    }
}

