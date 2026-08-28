import Foundation

/// On-Device intelligent engine generating engaging, context-aware athletic narratives and recap stories.
public final class AIWorkoutStoryteller: Sendable {
    public init() {}
    
    /// Generates a complete workout narrative based on telemetry metrics and selected tone.
    public func generateStory(
        activityTitle: String,
        activityType: ActivityType,
        distanceMeters: Double,
        durationSeconds: TimeInterval,
        averageSpeedMps: Double,
        elevationGainMeters: Double,
        averageHeartRate: Int?,
        rpeScore: Int?,
        tone: AIStoryTone = .motivatingCoach
    ) -> WorkoutNarrative {
        let distKm = distanceMeters / 1000.0
        let paceSecondsPerKm = averageSpeedMps > 0.1 ? (1000.0 / averageSpeedMps) : 360.0
        let paceMin = Int(paceSecondsPerKm) / 60
        let paceSec = Int(paceSecondsPerKm) % 60
        let paceStr = String(format: "%d:%02d /km", paceMin, paceSec)
        
        let headline: String
        let storyBody: String
        var highlights: [String] = []
        let advice: String
        
        // 1. Highlights compilation
        highlights.append("📍 Total Jarak: \(String(format: "%.2f km", distKm)) dengan pace rata-rata \(paceStr).")
        if elevationGainMeters > 20.0 {
            highlights.append("⛰️ Berhasil menaklukkan elevasi tanjakan +\(String(format: "%.0f", elevationGainMeters)) meter.")
        }
        if let hr = averageHeartRate {
            highlights.append("❤️ Detak jantung rata-rata terkontrol di \(hr) bpm.")
        }
        if let rpe = rpeScore {
            highlights.append("⚡️ Skala usaha (RPE): \(rpe)/10.")
        }
        
        // 2. Persona-based Story Generation
        switch tone {
        case .motivatingCoach:
            headline = "Kerja Luar Biasa! Konsistensi yang Mengesankan 🔥"
            storyBody = "Kamu baru saja menyelesaikan sesi \(activityType.rawValue.lowercased()) sejauh \(String(format: "%.2f km", distKm)) dengan performa yang sangat disiplin! Mempertahankan pace \(paceStr) di tengah rute dengan total elevasi +\(String(format: "%.0f", elevationGainMeters))m membuktikan ketahanan aerobikmu semakin tajam. Terus jaga momentum ini!"
            advice = "Lakukan pendinginan ringan dan rehidrasi 500ml air elektrolit. Tubuhmu siap berkembang lebih kuat."
            
        case .tacticalAnalyst:
            headline = "Laporan Analisis Efisiensi & Telemetri 📊"
            storyBody = "Sesi latihan menunjukkan stabilitas ritme yang solid. Kecepatan rata-rata mencapai \(String(format: "%.1f km/h", averageSpeedMps * 3.6)) dengan gradien elevasi +\(String(format: "%.0f", elevationGainMeters))m. Rasio output daya terhadap detak jantung rata-rata (\(averageHeartRate ?? 150) bpm) berada dalam zona ambang laktat yang sangat efisien."
            advice = "Disarankan istirahat aktif selama 14-18 jam sebelum sesi interval kecepatan berikutnya."
            
        case .relaxedCasual:
            headline = "Sesi Segar yang Sangat Menyenangkan ☕️"
            storyBody = "Lari santai sejauh \(String(format: "%.2f km", distKm)) yang sangat menyegarkan pikiran! Pace santai \(paceStr) adalah cara terbaik untuk melancarkan sirkulasi darah tanpa membebani persendian. Hari yang sempurna untuk bergerak aktif!"
            advice = "Nikmati sarapan bergizi dan kopi favoritmu hari ini. Kamu layak mendapatkannya!"
            
        case .championHeroic:
            headline = "Dominasi Penuh di Setiap Kilometer! 🏆"
            storyBody = "Sebuah pertunjukan daya tahan seorang juara! Kamu melibas rute sejauh \(String(format: "%.2f km", distKm)) tanpa ragu, menaklukkan tanjakan setinggi +\(String(format: "%.0f", elevationGainMeters))m, dan mengunci ritme tercepat di \(paceStr). Kamu terus melampaui batas kemampuanmu!"
            advice = "Prioritaskan tidur berkualitas 8 jam malam ini untuk pemulihan glikogen dan otot secara maksimal."
        }
        
        return WorkoutNarrative(
            headline: headline,
            storyBody: storyBody,
            keyHighlights: highlights,
            recoveryAdvice: advice,
            tone: tone,
            generatedAt: Date()
        )
    }
}

