import Foundation

/// Calculator estimating biomechanical running dynamics from velocity, cadence, and device motion.
public struct RunningDynamicsCalculator: Sendable {
    public init() {}
    
    /// Estimates biomechanics metrics from average speed and user stride characteristics.
    public func estimateDynamics(
        averageSpeedMps: Double,
        measuredCadenceSpm: Int? = nil
    ) -> RunningDynamicsMetrics {
        let speed = max(1.0, averageSpeedMps)
        
        // 1. Cadence (Steps per Minute)
        let cadence: Int
        if let measured = measuredCadenceSpm, measured > 80 {
            cadence = measured
        } else {
            // Speed-derived Cadence model: Cadence increases logarithmically with speed
            let estimated = 152.0 + (speed * 6.5)
            cadence = max(140, min(205, Int(estimated)))
        }
        
        // 2. Stride Length (meters)
        // Stride Length = (Speed * 60) / Cadence
        let strideLength = (speed * 60.0) / Double(cadence)
        
        // 3. Vertical Oscillation (cm)
        // Bounce height typically 6.0cm to 10.5cm for efficient runners
        let rawOscillation = 5.2 + (strideLength * 2.1)
        let verticalOscillation = max(5.0, min(12.0, (rawOscillation * 10.0).rounded() / 10.0))
        
        // 4. Ground Contact Time (milliseconds)
        // Elite runners spend less time on ground (190-220ms), recreational (240-290ms)
        let rawGCT = 325.0 - (speed * 21.0)
        let groundContactTime = max(175.0, min(330.0, (rawGCT).rounded()))
        
        // 5. Vertical Ratio (%)
        // Ratio = (Vertical Oscillation cm / (Stride Length m * 100)) * 100
        let strideLengthCm = strideLength * 100.0
        let verticalRatio = (verticalOscillation / strideLengthCm) * 100.0
        
        let zone = CadenceZone.evaluate(spm: cadence)
        
        return RunningDynamicsMetrics(
            averageCadenceSpm: cadence,
            maxCadenceSpm: cadence + 12,
            verticalOscillationCm: verticalOscillation,
            groundContactTimeMs: groundContactTime,
            strideLengthMeters: (strideLength * 100.0).rounded() / 100.0,
            verticalRatioPercent: (verticalRatio * 10.0).rounded() / 10.0,
            cadenceZone: zone
        )
    }
}

