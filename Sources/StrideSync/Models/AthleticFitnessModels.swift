import Foundation

/// Standard running race distances for time projections.
public enum RaceDistance: String, Sendable, Codable, CaseIterable, Identifiable {
    case fiveK = "5K"
    case tenK = "10K"
    case halfMarathon = "Half Marathon (21.1 km)"
    case fullMarathon = "Marathon (42.2 km)"
    
    public var id: String { rawValue }
    
    public var distanceMeters: Double {
        switch self {
        case .fiveK: return 5000.0
        case .tenK: return 10000.0
        case .halfMarathon: return 21097.5
        case .fullMarathon: return 42195.0
        }
    }
}

/// Fitness category classification according to Cooper Institute standards.
public enum FitnessCategory: String, Sendable, Codable {
    case superior = "Superior 🏆"
    case excellent = "Sangat Baik ⚡️"
    case good = "Baik 👍"
    case fair = "Cukup 📈"
    case needsWork = "Perlu Latihan 🛠️"
    
    public var adviceDescription: String {
        switch self {
        case .superior:
            return "Kapasitas aerobik di level atlet elit. Pertahankan efisiensi lari dan variasi interval tempo."
        case .excellent:
            return "Kebugaran kardiovaskular sangat prima. Potensi tinggi untuk memecahkan rekor waktu balapan."
        case .good:
            return "Kondisi fisik di atas rata-rata populasi. Latihan aerobik zona 2 teratur akan meningkatkannya."
        case .fair:
            return "Kebugaran cukup baik untuk olahraga rutin. Tingkatkan volume lari santai mingguan."
        case .needsWork:
            return "Fokus pada konsistensi lari santai dan jalan interval untuk membangun fondasi aerobik."
        }
    }
}

/// A projected finish time for a specific race distance.
public struct RacePrediction: Identifiable, Sendable, Codable {
    public var id: UUID
    public var raceDistance: RaceDistance
    public var estimatedTimeSeconds: TimeInterval
    public var estimatedPaceSecondsPerKm: TimeInterval
    
    public var formattedTime: String {
        let total = Int(estimatedTimeSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    public var formattedPace: String {
        let pace = Int(estimatedPaceSecondsPerKm)
        let min = pace / 60
        let sec = pace % 60
        return String(format: "%d:%02d /km", min, sec)
    }
    
    public init(
        id: UUID = UUID(),
        raceDistance: RaceDistance,
        estimatedTimeSeconds: TimeInterval,
        estimatedPaceSecondsPerKm: TimeInterval
    ) {
        self.id = id
        self.raceDistance = raceDistance
        self.estimatedTimeSeconds = estimatedTimeSeconds
        self.estimatedPaceSecondsPerKm = estimatedPaceSecondsPerKm
    }
}

/// Aerobic fitness capacity score (VO2 Max) and associated metrics.
public struct VO2MaxScore: Sendable, Codable {
    public var score: Double // ml/kg/min (e.g. 52.4)
    public var category: FitnessCategory
    public var ageGroupPercentile: Int // e.g. Top 15%
    public var predictions: [RacePrediction]
    public var calculatedAt: Date
    
    public var formattedScore: String {
        String(format: "%.1f", score)
    }
    
    public init(
        score: Double,
        category: FitnessCategory,
        ageGroupPercentile: Int,
        predictions: [RacePrediction],
        calculatedAt: Date = Date()
    ) {
        self.score = score
        self.category = category
        self.ageGroupPercentile = ageGroupPercentile
        self.predictions = predictions
        self.calculatedAt = calculatedAt
    }
}
