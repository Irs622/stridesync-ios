import Foundation

/// Real-time execution engine managing structured interval workout state, phase transitions, and audio-haptic cues.
public final class IntervalExecutionEngine: @unchecked Sendable {
    public let plan: StructuredWorkoutPlan
    private(set) public var currentStepIndex: Int = 0
    private var stepStartDistanceMeters: Double = 0.0
    private var stepStartTimestamp: Date?
    private var isWorkoutCompleted: Bool = false
    
    public var onStepTransition: (@Sendable (WorkoutStep, Int, Int) -> Void)?
    public var onWorkoutComplete: (@Sendable () -> Void)?
    
    public init(plan: StructuredWorkoutPlan) {
        self.plan = plan
    }
    
    public var currentStep: WorkoutStep? {
        guard currentStepIndex < plan.steps.count else { return nil }
        return plan.steps[currentStepIndex]
    }
    
    /// Starts the interval workout sequence at the first step.
    public func start(initialDistanceMeters: Double = 0.0, startTime: Date = Date()) {
        currentStepIndex = 0
        stepStartDistanceMeters = initialDistanceMeters
        stepStartTimestamp = startTime
        isWorkoutCompleted = false
        
        if let step = currentStep {
            onStepTransition?(step, 0, plan.steps.count)
        }
    }
    
    /// Updates the engine with real-time distance and timestamp, evaluating step progress.
    public func update(
        currentDistanceMeters: Double,
        currentTimestamp: Date = Date()
    ) -> IntervalStepProgress? {
        guard !isWorkoutCompleted, let step = currentStep else { return nil }
        
        let startDist = stepStartDistanceMeters
        let startTime = stepStartTimestamp ?? currentTimestamp
        
        let stepDist = max(0.0, currentDistanceMeters - startDist)
        let stepDuration = max(0.0, currentTimestamp.timeIntervalSince(startTime))
        
        var isFinished = false
        var progressFraction = 0.0
        var remaining = 0.0
        
        switch step.targetType {
        case .distance:
            let target = step.targetValue
            progressFraction = target > 0 ? min(1.0, stepDist / target) : 1.0
            remaining = max(0.0, target - stepDist)
            if stepDist >= target {
                isFinished = true
            }
        case .duration:
            let target = step.targetValue
            progressFraction = target > 0 ? min(1.0, stepDuration / target) : 1.0
            remaining = max(0.0, target - stepDuration)
            if stepDuration >= target {
                isFinished = true
            }
        case .openLap:
            progressFraction = 0.5
            remaining = 0.0
            isFinished = false
        }
        
        let progress = IntervalStepProgress(
            currentStepIndex: currentStepIndex,
            totalSteps: plan.steps.count,
            step: step,
            stepElapsedTimeSeconds: stepDuration,
            stepDistanceMeters: stepDist,
            progressFraction: progressFraction,
            remainingValue: remaining,
            isStepFinished: isFinished
        )
        
        if isFinished {
            advanceToNextStep(currentDistanceMeters: currentDistanceMeters, currentTimestamp: currentTimestamp)
        }
        
        return progress
    }
    
    /// Manually or automatically advances to the next step.
    @discardableResult
    public func advanceToNextStep(
        currentDistanceMeters: Double,
        currentTimestamp: Date = Date()
    ) -> WorkoutStep? {
        currentStepIndex += 1
        stepStartDistanceMeters = currentDistanceMeters
        stepStartTimestamp = currentTimestamp
        
        if currentStepIndex < plan.steps.count {
            let nextStep = plan.steps[currentStepIndex]
            onStepTransition?(nextStep, currentStepIndex, plan.steps.count)
            return nextStep
        } else {
            isWorkoutCompleted = true
            onWorkoutComplete?()
            return nil
        }
    }
    
    /// Resets the engine back to initial state.
    public func reset() {
        currentStepIndex = 0
        stepStartDistanceMeters = 0.0
        stepStartTimestamp = nil
        isWorkoutCompleted = false
    }
}

