import Testing
import Foundation
@testable import StrideSync

@Suite("Cadence Metronome & Biomechanics Tests")
struct CadenceMetronomeTests {
    
    @Test("Test Beat Interval Calculation")
    func testBeatIntervalCalculation() {
        let metronome = CadenceMetronomeEngine(targetCadenceSPM: 180)
        #expect(metronome.beatIntervalSeconds == (60.0 / 180.0))
        
        metronome.targetCadenceSPM = 120
        #expect(metronome.beatIntervalSeconds == 0.5)
    }
    
    @Test("Test Cadence Deviation Evaluation")
    func testCadenceDeviationEvaluation() {
        let metronome = CadenceMetronomeEngine(targetCadenceSPM: 180)
        
        let perfectLock = metronome.evaluateCadenceDeviation(actualCadenceSPM: 182)
        #expect(perfectLock.isLocked == true)
        #expect(perfectLock.deltaSPM == 2)
        
        let tooSlow = metronome.evaluateCadenceDeviation(actualCadenceSPM: 165)
        #expect(tooSlow.isLocked == false)
        #expect(tooSlow.deltaSPM == -15)
        
        let tooFast = metronome.evaluateCadenceDeviation(actualCadenceSPM: 195)
        #expect(tooFast.isLocked == false)
        #expect(tooFast.deltaSPM == 15)
    }
    
    @Test("Test Metronome Start and Stop Lifecycle")
    func testStartStopLifecycle() {
        let metronome = CadenceMetronomeEngine(targetCadenceSPM: 180)
        #expect(metronome.isRunning == false)
        
        metronome.start()
        #expect(metronome.isRunning == true)
        
        metronome.stop()
        #expect(metronome.isRunning == false)
    }
}

