import Testing
@testable import StrideSync

@Suite("Running Dynamics Biomechanics Tests")
struct RunningDynamicsTests {
    
    @Test("Test Running Dynamics Estimation from Running Velocity")
    func testDynamicsEstimation() {
        let calc = RunningDynamicsCalculator()
        
        // Speed: 3.5 m/s (~12.6 km/h)
        let metrics = calc.estimateDynamics(averageSpeedMps: 3.5)
        
        #expect(metrics.averageCadenceSpm >= 160 && metrics.averageCadenceSpm <= 190)
        #expect(metrics.strideLengthMeters >= 0.9 && metrics.strideLengthMeters <= 1.5)
        #expect(metrics.verticalOscillationCm >= 5.0 && metrics.verticalOscillationCm <= 10.0)
        #expect(metrics.groundContactTimeMs >= 200.0 && metrics.groundContactTimeMs <= 290.0)
        #expect(metrics.cadenceZone == .optimal || metrics.cadenceZone == .moderate)
    }
    
    @Test("Test Cadence Zone Evaluation")
    func testCadenceZone() {
        #expect(CadenceZone.evaluate(spm: 190) == .fast)
        #expect(CadenceZone.evaluate(spm: 175) == .optimal)
        #expect(CadenceZone.evaluate(spm: 160) == .moderate)
        #expect(CadenceZone.evaluate(spm: 145) == .low)
    }
}

