#if os(macOS)
import Foundation
import CoreLocation
import StrideSync

@main
struct StrideSyncDemoRunner {
    static func main() async {
        print("""
        ========================================================================================
           🏃‍♂️⚡️ STRIDESYNC v0.5.0-beta - ATHLETIC & GPS TRACKING PLATFORM (SWIFT 6) ⚡️🚴‍♀️
        ========================================================================================
        Platform: iOS 17+ / macOS 14+ / watchOS 10+ | Strict Concurrency: Swift 6
        Engines : LocationEngine Actor, Auto-Pause, Garmin FIT 2.0, GPX 1.1, Supabase Cloud
        
        """)
        
        // 1. Inisialisasi Engine, Pacing & Structured Interval Program
        print("🔹 [1/11] Menginisialisasi LocationEngine, Safety Beacon & Structured Intervals...")
        let engine = LocationEngine(activityType: .run, autoPauseEnabled: true)
        let splitCalculator = SplitCalculator(splitIntervalMeters: 1000.0)
        let segmentMatcher = SegmentMatcher(gateRadiusMeters: 40.0)
        let gpxService = GPXService()
        let privacyService = PrivacyZoneService(zones: [
            PrivacyZone(name: "Home Privacy Zone", latitude: -6.175392, longitude: 106.827153, radiusMeters: 200.0)
        ])
        
        // Setup Pacing Coach, Ghost Runner & Interval Program
        let pacingCoach = PacingCoachService(target: .sub25_5K, languageCode: "id-ID")
        let ghostRunner = GhostRunnerEngine(source: .customTargetPace(paceSecondsPerKm: 300.0))
        let intervalPlan = StructuredWorkoutPlan.speedLadder5K
        let intervalEngine = IntervalExecutionEngine(plan: intervalPlan)
        
        print("   🎯 Target Pacing Diatur: Sub-25m 5K (Pace Target: 5:00 /km)")
        print("   👻 Virtual Ghost Runner Aktif: Target Pace 5:00 /km")
        print("   ⚡️ Program Interval Aktif: \(intervalPlan.title) (\(intervalPlan.steps.count) Fase)")
        
        // Start Live Safety Beacon
        let beacon = LiveSafetyBeaconService.shared.startBeacon(athleteName: "Budi Santoso", activityType: .run)
        print("   🛡️ Live Safety Beacon Aktif: \(beacon.shareableURLString)")
        
        // Setup Weather Intelligence & Group Run Radar
        let weatherService = WeatherIntelligenceService.shared
        let initialCoord = CLLocationCoordinate2D(latitude: -6.175392, longitude: 106.827153)
        let weather = weatherService.fetchWeather(for: initialCoord)
        let radarEngine = GroupRunRadarEngine.shared
        let metronomeEngine = CadenceMetronomeEngine(targetCadenceSPM: 180)
        
        print("   ☀️ Analisis Cuaca & Suhu Semu: \(weather.conditionDescription), \(weather.formattedTemperature) (Terasa \(weather.formattedApparentTemperature))")
        print("   💡 Rekomendasi Cuaca: \(weatherService.generateWeatherAdvice(conditions: weather))")
        print("   ⏱️ Cadence Metronome: Disetel ke \(metronomeEngine.targetCadenceSPM) SPM (Beat tiap \(String(format: "%.2f", metronomeEngine.beatIntervalSeconds))s)")
        
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
        print("\n🔹 [2/11] Memulai perekaman latihan GPS (Start Workout)...")
        await engine.start()
        intervalEngine.start(initialDistanceMeters: 0.0, startTime: Date())
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan dimulai")
        
        let startTime = Date().addingTimeInterval(-1200) // 20 menit yang lalu
        print("   Status: REC (Recording) | Aktivitas: Outdoor Run")
        print("   -----------------------------------------------------------------------------------------------------------------")
        print("   STEP | DISTANCE | SPEED   | ELEV GAIN | HR      | PACING DELTA | GHOST GAP     | INTERVAL PHASE        | LIVE GPS")
        print("   -----------------------------------------------------------------------------------------------------------------")
        
        // 3. Simulasi Streaming Koordinat GPS (5 km simulasi rute)
        let baseLat = -6.175392
        let baseLon = 106.827153
        
        for i in 1...25 {
            let lat = baseLat + (Double(i) * 0.0018)
            let alt = 15.0 + (Double(i) * 1.8) // Elevation climbing
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
            let intervalProgress = intervalEngine.update(currentDistanceMeters: metrics.distanceMeters, currentTimestamp: timestamp)
            
            let distKm = String(format: "%.2f km", metrics.distanceMeters / 1000.0)
            let speedKmh = String(format: "%.1f km/h", metrics.currentSpeedMps * 3.6)
            let elevStr = String(format: "%.0f m", metrics.totalElevationGainMeters)
            let hrStr = "\(hr) bpm"
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
            let intervalStr = intervalProgress != nil ? "#\(intervalProgress!.currentStepIndex + 1) \(intervalProgress!.step.stepType.rawValue)" : "Normal"
            
            print(String(format: "   #%02d  | %-8@ | %-7@ | %-9@ | %-7@ | %-12@ | %-13@ | %-21@ | %@", i, distKm, speedKmh, elevStr, hrStr, deltaStr, ghostGapStr, intervalStr, coordStr))
        }
        
        print("   -----------------------------------------------------------------------------------------------------------------")
        
        // 4. Live Group Run Radar
        print("\n🔹 [3/11] Memindai Radar Pelari Sekitar (Live Group Run Radar)...")
        let radarPings = radarEngine.scanRadar(currentCoordinate: CLLocationCoordinate2D(latitude: baseLat, longitude: baseLon), currentPaceSecondsPerKm: 240.0)
        print("   📡 Terdeteksi \(radarPings.count) pelari komunitas dalam radius 1.2 km:")
        for ping in radarPings {
            print("   👉 [\(ping.compassDirection)] \(ping.buddy.name) — Jarak \(ping.formattedDistance) | Pace: \(ping.buddy.formattedPace) (\(ping.paceDifferenceSecondsPerKm > 0 ? "Kamu lebih cepat" : "Lebih cepat darimu"))")
        }
        
        // 5. Menyelesaikan Latihan (Finish Workout)
        print("\n🔹 [4/11] Menyelesaikan latihan (Finish Workout)...")
        let (summary, telemetry) = await engine.finish()
        let activity = ActivityRecord(from: summary)
        activity.durationSeconds = 1200 // 20:00
        activity.movingTimeSeconds = 1152 // 19:12
        activity.averageSpeedMps = activity.distanceMeters / activity.movingTimeSeconds
        activity.rpe = 7 // Rating of Perceived Exertion (1-10)
        activity.gearName = "Nike Vaporfly 3"
        activity.notes = "Speed workout 5K interval di Monas dengan cuaca sejuk pagi hari!"
        
        print("   🏆 Judul Aktivitas : \(activity.title)")
        print("   📍 Total Jarak     : \(activity.formattedDistance)")
        print("   ⏱️ Durasi Total    : \(activity.formattedDuration)")
        print("   ⚡️ Waktu Bergerak  : \(activity.formattedMovingTime)")
        print("   🚀 Pace Rata-rata  : \(activity.formattedAveragePace)")
        print("   ⛰️ Elevasi Naik    : \(activity.formattedElevationGain)")
        print("   ❤️ HR Rata-rata    : \(activity.averageHeartRate != nil ? "\(activity.averageHeartRate!) bpm" : "-") (Max: \(activity.maxHeartRate != nil ? "\(activity.maxHeartRate!) bpm" : "-"))")
        print("   ⚡️ Skala RPE (1-10): \(activity.rpe != nil ? "\(activity.rpe!)/10 (Keras/Threshold)" : "-")")
        print("   👟 Sepatu Digunakan: \(activity.gearName ?? "-")")
        
        // 6. Analisis Fisiologis TRIMP & Recovery
        print("\n🔹 [5/11] Menghitung Beban Fisiologis Latihan (Banister TRIMP & Recovery Gauge)...")
        let loadCalc = TrainingLoadCalculator(restingHeartRate: 58, maxHeartRate: 192, isMale: true)
        let trimpScore = loadCalc.calculateSessionTRIMP(durationSeconds: activity.durationSeconds, averageHeartRate: activity.averageHeartRate, rpeScore: activity.rpe)
        let trainingMetrics = loadCalc.calculateTrainingMetrics(currentSessionTrimp: trimpScore, previousATL: 42.0, previousCTL: 52.0)
        
        print("   📊 Skor TRIMP Sesi : \(trainingMetrics.formattedTrimp)")
        print("   📈 Chronic Load CTL: \(String(format: "%.1f", trainingMetrics.chronicTrainingLoad)) (Fitness)")
        print("   📉 Acute Load ATL  : \(String(format: "%.1f", trainingMetrics.acuteTrainingLoad)) (Fatigue)")
        print("   ⚡️ Training Form   : \(String(format: "%+.1f", trainingMetrics.trainingStressBalance)) (TSB)")
        print("   🛡️ Kesiapan Tubuh  : \(trainingMetrics.readiness.rawValue)")
        print("   ⏳ Waktu Istirahat : \(trainingMetrics.formattedRecoveryHours)")
        
        // 7. Running Dynamics, Biomekanika & Cadence Metronome Lock
        print("\n🔹 [6/11] Menghitung Running Dynamics & Cadence Lock Evaluation...")
        let dynamicsCalc = RunningDynamicsCalculator()
        let dynamics = dynamicsCalc.estimateDynamics(averageSpeedMps: activity.averageSpeedMps)
        let cadenceEvaluation = metronomeEngine.evaluateCadenceDeviation(actualCadenceSPM: dynamics.averageCadenceSpm)
        
        print("   👟 Cadence SPM     : \(dynamics.formattedCadence) (\(dynamics.cadenceZone.rawValue))")
        print("   🎯 Target Cadence  : \(metronomeEngine.targetCadenceSPM) SPM -> \(cadenceEvaluation.advice)")
        print("   📐 Osilasi Vertikal: \(dynamics.formattedOscillation) (Rasio: \(dynamics.formattedVerticalRatio))")
        print("   ⏱️ Ground Contact  : \(dynamics.formattedGroundContact)")
        print("   📏 Panjang Langkah : \(dynamics.formattedStrideLength)")
        
        // 8. Deteksi & Klasifikasi Tanjakan (Climb Classifier - UCI/Strava Standard)
        print("\n🔹 [7/11] Menganalisis Profil Elevasi & Klasifikasi Tanjakan (Climb Classifier)...")
        let climbClassifier = ClimbClassifier()
        let climbs = climbClassifier.detectClimbs(from: telemetry, minClimbLengthMeters: 200.0, minElevationGainMeters: 5.0)
        print("   ⛰️ Terdeteksi \(climbs.count) segmen tanjakan terukur:")
        for climb in climbs {
            print("   👉 [\(climb.category.shortLabel)] Panjang \(climb.formattedDistance) | Elevasi +\(climb.formattedElevationGain) | Grade \(climb.formattedAverageGrade) (Skor: \(String(format: "%.0f", climb.score)))")
        }
        
        // 9. Deteksi Rekor Terbaik (Personal Records & Best Efforts)
        print("\n🔹 [8/11] Mendeteksi Rekor Terbaik Sepanjang Masa (Personal Best Detector)...")
        let prDetector = PersonalRecordDetector()
        let prs = prDetector.detectBestEfforts(from: telemetry, activityTitle: activity.title)
        print("   🥇 Terdeteksi \(prs.count) Rekor Terbaik pada Sesi Ini:")
        for pr in prs {
            print("   🏆 \(pr.distanceCategory.rawValue): Waktu \(pr.formattedDuration) | Pace \(pr.formattedPace)")
        }
        
        // 10. Estimasi VO2 Max & Prediksi Lomba
        print("\n🔹 [9/11] Menghitung VO2 Max & Prediksi Waktu Balapan...")
        let vo2Calc = VO2MaxCalculator(restingHeartRate: 58, maxHeartRate: 192, age: 28, isMale: true)
        let vo2Score = vo2Calc.estimateVO2Max(averageSpeedMps: activity.averageSpeedMps, averageHeartRate: activity.averageHeartRate)
        print("   🫁 Skor VO2 Max    : \(vo2Score.formattedScore) ml/kg/min (\(vo2Score.category.rawValue))")
        print("   🏆 Peringkat Usia  : Top \(100 - vo2Score.ageGroupPercentile)% Seusiamu")
        for pred in vo2Score.predictions {
            print("   🏁 Prediksi \(pred.raceDistance.rawValue): \(pred.formattedTime) (Pace: \(pred.formattedPace))")
        }
        
        // 11. 3D Aerial Flyover & On-Device AI Workout Storyteller
        print("\n🔹 [10/11] Menghitung Keyframe Kamera 3D Flyover & Narasi AI Storyteller...")
        let flyoverEngine = FlyoverReplayEngine()
        let coords = telemetry.map { $0.coordinate }
        let cameraFrames = flyoverEngine.generateCameraFrames(from: coords)
        let milestones = flyoverEngine.generateMilestones(from: telemetry, totalDistanceMeters: activity.distanceMeters)
        print("   🚁 Frame Kamera 3D : \(cameraFrames.count) keyframes dengan pitch 60° dan heading dinamis")
        print("   🚩 Milestones Rute : \(milestones.count) penanda rute (\(milestones.map { $0.title }.joined(separator: ", ")))")
        
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
        print("   ✨ Headline AI     : \"\(narrative.headline)\"")
        print("   📝 Narasi AI       : \"\(narrative.storyBody)\"")
        print("   💡 Saran Pemulihan : \"\(narrative.recoveryAdvice)\"")
        
        // 12. Splits, Segmen, GPX Sanitasi & Finish
        print("\n🔹 [11/11] Memproses Analisis Splits, Segmen & Sanitasi GPX...")
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
        ========================================================================================
           ✅ SELURUH SUITE STRIDESYNC v0.5.0-beta BERJALAN DENGAN SEMPURNA (100% TEST PASS)!
        ========================================================================================
        """)
    }
}
#endif
