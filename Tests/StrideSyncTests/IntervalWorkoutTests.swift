import Testing
import Foundation
@testable import StrideSync

@Suite("Structured Interval Workout Engine Tests")
struct IntervalWorkoutTests {
    
    @Test("Test Standard Presets Initialization")
    func testStandardPresets() {
        let presets = StructuredWorkoutPlan.standardPresets
        #expect(presets.count == 4)
        
        let speedLadder = StructuredWorkoutPlan.speedLadder5K
        #expect(speedLadder.intervalCount == 4)
        #expect(speedLadder.steps.count == 10)
        #expect(speedLadder.steps.first?.stepType == .warmup)
        #expect(speedLadder.steps.last?.stepType == .cooldown)
    }
    
    @Test("Test Step Target Formatting")
    func testStepTargetFormatting() {
        let distStep = WorkoutStep(orderIndex: 0, stepType: .intervalWork, targetType: .distance, targetValue: 400, targetPaceSecondsPerKm: 240)
        #expect(distStep.formattedTarget == "400 m")
        #expect(distStep.formattedTargetPace == "4:00 /km")
        
        let durStep = WorkoutStep(orderIndex: 1, stepType: .recoveryRest, targetType: .duration, targetValue: 90)
        #expect(durStep.formattedTarget == "1m 30s")
    }
    
    @Test("Test Interval Execution Engine Step Transitions")
    func testIntervalExecutionEngineTransitions() {
        let plan = StructuredWorkoutPlan.speedLadder5K
        let engine = IntervalExecutionEngine(plan: plan)
        
        let startTime = Date()
        engine.start(initialDistanceMeters: 0.0, startTime: startTime)
        
        #expect(engine.currentStepIndex == 0)
        #expect(engine.currentStep?.stepType == .warmup)
        
        // Update at 500m (halfway through warmup of 1000m)
        let prog1 = engine.update(currentDistanceMeters: 500.0, currentTimestamp: startTime.addingTimeInterval(150))
        #expect(prog1 != nil)
        #expect(prog1?.progressFraction == 0.5)
        #expect(prog1?.remainingValue == 500.0)
        #expect(prog1?.isStepFinished == false)
        
        // Update at 1000m (warmup finished -> advances to step 1)
        let prog2 = engine.update(currentDistanceMeters: 1000.0, currentTimestamp: startTime.addingTimeInterval(300))
        #expect(prog2 != nil)
        #expect(prog2?.isStepFinished == true)
        #expect(engine.currentStepIndex == 1)
        #expect(engine.currentStep?.stepType == .intervalWork)
    }
    
    @Test("Test Manual Step Advance")
    func testManualStepAdvance() {
        let plan = StructuredWorkoutPlan.tabataHighIntensity
        let engine = IntervalExecutionEngine(plan: plan)
        engine.start()
        
        #expect(engine.currentStepIndex == 0)
        let next = engine.advanceToNextStep(currentDistanceMeters: 0.0)
        #expect(next != nil)
        #expect(engine.currentStepIndex == 1)
    }
}

