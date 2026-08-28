import Foundation

/// Calculator estimating aerobic capacity (VO2 Max) and projecting race finish times (5K, 10K, 21K, 42K).
public struct VO2MaxCalculator: Sendable {
    public let restingHeartRate: Int
    public let maxHeartRate: Int
    public let age: Int
    public let isMale: Bool
    
    public init(
        restingHeartRate: Int = 58,
        maxHeartRate: Int = 190,
        age: Int = 28,
        isMale: Bool = true
    ) {
        self.restingHeartRate = max(35, min(100, restingHeartRate))
        self.maxHeartRate = max(130, min(220, maxHeartRate))
        self.age = max(16, min(90, age))
        self.isMale = isMale
    }
    
    /// Calculates VO2 Max score and race finish time projections from workout telemetry.
    public func estimateVO2Max(
        averageSpeedMps: Double,
        averageHeartRate: Int?
    ) -> VO2MaxScore {
        let hrAvg = averageHeartRate ?? Int(Double(maxHeartRate) * 0.75)
        
        // 1. Ratio-based Baseline VO2 Max (Uth-Sørensen Formula)
        let hrRatio = Double(maxHeartRate) / Double(restingHeartRate)
        let baselineVO2 = 15.3 * hrRatio
        
        // 2. Velocity Efficiency Factor
        let hrFraction = max(0.5, min(0.98, Double(hrAvg) / Double(maxHeartRate)))
        let speedKmh = max(5.0, averageSpeedMps * 3.6)
        let speedEfficiencyVO2 = (speedKmh / hrFraction) * 3.6
        
        // Blended VO2 Max score
        var estimatedVO2 = (baselineVO2 * 0.4) + (speedEfficiencyVO2 * 0.6)
        if !isMale {
            estimatedVO2 *= 0.92 // Female physiological norm adjustment
        }
        
        // Clamp to realistic athletic bounds [28.0, 82.0]
        let finalScore = max(28.0, min(82.0, estimatedVO2))
        
        // 3. Category & Percentile
        let category = classifyFitness(score: finalScore, age: age, isMale: isMale)
        let percentile = calculatePercentile(score: finalScore, isMale: isMale)
        
        // 4. Race Predictions (Riegel's Power Law)
        let predictions = generateRacePredictions(vo2Max: finalScore)
        
        return VO2MaxScore(
            score: (finalScore * 10.0).rounded() / 10.0,
            category: category,
            ageGroupPercentile: percentile,
            predictions: predictions,
            calculatedAt: Date()
        )
    }
    
    /// Generates projected race times for standard distances using Riegel's endurance formula.
    public func generateRacePredictions(vo2Max: Double) -> [RacePrediction] {
        // Base 5K velocity estimate (m/s) derived from VO2 Max
        // VO2 (ml/kg/min) ≈ 3.5 * v (km/h) => v (m/s) ≈ (VO2 / 3.5) / 3.6 * 0.92
        let estimated5kVelocityMps = max(2.5, min(6.5, (vo2Max / 3.5) / 3.6 * 0.90))
        let base5KTime = 5000.0 / estimated5kVelocityMps
        
        var predictions: [RacePrediction] = []
        
        for distance in RaceDistance.allCases {
            // Riegel formula: T2 = T1 * (D2 / D1)^1.06
            let distanceRatio = distance.distanceMeters / 5000.0
            let projectedTime = base5KTime * pow(distanceRatio, 1.06)
            let projectedPace = projectedTime / (distance.distanceMeters / 1000.0)
            
            predictions.append(RacePrediction(
                raceDistance: distance,
                estimatedTimeSeconds: projectedTime,
                estimatedPaceSecondsPerKm: projectedPace
            ))
        }
        
        return predictions
    }
    
    private func classifyFitness(score: Double, age: Int, isMale: Bool) -> FitnessCategory {
        let thresholdOffset = Double(max(0, age - 25)) * 0.35
        let maleSuperior = 56.0 - thresholdOffset
        let maleExcellent = 48.0 - thresholdOffset
        let maleGood = 42.0 - thresholdOffset
        let maleFair = 35.0 - thresholdOffset
        
        let multiplier = isMale ? 1.0 : 0.88
        
        if score >= maleSuperior * multiplier { return .superior }
        if score >= maleExcellent * multiplier { return .excellent }
        if score >= maleGood * multiplier { return .good }
        if score >= maleFair * multiplier { return .fair }
        return .needsWork
    }
    
    private func calculatePercentile(score: Double, isMale: Bool) -> Int {
        let base = isMale ? 45.0 : 38.0
        let delta = score - base
        let percentile = 50 + Int(delta * 2.8)
        return max(5, min(99, percentile))
    }
}

