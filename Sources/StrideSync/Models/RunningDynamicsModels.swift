import Foundation

/// Cadence classification zone based on Steps Per Minute (SPM).
public enum CadenceZone: String, Sendable, Codable {
    case optimal = "Optimal (170-185 SPM)"
    case fast = "Tinggi (> 185 SPM)"
    case moderate = "Sedang (155-169 SPM)"
    case low = "Rendah (< 155 SPM)"
    
    public static func evaluate(spm: Int) -> CadenceZone {
        if spm >= 186 { return .fast }
        if spm >= 170 { return .optimal }
        if spm >= 155 { return .moderate }
        return .low
    }
}

/// Running dynamics and biomechanics telemetry metrics.
public struct RunningDynamicsMetrics: Sendable, Codable {
    public var averageCadenceSpm: Int // Steps per minute (e.g. 174)
    public var maxCadenceSpm: Int
    public var verticalOscillationCm: Double // Bounce height in cm (e.g. 7.8 cm)
    public var groundContactTimeMs: Double // Milliseconds foot is on ground (e.g. 240 ms)
    public var strideLengthMeters: Double // Average stride distance (e.g. 1.15 m)
    public var verticalRatioPercent: Double // Oscillation / Stride Length ratio (lower is better, e.g. 6.8%)
    public var cadenceZone: CadenceZone
    
    public var formattedCadence: String {
        "\(averageCadenceSpm) SPM"
    }
    
    public var formattedOscillation: String {
        String(format: "%.1f cm", verticalOscillationCm)
    }
    
    public var formattedGroundContact: String {
        String(format: "%.0f ms", groundContactTimeMs)
    }
    
    public var formattedStrideLength: String {
        String(format: "%.2f m", strideLengthMeters)
    }
    
    public var formattedVerticalRatio: String {
        String(format: "%.1f%%", verticalRatioPercent)
    }
    
    public init(
        averageCadenceSpm: Int = 172,
        maxCadenceSpm: Int = 184,
        verticalOscillationCm: Double = 7.5,
        groundContactTimeMs: Double = 235.0,
        strideLengthMeters: Double = 1.18,
        verticalRatioPercent: Double = 6.4,
        cadenceZone: CadenceZone = .optimal
    ) {
        self.averageCadenceSpm = averageCadenceSpm
        self.maxCadenceSpm = maxCadenceSpm
        self.verticalOscillationCm = verticalOscillationCm
        self.groundContactTimeMs = groundContactTimeMs
        self.strideLengthMeters = strideLengthMeters
        self.verticalRatioPercent = verticalRatioPercent
        self.cadenceZone = cadenceZone
    }
}

