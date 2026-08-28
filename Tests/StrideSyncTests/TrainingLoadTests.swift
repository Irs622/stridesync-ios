import Testing
import Foundation
@testable import StrideSync

@Suite("Training Load & Physiological Recovery Tests")
struct TrainingLoadTests {
    
    @Test("Test Banister TRIMP calculation from heart rate")
    func testBanisterTRIMP() {
        let calc = TrainingLoadCalculator(restingHeartRate: 60, maxHeartRate: 190, isMale: true)
        
        // 60 minutes workout with average HR 150 bpm (70% HRR)
        let trimp = calc.calculateSessionTRIMP(durationSeconds: 3600.0, averageHeartRate: 150)
        #expect(trimp > 50.0)
        #expect(trimp < 150.0)
    }
    
    @Test("Test Foster Session-RPE fallback when no HR available")
    func testFosterRPEFallback() {
        let calc = TrainingLoadCalculator()
        
        // 40 minutes workout with RPE 8/10
        let trimp = calc.calculateSessionTRIMP(durationSeconds: 2400.0, averageHeartRate: nil, rpeScore: 8)
        #expect(trimp == 40.0 * 0.8 * 1.5) // 48.0
    }
    
    @Test("Test Training Load metrics and recovery hours calculation")
    func testTrainingLoadMetrics() {
        let calc = TrainingLoadCalculator()
        
        // Hard workout TRIMP 140
        let metrics = calc.calculateTrainingMetrics(currentSessionTrimp: 140.0, previousATL: 40.0, previousCTL: 50.0)
        
        #expect(metrics.sessionTrimpScore == 140.0)
        #expect(metrics.acuteTrainingLoad > 40.0) // ATL increases
        #expect(metrics.recoveryHoursRemaining == 36.0)
        #expect(metrics.formattedTrimp == "140")
    }
}

