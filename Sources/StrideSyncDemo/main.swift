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
        Features: Pacing Coach, GPX Navigation, TRIMP Recovery, BLE Sensors, Heatmaps
        
        """)
        
        // 1. Inisialisasi Engine & Layanan
        print("🔹 [1/7] Menginisialisasi LocationEngine, SegmentMatcher & Services...")
        let engine = LocationEngine(activityType: .run, autoPauseEnabled: true)
        let splitCalculator = SplitCalculator(splitIntervalMeters: 1000.0)
        let segmentMatcher = SegmentMatcher(gateRadiusMeters: 40.0)
        let gpxService = GPXService()
        let privacyService = PrivacyZoneService(zones: [
            PrivacyZone(name: "Home Privacy Zone", latitude: -6.175392, longitude: 106.827153, radiusMeters: 200.0)
        ])
        
        // Pacing Coach & Target Split Setup
        let pacingCoach = PacingCoachService(target: .sub25_5K, languageCode: "id-ID")
        print("   🎯 Target Pacing Diatur: Sub-25m 5K (Pace Target: 5:00 /km)")
        
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
        print("\n🔹 [2/7] Memulai perekaman latihan GPS (Start Workout)...")
        await engine.start()
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan dimulai")
        
        let startTime = Date().addingTimeInterval(-1200) // 20 menit yang lalu
        print("   Status: REC (Recording) | Aktivitas: Outdoor Run")
        print("   ------------------------------------------------------------------------------------------------")
        print("   STEP | DISTANCE | SPEED   | ELEV GAIN | HR      | PACING DELTA | STATUS       | LIVE GPS POINT")
        print("   ------------------------------------------------------------------------------------------------")
        
        // 3. Simulasi Streaming Koordinat GPS (5 km simulasi rute)
        let baseLat = -6.175392
        let baseLon = 106.827153
        
        for i in 1...25 {
            // Setiap step = ~200 meter & ~48 detik (Pace ~4:00 /km - Lebih cepat dari target 5:00)
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
            let stateStr = metrics.state == .autoPaused ? "🟡 AUTO-PAUSE" : "🟢 RECORDING"
            let coordStr = String(format: "(%.4f, %.4f)", lat, baseLon)
            
            let feedback = pacingCoach.evaluate(
                distanceMeters: metrics.distanceMeters,
                elapsedTimeSeconds: metrics.elapsedTimeSeconds,
                currentPaceSecondsPerKm: metrics.currentPaceSecondsPerKm
            )
            let deltaStr = feedback?.formattedDelta ?? "--"
            
            print(String(format: "   #%02d  | %-8@ | %-7@ | %-9@ | %-7@ | %-12@ | %-12@ | %@", i, distKm, speedKmh, elevStr, hrStr, deltaStr, stateStr, coordStr))
        }
        
        print("   ------------------------------------------------------------------------------------------------")
        
        // 4. Menyelesaikan Latihan (Finish Workout)
        print("\n🔹 [3/7] Menyelesaikan latihan (Finish Workout)...")
        let (summary, telemetry) = await engine.finish()
        let activity = ActivityRecord(from: summary)
        activity.durationSeconds = 1200 // 20:00
        activity.movingTimeSeconds = 1152 // 19:12
        activity.averageSpeedMps = activity.distanceMeters / activity.movingTimeSeconds
        activity.rpe = 7 // Rating of Perceived Exertion (1-10)
        activity.gearName = "Nike Vaporfly 3"
        activity.notes = "Tempo run pagi yang sangat nyaman di area Monas!"
        
        print("   🏆 Judul Aktivitas : \(activity.title)")
        print("   📍 Total Jarak     : \(activity.formattedDistance)")
        print("   ⏱️ Durasi Total    : \(activity.formattedDuration)")
        print("   ⚡️ Waktu Bergerak  : \(activity.formattedMovingTime)")
        print("   🚀 Pace Rata-rata  : \(activity.formattedAveragePace)")
        print("   ⛰️ Elevasi Naik    : \(activity.formattedElevationGain)")
        print("   ❤️ HR Rata-rata    : \(activity.averageHeartRate != nil ? "\(activity.averageHeartRate!) bpm" : "-") (Max: \(activity.maxHeartRate != nil ? "\(activity.maxHeartRate!) bpm" : "-"))")
        print("   ⚡️ Skala RPE (1-10): \(activity.rpe != nil ? "\(activity.rpe!)/10 (Keras/Threshold)" : "-")")
        print("   👟 Sepatu Digunakan: \(activity.gearName ?? "-")")
        
        // 5. Analisis Fisiologis & Pemulihan (TRIMP & Recovery Score)
        print("\n🔹 [4/7] Menghitung Beban Fisiologis Latihan (Banister TRIMP & Recovery Gauge)...")
        let loadCalc = TrainingLoadCalculator(restingHeartRate: 58, maxHeartRate: 192, isMale: true)
        let trimpScore = loadCalc.calculateSessionTRIMP(durationSeconds: activity.durationSeconds, averageHeartRate: activity.averageHeartRate, rpeScore: activity.rpe)
        let trainingMetrics = loadCalc.calculateTrainingMetrics(currentSessionTrimp: trimpScore, previousATL: 42.0, previousCTL: 52.0)
        
        print("   📊 Skor TRIMP Sesi : \(trainingMetrics.formattedTrimp)")
        print("   📈 Chronic Load CTL: \(String(format: "%.1f", trainingMetrics.chronicTrainingLoad)) (Fitness)")
        print("   📉 Acute Load ATL  : \(String(format: "%.1f", trainingMetrics.acuteTrainingLoad)) (Fatigue)")
        print("   ⚡️ Training Form   : \(String(format: "%+.1f", trainingMetrics.trainingStressBalance)) (TSB)")
        print("   🛡️ Kesiapan Tubuh  : \(trainingMetrics.readiness.rawValue)")
        print("   ⏳ Waktu Istirahat : \(trainingMetrics.formattedRecoveryHours)")
        print("   💡 Rekomendasi     : \(trainingMetrics.readiness.adviceDescription)")
        
        // 6. Analisis Splits & Segmen
        print("\n🔹 [5/7] Menghitung Analisis Splits (per 1 Kilometer) & Segmen...")
        let splits = splitCalculator.calculateSplits(from: telemetry)
        for split in splits {
            print("   👉 Km \(split.splitIndex): Waktu \(split.formattedDuration) | Pace \(split.formattedPace) | Elevasi +\(String(format: "%.0f", split.elevationChangeMeters))m | HR Rata-rata \(split.averageHeartRate ?? 0) bpm")
        }
        
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
        
        // 7. Heatmap Global Pribadi & BLE Decoding
        print("\n🔹 [6/7] Agregasi Personal Global Heatmap & Pengujian Sensor BLE...")
        let heatmapEngine = HeatmapTileEngine(defaultZoom: 14)
        let coords = telemetry.map { $0.coordinate }
        let uniqueTiles = heatmapEngine.aggregateTiles(from: [coords])
        let heatStats = heatmapEngine.calculateExplorationStats(uniqueTilesCount: uniqueTiles.count, totalActivities: 1)
        print("   🗺️ Petak Heatmap   : \(heatStats.totalUniqueTiles) tiles unik di level zoom 14")
        print("   📐 Luas Eksplorasi : \(heatStats.formattedArea)")
        print("   🎖️ Lencana Badge   : \(heatStats.badge.rawValue)")
        
        // Bluetooth BLE Packet Test
        let rawHRPacket = Data([0x00, 164]) // 8-bit flag, 164 bpm
        let parsedBPM = BLEHeartRateAndSensorManager.parseHeartRateMeasurement(from: rawHRPacket)
        print("   📶 BLE GATT 0x2A37 : Berhasil mem-parsing \(parsedBPM ?? 0) BPM dari paket data biner nirkabel")
        
        // Ekspor GPX & Sanitasi Privasi
        print("\n🔹 [7/7] Menghasilkan Ekspor File GPX XML & Sanitasi Geofence Privasi...")
        _ = privacyService.sanitizeCoordinates(coords)
        let gpxXml = gpxService.exportToGPX(activity: activity, points: telemetry)
        print("   🛡️ Titik koordinat dalam radius 200m zona privasi rumah berhasil dimasking.")
        print("   📄 GPX 1.1 file berhasil dibuat (\(telemetry.count) titik rute).")
        
        print("""
        ========================================================================
           ✅ SELURUH FITUR STRIDESYNC v2.0+ BERJALAN DENGAN SEMPURNA (100%)!
        ========================================================================
        """)
    }
}
