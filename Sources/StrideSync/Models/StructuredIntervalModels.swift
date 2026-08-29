import Foundation

/// Type of step within a structured interval workout.
public enum StepType: String, Codable, Sendable, CaseIterable {
    case warmup = "Warm-up"
    case intervalWork = "Interval / Sprint"
    case recoveryRest = "Recovery / Rest"
    case cooldown = "Cool-down"
    
    public var iconName: String {
        switch self {
        case .warmup: return "flame.fill"
        case .intervalWork: return "bolt.fill"
        case .recoveryRest: return "heart.circle.fill"
        case .cooldown: return "snowflake"
        }
    }
}

/// Target dimension for measuring workout step completion.
public enum TargetMetricType: String, Codable, Sendable, CaseIterable {
    case distance = "Distance (Meters)"
    case duration = "Duration (Seconds)"
    case openLap = "Open / Manual Lap"
}

/// Individual step specification in a structured workout plan.
public struct WorkoutStep: Identifiable, Codable, Sendable {
    public var id: UUID
    public var orderIndex: Int
    public var stepType: StepType
    public var targetType: TargetMetricType
    public var targetValue: Double // e.g. 400 meters or 90 seconds
    public var targetPaceSecondsPerKm: Double?
    public var targetHeartRateZone: Int?
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        orderIndex: Int,
        stepType: StepType,
        targetType: TargetMetricType,
        targetValue: Double,
        targetPaceSecondsPerKm: Double? = nil,
        targetHeartRateZone: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.stepType = stepType
        self.targetType = targetType
        self.targetValue = targetValue
        self.targetPaceSecondsPerKm = targetPaceSecondsPerKm
        self.targetHeartRateZone = targetHeartRateZone
        self.notes = notes
    }
    
    public var formattedTarget: String {
        switch targetType {
        case .distance:
            if targetValue >= 1000 {
                return String(format: "%.1f km", targetValue / 1000.0)
            } else {
                return String(format: "%.0f m", targetValue)
            }
        case .duration:
            let min = Int(targetValue) / 60
            let sec = Int(targetValue) % 60
            if min > 0 {
                return sec > 0 ? "\(min)m \(sec)s" : "\(min) min"
            } else {
                return "\(sec)s"
            }
        case .openLap:
            return "Lap Press"
        }
    }
    
    public var formattedTargetPace: String? {
        guard let pace = targetPaceSecondsPerKm, pace > 0 else { return nil }
        let min = Int(pace) / 60
        let sec = Int(pace) % 60
        return String(format: "%d:%02d /km", min, sec)
    }
}

/// A complete structured interval workout program with sequential steps.
public struct StructuredWorkoutPlan: Identifiable, Codable, Sendable {
    public var id: UUID
    public var title: String
    public var workoutDescription: String
    public var activityType: ActivityType
    public var steps: [WorkoutStep]
    
    public init(
        id: UUID = UUID(),
        title: String,
        workoutDescription: String = "",
        activityType: ActivityType = .run,
        steps: [WorkoutStep] = []
    ) {
        self.id = id
        self.title = title
        self.workoutDescription = workoutDescription
        self.activityType = activityType
        self.steps = steps
    }
    
    public var totalDistanceMeters: Double {
        steps.filter { $0.targetType == .distance }.reduce(0) { $0 + $1.targetValue }
    }
    
    public var totalDurationSeconds: TimeInterval {
        steps.filter { $0.targetType == .duration }.reduce(0) { $0 + $1.targetValue }
    }
    
    public var intervalCount: Int {
        steps.filter { $0.stepType == .intervalWork }.count
    }
    
    // MARK: - Standard Presets
    
    public static let speedLadder5K: StructuredWorkoutPlan = {
        var steps: [WorkoutStep] = []
        // Warmup: 1.0 km
        steps.append(WorkoutStep(orderIndex: 0, stepType: .warmup, targetType: .distance, targetValue: 1000, targetPaceSecondsPerKm: 340, notes: "Easy jogging warmup"))
        
        // 4x (400m fast + 200m rest)
        for i in 1...4 {
            steps.append(WorkoutStep(orderIndex: steps.count, stepType: .intervalWork, targetType: .distance, targetValue: 400, targetPaceSecondsPerKm: 240, targetHeartRateZone: 5, notes: "Rep \(i): Fast 400m sprint"))
            steps.append(WorkoutStep(orderIndex: steps.count, stepType: .recoveryRest, targetType: .distance, targetValue: 200, targetPaceSecondsPerKm: 390, targetHeartRateZone: 1, notes: "Rep \(i): 200m recovery jog"))
        }
        
        // Cooldown: 1.0 km
        steps.append(WorkoutStep(orderIndex: steps.count, stepType: .cooldown, targetType: .distance, targetValue: 1000, targetPaceSecondsPerKm: 360, notes: "Easy cooldown and walk"))
        
        return StructuredWorkoutPlan(
            title: "5K Speed Ladder (4x400m)",
            workoutDescription: "Latihan kecepatan 4 repetisi 400m untuk meningkatkan VO2 Max dan laktat threshold.",
            activityType: .run,
            steps: steps
        )
    }()
    
    public static let vo2MaxMileRepeats: StructuredWorkoutPlan = {
        var steps: [WorkoutStep] = []
        // Warmup: 1.5 km
        steps.append(WorkoutStep(orderIndex: 0, stepType: .warmup, targetType: .distance, targetValue: 1500, targetPaceSecondsPerKm: 330))
        
        // 3x (1600m @ 4:15/km + 180s rest)
        for i in 1...3 {
            steps.append(WorkoutStep(orderIndex: steps.count, stepType: .intervalWork, targetType: .distance, targetValue: 1600, targetPaceSecondsPerKm: 255, targetHeartRateZone: 4, notes: "Mile \(i) @ 5K Race Pace"))
            steps.append(WorkoutStep(orderIndex: steps.count, stepType: .recoveryRest, targetType: .duration, targetValue: 180, targetHeartRateZone: 1, notes: "3 min active recovery"))
        }
        
        // Cooldown: 1.0 km
        steps.append(WorkoutStep(orderIndex: steps.count, stepType: .cooldown, targetType: .distance, targetValue: 1000, targetPaceSecondsPerKm: 360))
        
        return StructuredWorkoutPlan(
            title: "VO2 Max 3x1 Mile Repeats",
            workoutDescription: "Latihan interval jarak menengah 3 repetisi 1 mil pada pace lomba 5K.",
            activityType: .run,
            steps: steps
        )
    }()
    
    public static let tempoThreshold8K: StructuredWorkoutPlan = {
        var steps: [WorkoutStep] = []
        steps.append(WorkoutStep(orderIndex: 0, stepType: .warmup, targetType: .distance, targetValue: 2000, targetPaceSecondsPerKm: 330))
        steps.append(WorkoutStep(orderIndex: 1, stepType: .intervalWork, targetType: .distance, targetValue: 4000, targetPaceSecondsPerKm: 270, targetHeartRateZone: 3, notes: "Lactate Threshold Pace"))
        steps.append(WorkoutStep(orderIndex: 2, stepType: .cooldown, targetType: .distance, targetValue: 2000, targetPaceSecondsPerKm: 360))
        
        return StructuredWorkoutPlan(
            title: "8K Lactate Threshold Tempo",
            workoutDescription: "Sesi tempo run berkelanjutan untuk membangun daya tahan aerobik dan efisiensi laktat.",
            activityType: .run,
            steps: steps
        )
    }()
    
    public static let tabataHighIntensity: StructuredWorkoutPlan = {
        var steps: [WorkoutStep] = []
        steps.append(WorkoutStep(orderIndex: 0, stepType: .warmup, targetType: .duration, targetValue: 300, notes: "5 min warmup"))
        for i in 1...8 {
            steps.append(WorkoutStep(orderIndex: steps.count, stepType: .intervalWork, targetType: .duration, targetValue: 30, notes: "Sprint \(i) (30s All-Out)"))
            steps.append(WorkoutStep(orderIndex: steps.count, stepType: .recoveryRest, targetType: .duration, targetValue: 30, notes: "Rest \(i) (30s)"))
        }
        steps.append(WorkoutStep(orderIndex: steps.count, stepType: .cooldown, targetType: .duration, targetValue: 300, notes: "5 min cooldown"))
        
        return StructuredWorkoutPlan(
            title: "Tabata Sprint 30/30 (8 Reps)",
            workoutDescription: "Interval sprint intensitas tinggi 30 detik kerja / 30 detik istirahat.",
            activityType: .run,
            steps: steps
        )
    }()
    
    public static let standardPresets: [StructuredWorkoutPlan] = [
        speedLadder5K,
        vo2MaxMileRepeats,
        tempoThreshold8K,
        tabataHighIntensity
    ]
}

/// Real-time live execution progress state for the active workout step.
public struct IntervalStepProgress: Sendable {
    public var currentStepIndex: Int
    public var totalSteps: Int
    public var step: WorkoutStep
    public var stepElapsedTimeSeconds: TimeInterval
    public var stepDistanceMeters: Double
    public var progressFraction: Double // 0.0 to 1.0
    public var remainingValue: Double
    public var isStepFinished: Bool
    
    public init(
        currentStepIndex: Int,
        totalSteps: Int,
        step: WorkoutStep,
        stepElapsedTimeSeconds: TimeInterval,
        stepDistanceMeters: Double,
        progressFraction: Double,
        remainingValue: Double,
        isStepFinished: Bool
    ) {
        self.currentStepIndex = currentStepIndex
        self.totalSteps = totalSteps
        self.step = step
        self.stepElapsedTimeSeconds = stepElapsedTimeSeconds
        self.stepDistanceMeters = stepDistanceMeters
        self.progressFraction = min(1.0, max(0.0, progressFraction))
        self.remainingValue = max(0.0, remainingValue)
        self.isStepFinished = isStepFinished
    }
    
    public var formattedRemaining: String {
        switch step.targetType {
        case .distance:
            if remainingValue >= 1000 {
                return String(format: "%.2f km tersisa", remainingValue / 1000.0)
            } else {
                return String(format: "%.0f m tersisa", remainingValue)
            }
        case .duration:
            let min = Int(remainingValue) / 60
            let sec = Int(remainingValue) % 60
            return String(format: "%02d:%02d tersisa", min, sec)
        case .openLap:
            return "Tekan Lap untuk lanjut"
        }
    }
}

