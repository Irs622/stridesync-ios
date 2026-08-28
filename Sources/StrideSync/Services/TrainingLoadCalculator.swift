import Foundation

/// Physiological Training Load & Banister TRIMP Calculator.
public struct TrainingLoadCalculator: Sendable {
    public let restingHeartRate: Int
    public let maxHeartRate: Int
    public let isMale: Bool
    
    public init(
        restingHeartRate: Int = 60,
        maxHeartRate: Int = 190,
        isMale: Bool = true
    ) {
        self.restingHeartRate = restingHeartRate
        self.maxHeartRate = maxHeartRate
        self.isMale = isMale
    }
    
    /// Calculates session TRIMP score from duration and average heart rate (or RPE fallback).
    public func calculateSessionTRIMP(
        durationSeconds: TimeInterval,
        averageHeartRate: Int?,
        rpeScore: Int? = nil
    ) -> Double {
        let durationMinutes = durationSeconds / 60.0
        guard durationMinutes > 0 else { return 0.0 }
        
        if let hr = averageHeartRate, hr > restingHeartRate {
            let hrReserve = Double(maxHeartRate - restingHeartRate)
            guard hrReserve > 0 else { return durationMinutes }
            
            let hrRatio = min(1.0, max(0.0, Double(hr - restingHeartRate) / hrReserve))
            let bExponent = isMale ? 1.92 : 1.67
            let bMultiplier = isMale ? 0.64 : 0.86
            
            let trimp = durationMinutes * hrRatio * bMultiplier * exp(bExponent * hrRatio)
            return max(0.0, trimp)
        } else {
            // Foster Session-RPE Fallback: RPE (1-10) * Duration (mins) * Scaling Factor
            let rpe = Double(rpeScore ?? 5)
            let trimp = durationMinutes * (rpe / 10.0) * 1.5
            return max(0.0, trimp)
        }
    }
    
    /// Calculates comprehensive training metrics and recovery hours from historical and current session TRIMP.
    public func calculateTrainingMetrics(
        currentSessionTrimp: Double,
        previousATL: Double = 45.0, // Historical 7-day baseline
        previousCTL: Double = 50.0  // Historical 28-day baseline
    ) -> TrainingLoadMetrics {
        // Exponential moving average updates
        let atlAlpha = 2.0 / (7.0 + 1.0)
        let ctlAlpha = 2.0 / (28.0 + 1.0)
        
        let newATL = previousATL * (1.0 - atlAlpha) + currentSessionTrimp * atlAlpha
        let newCTL = previousCTL * (1.0 - ctlAlpha) + currentSessionTrimp * ctlAlpha
        let tsb = newCTL - newATL // Training Stress Balance (Form)
        
        // Calculate recovery hours based on session TRIMP intensity
        let recoveryHours: Double
        if currentSessionTrimp > 180 {
            recoveryHours = 48.0
        } else if currentSessionTrimp > 120 {
            recoveryHours = 36.0
        } else if currentSessionTrimp > 70 {
            recoveryHours = 24.0
        } else if currentSessionTrimp > 30 {
            recoveryHours = 12.0
        } else {
            recoveryHours = 0.0
        }
        
        // Readiness classification
        let readiness: RecoveryReadiness
        if tsb > 15 {
            readiness = .fresh
        } else if tsb >= -5 && tsb <= 15 {
            readiness = .optimal
        } else if tsb >= -15 && tsb < -5 {
            readiness = .maintain
        } else if tsb >= -30 && tsb < -15 {
            readiness = .overreaching
        } else {
            readiness = .fatigued
        }
        
        return TrainingLoadMetrics(
            sessionTrimpScore: currentSessionTrimp,
            acuteTrainingLoad: newATL,
            chronicTrainingLoad: newCTL,
            trainingStressBalance: tsb,
            recoveryHoursRemaining: recoveryHours,
            readiness: readiness
        )
    }
}

