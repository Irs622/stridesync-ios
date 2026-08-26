import Foundation

#if canImport(HealthKit)
import HealthKit
#endif

/// Manager for integrating with Apple HealthKit (heart rate reading, energy burned, and workout session syncing).
public final class HealthKitManager: @unchecked Sendable {
    public static let shared = HealthKitManager()
    
    #if canImport(HealthKit)
    private let healthStore = HKHealthStore()
    #endif
    
    public var isHealthKitAvailable: Bool {
        #if canImport(HealthKit)
        return HKHealthStore.isHealthDataAvailable()
        #else
        return false
        #endif
    }
    
    public init() {}
    
    /// Requests authorization to read and write workout telemetry data.
    public func requestAuthorization() async -> Bool {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let typesToShare: Set<HKSampleType> = [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
        ]
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            return true
        } catch {
            return false
        }
        #else
        return false
        #endif
    }
    
    /// Saves a completed workout record to Apple HealthKit.
    public func saveWorkout(
        activityType: ActivityType,
        startDate: Date,
        endDate: Date,
        distanceMeters: Double,
        caloriesBurned: Double?
    ) async -> Bool {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        let hkActivityType: HKWorkoutActivityType
        switch activityType {
        case .run, .trailRun, .indoorRun:
            hkActivityType = .running
        case .ride:
            hkActivityType = .cycling
        case .walk:
            hkActivityType = .walking
        case .hike:
            hkActivityType = .hiking
        }
        
        let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: distanceMeters)
        let energyQuantity: HKQuantity? = caloriesBurned.map { HKQuantity(unit: .kilocalorie(), doubleValue: $0) }
        
        let workout = HKWorkout(
            activityType: hkActivityType,
            start: startDate,
            end: endDate,
            duration: endDate.timeIntervalSince(startDate),
            totalEnergyBurned: energyQuantity,
            totalDistance: distanceQuantity,
            metadata: [HKMetadataKeyIndoorWorkout: activityType == .indoorRun]
        )
        
        do {
            try await healthStore.save(workout)
            return true
        } catch {
            return false
        }
        #else
        return false
        #endif
    }
}

