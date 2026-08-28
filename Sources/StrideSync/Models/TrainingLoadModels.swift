import Foundation
import SwiftUI

/// Qualitative readiness status of an athlete's physiological recovery.
public enum RecoveryReadiness: String, Codable, Sendable {
    case fresh = "Sangat Segar"
    case optimal = "Optimal & Produktif"
    case maintain = "Fase Pemeliharaan"
    case overreaching = "Beban Berlebih (Overreaching)"
    case fatigued = "Kelelahan Ekstrem (Fatigued)"
    
    public var color: Color {
        switch self {
        case .fresh: return Color.blue
        case .optimal: return StrideTheme.athleticGreen
        case .maintain: return Color.yellow
        case .overreaching: return StrideTheme.primaryOrange
        case .fatigued: return Color.red
        }
    }
    
    public var iconName: String {
        switch self {
        case .fresh: return "bolt.shield.fill"
        case .optimal: return "checkmark.seal.fill"
        case .maintain: return "gauge.medium"
        case .overreaching: return "flame.fill"
        case .fatigued: return "battery.25percent"
        }
    }
    
    public var adviceDescription: String {
        switch self {
        case .fresh:
            return "Tubuh Anda dalam kondisi puncak dan siap untuk tantangan latihan intensif atau perlombaan."
        case .optimal:
            return "Keseimbangan latihan dan pemulihan sangat baik. Pertahankan jadwal latihan rutin."
        case .maintain:
            return "Beban latihan stabil. Cocok untuk sesi lari aerobik Zona 2 atau pemulihan aktif."
        case .overreaching:
            return "Beban latihan akumulatif cukup tinggi. Disarankan latihan ringan atau istirahat terencana."
        case .fatigued:
            return "Tingkat kelelahan kritis. Prioritaskan tidur berkualitas dan istirahat penuh hari ini."
        }
    }
}

/// Comprehensive physiological load metrics derived from Banister TRIMP model and Acute/Chronic load ratios.
public struct TrainingLoadMetrics: Sendable, Equatable {
    public let sessionTrimpScore: Double
    public let acuteTrainingLoad: Double // ATL (7-day Fatigue)
    public let chronicTrainingLoad: Double // CTL (28-day Fitness)
    public let trainingStressBalance: Double // TSB (Form = CTL - ATL)
    public let recoveryHoursRemaining: Double
    public let readiness: RecoveryReadiness
    
    public init(
        sessionTrimpScore: Double,
        acuteTrainingLoad: Double,
        chronicTrainingLoad: Double,
        trainingStressBalance: Double,
        recoveryHoursRemaining: Double,
        readiness: RecoveryReadiness
    ) {
        self.sessionTrimpScore = sessionTrimpScore
        self.acuteTrainingLoad = acuteTrainingLoad
        self.chronicTrainingLoad = chronicTrainingLoad
        self.trainingStressBalance = trainingStressBalance
        self.recoveryHoursRemaining = recoveryHoursRemaining
        self.readiness = readiness
    }
    
    public var formattedTrimp: String {
        String(format: "%.0f", sessionTrimpScore)
    }
    
    public var formattedRecoveryHours: String {
        if recoveryHoursRemaining <= 0 {
            return "Pulih Penuh"
        } else {
            return String(format: "%.0fj istirahat", recoveryHoursRemaining)
        }
    }
}

