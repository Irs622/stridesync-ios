#if os(macOS)
import Foundation
import CoreLocation
import StrideSync

@main
struct StrideSyncDemoRunner {
    static func main() async {
        print("""
        ========================================================================
           🏃‍♂️⚡️ STRIDESYNC v3.0 - NEXT-GEN ATHLETIC INTELLIGENCE (SWIFT 6) ⚡️🚴‍♀️
        ========================================================================
        Platform: iOS 18+ / macOS 14+ | Engine: LocationEngine Actor & SwiftData
        Features: Pacing Coach, Navigation, TRIMP, Heatmap, VO2 Max, AI Story,
                  3D Flyover, Live Safety Beacon, Biomechanics & Ghost Runner
        
        """)
        
        // 1. Inisialisasi Engine & Layanan
        print("🔹 [1/9] Menginisialisasi LocationEngine, Safety Beacon & Services...")
        let engine = LocationEngine(activityType: .run, autoPauseEnabled: true)
        let splitCalculator = SplitCalculator(splitIntervalMeters: 1000.0)
        let segmentMatcher = SegmentMatcher(gateRadiusMeters: 40.0)
        let gpxService = GPXService()
        let privacyService = PrivacyZoneService(zones: [
            PrivacyZone(name: "Home Privacy Zone", latitude: -6.175392, longitude: 106.827153, radiusMeters: 200.0)
        ])
        
        // Setup Pacing Coach & Ghost Runner
        let pacingCoach = PacingCoachService(target: .sub25_5K, languageCode: "id-ID")
        let ghostRunner = GhostRunnerEngine(source: .customTargetPace(paceSecondsPerKm: 300.0))
        print("   🎯 Target Pacing Diatur: Sub-25m 5K (Pace Target: 5:00 /km)")
        print("   👻 Virtual Ghost Runner Aktif: Target Pace 5:00 /km")
        
        // Start Live Safety Beacon
        let beacon = LiveSafetyBeaconService.shared.startBeacon(athleteName: "Budi Santoso", activityType: .run)
        print("   🛡️ Live Safety Beacon Aktif: \(beacon.shareableURLString)")
        
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
        print("\n🔹 [2/9] Memulai perekaman latihan GPS (Start Workout)...")
        await engine.start()
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan dimulai")
        
        let startTime = Date().addingTimeInterval(-1200) // 20 menit yang lalu
        print("   Status: REC (Recording) | Aktivitas: Outdoor Run")
        print("   -----------------------------------------------------------------------------------------------------------")
        print("   STEP | DISTANCE | SPEED   | ELEV GAIN | HR      | PACING DELTA | GHOST GAP     | STATUS       | LIVE GPS")
        print("   -----------------------------------------------------------------------------------------------------------")
        
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
            let stateStr = metrics.state == .autoPaused ? "🟡 PAUSE" : "🟢 REC"
            let coordStr = String(format: "(%.4f, %.4f)", lat, baseLon)
            
            let feedback = pacingCoach.evaluate(
                distanceMeters: metrics.distanceMeters,
                elapsedTimeSeconds: metrics.elapsedTimeSeconds,
                currentPaceSecondsPerKm: metrics.currentPaceSecondsPerKm
            )
            let deltaStr = feedback?.formattedDelta ?? "--"
            
            let ghostDelta = ghostRunner.evaluate(
                athleteDistanceMeters: metrics.distanceMeters,
                athleteElapsedTimeSeconds: metrics.elapsedTimeSeconds,
                athleteCurrentPaceSecondsPerKm: metrics.currentPaceSecondsPerKm
            )
            let ghostGapStr = String(format: "%+.0fm", ghostDelta.distanceSeparationMeters)
            
            print(String(format: "   #%02d  | %-8@ | %-7@ | %-9@ | %-7@ | %-12@ | %-13@ | %-12@ | %@", i, distKm, speedKmh, elevStr, hrStr, deltaStr, ghostGapStr, stateStr, coordStr))
        }
        
        print("   -----------------------------------------------------------------------------------------------------------")
        
        // 4. Menyelesaikan Latihan (Finish Workout)
        print("\n🔹 [3/9] Menyelesaikan latihan (Finish Workout)...")
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
        
        // 5. Analisis Fisiologis TRIMP & Recovery
        print("\n🔹 [4/9] Menghitung Beban Fisiologis Latihan (Banister TRIMP & Recovery Gauge)...")
        let loadCalc = TrainingLoadCalculator(restingHeartRate: 58, maxHeartRate: 192, isMale: true)
        let trimpScore = loadCalc.calculateSessionTRIMP(durationSeconds: activity.durationSeconds, averageHeartRate: activity.averageHeartRate, rpeScore: activity.rpe)
        let trainingMetrics = loadCalc.calculateTrainingMetrics(currentSessionTrimp: trimpScore, previousATL: 42.0, previousCTL: 52.0)
        
        print("   📊 Skor TRIMP Sesi : \(trainingMetrics.formattedTrimp)")
        print("   📈 Chronic Load CTL: \(String(format: "%.1f", trainingMetrics.chronicTrainingLoad)) (Fitness)")
        print("   📉 Acute Load ATL  : \(String(format: "%.1f", trainingMetrics.acuteTrainingLoad)) (Fatigue)")
        print("   ⚡️ Training Form   : \(String(format: "%+.1f", trainingMetrics.trainingStressBalance)) (TSB)")
        print("   🛡️ Kesiapan Tubuh  : \(trainingMetrics.readiness.rawValue)")
        print("   ⏳ Waktu Istirahat : \(trainingMetrics.formattedRecoveryHours)")
        
        // 6. Running Dynamics & Biomekanika
        print("\n🔹 [5/9] Menghitung Running Dynamics & Biomekanika...")
        let dynamicsCalc = RunningDynamicsCalculator()
        let dynamics = dynamicsCalc.estimateDynamics(averageSpeedMps: activity.averageSpeedMps)
        print("   👟 Cadence SPM     : \(dynamics.formattedCadence) (\(dynamics.cadenceZone.rawValue))")
        print("   📐 Osilasi Vertikal: \(dynamics.formattedOscillation) (Rasio: \(dynamics.formattedVerticalRatio))")
        print("   ⏱️ Ground Contact  : \(dynamics.formattedGroundContact)")
        print("   📏 Panjang Langkah : \(dynamics.formattedStrideLength)")
        
        // 7. Estimasi VO2 Max & Prediksi Lomba
        print("\n🔹 [6/9] Menghitung VO2 Max & Prediksi Waktu Balapan...")
        let vo2Calc = VO2MaxCalculator(restingHeartRate: 58, maxHeartRate: 192, age: 28, isMale: true)
        let vo2Score = vo2Calc.estimateVO2Max(averageSpeedMps: activity.averageSpeedMps, averageHeartRate: activity.averageHeartRate)
        print("   🫁 Skor VO2 Max    : \(vo2Score.formattedScore) ml/kg/min (\(vo2Score.category.rawValue))")
        print("   🏆 Peringkat Usia  : Top \(100 - vo2Score.ageGroupPercentile)% Seusiamu")
        for pred in vo2Score.predictions {
            print("   🏁 Prediksi \(pred.raceDistance.rawValue): \(pred.formattedTime) (Pace: \(pred.formattedPace))")
        }
        
        // 8. 3D Aerial Flyover Keyframes
        print("\n🔹 [7/9] Menghitung Keyframe Kamera 3D Aerial Flyover...")
        let flyoverEngine = FlyoverReplayEngine()
        let coords = telemetry.map { $0.coordinate }
        let cameraFrames = flyoverEngine.generateCameraFrames(from: coords)
        let milestones = flyoverEngine.generateMilestones(from: telemetry, totalDistanceMeters: activity.distanceMeters)
        print("   🚁 Frame Kamera 3D : \(cameraFrames.count) keyframes dengan pitch 60° dan heading dinamis")
        print("   🚩 Milestones Rute : \(milestones.count) penanda rute (\(milestones.map { $0.title }.joined(separator: ", ")))")
        
        // 9. On-Device AI Workout Storyteller
        print("\n🔹 [8/9] Menghasilkan Ulasan Narasi AI Workout Storyteller...")
        let storyteller = AIWorkoutStoryteller()
        let narrative = storyteller.generateStory(
            activityTitle: activity.title,
            activityType: activity.activityType,
            distanceMeters: activity.distanceMeters,
            durationSeconds: activity.durationSeconds,
            averageSpeedMps: activity.averageSpeedMps,
            elevationGainMeters: activity.totalElevationGainMeters,
            averageHeartRate: activity.averageHeartRate,
            rpeScore: activity.rpe,
            tone: .motivatingCoach
        )
        print("   ✨ Headline        : \"\(narrative.headline)\"")
        print("   📝 Narasi AI       : \"\(narrative.storyBody)\"")
        print("   💡 Saran Pemulihan : \"\(narrative.recoveryAdvice)\"")
        
        // 10. Splits, Segmen, GPX Sanitasi & Finish
        print("\n🔹 [9/9] Memproses Analisis Splits, Segmen & Sanitasi GPX...")
        let splits = splitCalculator.calculateSplits(from: telemetry)
        for split in splits {
            print("   👉 Km \(split.splitIndex): Waktu \(split.formattedDuration) | Pace \(split.formattedPace) | Elevasi +\(String(format: "%.0f", split.elevationChangeMeters))m")
        }
        
        let efforts = segmentMatcher.matchSegments(
            activityPoints: telemetry,
            segments: [sampleSegment],
            athleteId: UUID(),
            athleteName: "Budi Santoso"
        )
        if let firstEffort = efforts.first {
            print("   🏅 Segmen Terdeteksi: \(sampleSegment.name) - Waktu \(firstEffort.formattedDuration) (\(firstEffort.isPersonalRecord ? "Rekor Baru! 🏆" : "Effort Tercatat"))")
        }
        
        _ = privacyService.sanitizeCoordinates(coords)
        let gpxXml = gpxService.exportToGPX(activity: activity, points: telemetry)
        print("   📄 File GPX 1.1 XML berhasil diekspor (\(telemetry.count) titik telemetri, \(gpxXml.count) karakter XML).")
        
        print("""
        ========================================================================
           ✅ SELURUH SUITE STRIDESYNC v3.0 BERJALAN DENGAN SEMPURNA (100%)!
        ========================================================================
        """)
    }
}
#endif
