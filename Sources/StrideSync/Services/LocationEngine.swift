import Foundation
import CoreLocation
import Combine

/// Real-time workout metrics snapshot emitted during an active recording.
public struct LiveWorkoutMetrics: Sendable {
    public var state: TrackingState
    public var distanceMeters: Double
    public var elapsedTimeSeconds: TimeInterval
    public var movingTimeSeconds: TimeInterval
    public var currentSpeedMps: Double
    public var maxSpeedMps: Double
    public var currentPaceSecondsPerKm: Double
    public var averagePaceSecondsPerKm: Double
    public var totalElevationGainMeters: Double
    public var currentHeartRate: Int?
    public var latestCoordinate: CLLocationCoordinate2D?
    public var coordinates: [CLLocationCoordinate2D]
    
    public init(
        state: TrackingState = .idle,
        distanceMeters: Double = 0.0,
        elapsedTimeSeconds: TimeInterval = 0.0,
        movingTimeSeconds: TimeInterval = 0.0,
        currentSpeedMps: Double = 0.0,
        maxSpeedMps: Double = 0.0,
        currentPaceSecondsPerKm: Double = 0.0,
        averagePaceSecondsPerKm: Double = 0.0,
        totalElevationGainMeters: Double = 0.0,
        currentHeartRate: Int? = nil,
        latestCoordinate: CLLocationCoordinate2D? = nil,
        coordinates: [CLLocationCoordinate2D] = []
    ) {
        self.state = state
        self.distanceMeters = distanceMeters
        self.elapsedTimeSeconds = elapsedTimeSeconds
        self.movingTimeSeconds = movingTimeSeconds
        self.currentSpeedMps = currentSpeedMps
        self.maxSpeedMps = maxSpeedMps
        self.currentPaceSecondsPerKm = currentPaceSecondsPerKm
        self.averagePaceSecondsPerKm = averagePaceSecondsPerKm
        self.totalElevationGainMeters = totalElevationGainMeters
        self.currentHeartRate = currentHeartRate
        self.latestCoordinate = latestCoordinate
        self.coordinates = coordinates
    }
}

/// Actor responsible for precision GPS streaming, noise filtering, auto-pause, and telemetry computation.
public actor LocationEngine {
    // Configuration
    public let activityType: ActivityType
    public let autoPauseEnabled: Bool
    public let autoPauseSpeedThresholdMps: Double // e.g. 0.8 m/s (~2.88 km/h)
    public let maxAcceptableAccuracyMeters: Double // 25.0 meters
    
    // State
    private(set) public var state: TrackingState = .idle
    private(set) public var distanceMeters: Double = 0.0
    private(set) public var totalElevationGainMeters: Double = 0.0
    private(set) public var maxSpeedMps: Double = 0.0
    private(set) public var currentSpeedMps: Double = 0.0
    
    // Time tracking
    private var sessionStartTime: Date?
    private var sessionEndTime: Date?
    private var lastRecordedPointTime: Date?
    private var accumulatedMovingTimeSeconds: TimeInterval = 0.0
    private var accumulatedPausedTimeSeconds: TimeInterval = 0.0
    private var lastStateChangeTime: Date?
    
    // Points storage
    private(set) public var telemetrySnapshots: [TelemetrySnapshot] = []
    private var lastValidLocation: CLLocation?
    private var recentSpeedSamples: [Double] = []
    
    // Active Heart Rate
    private var currentHeartRate: Int?
    
    public init(
        activityType: ActivityType = .run,
        autoPauseEnabled: Bool = true,
        autoPauseSpeedThresholdMps: Double = 0.8,
        maxAcceptableAccuracyMeters: Double = 25.0,
        initialState: TrackingState = .idle
    ) {
        self.activityType = activityType
        self.autoPauseEnabled = autoPauseEnabled
        self.autoPauseSpeedThresholdMps = autoPauseSpeedThresholdMps
        self.maxAcceptableAccuracyMeters = maxAcceptableAccuracyMeters
        self.state = initialState
        if initialState == .recording {
            let now = Date()
            self.sessionStartTime = now
            self.lastRecordedPointTime = now
            self.lastStateChangeTime = now
        }
    }
    
    // MARK: - Lifecycle Controls
    
    public func start() {
        guard state == .idle else { return }
        let now = Date()
        sessionStartTime = now
        lastRecordedPointTime = now
        lastStateChangeTime = now
        state = .recording
    }
    
    public func pause() {
        guard state == .recording || state == .autoPaused else { return }
        updateMovingTimeOnPause()
        state = .paused
        lastStateChangeTime = Date()
    }
    
    public func resume() {
        guard state == .paused || state == .autoPaused else { return }
        lastRecordedPointTime = Date()
        lastStateChangeTime = Date()
        state = .recording
    }
    
    public func finish() -> (ActivitySummarySnapshot, [TelemetrySnapshot]) {
        let now = Date()
        sessionEndTime = now
        if state == .recording {
            updateMovingTimeOnPause()
        }
        state = .finished
        
        let duration = sessionEndTime?.timeIntervalSince(sessionStartTime ?? now) ?? 0.0
        let movingTime = accumulatedMovingTimeSeconds > 0 ? accumulatedMovingTimeSeconds : duration
        let avgSpeed = movingTime > 0 ? (distanceMeters / movingTime) : 0.0
        
        let summary = ActivitySummarySnapshot(
            title: "\(activityType.rawValue) Workout",
            activityType: activityType,
            startTime: sessionStartTime ?? now,
            endTime: sessionEndTime ?? now,
            distanceMeters: distanceMeters,
            durationSeconds: duration,
            movingTimeSeconds: movingTime,
            totalElevationGainMeters: totalElevationGainMeters,
            averageSpeedMps: avgSpeed,
            maxSpeedMps: maxSpeedMps,
            averageHeartRate: currentHeartRate
        )
        
        return (summary, telemetrySnapshots)
    }
    
    public func updateHeartRate(_ hr: Int) {
        self.currentHeartRate = hr
    }
    
    // MARK: - Location Processing
    
    /// Ingest a raw CLLocation update from CoreLocation stream.
    public func processLocation(_ location: CLLocation) -> LiveWorkoutMetrics {
        guard state == .recording || state == .autoPaused else {
            return currentMetrics()
        }
        
        // 1. Accuracy Filter: Reject coordinates with invalid or poor horizontal accuracy
        guard location.horizontalAccuracy > 0,
              location.horizontalAccuracy <= maxAcceptableAccuracyMeters else {
            return currentMetrics()
        }
        
        let timestamp = location.timestamp
        let speed = max(0.0, location.speed)
        currentSpeedMps = speed
        
        // 2. Speed Smoothing
        recentSpeedSamples.append(speed)
        if recentSpeedSamples.count > 5 {
            recentSpeedSamples.removeFirst()
        }
        let smoothedSpeed = recentSpeedSamples.reduce(0.0, +) / Double(recentSpeedSamples.count)
        
        // 3. Auto-Pause Logic
        if autoPauseEnabled {
            if smoothedSpeed < autoPauseSpeedThresholdMps && state == .recording {
                state = .autoPaused
                updateMovingTimeOnPause()
            } else if smoothedSpeed >= autoPauseSpeedThresholdMps && state == .autoPaused {
                state = .recording
                lastRecordedPointTime = timestamp
            }
        }
        
        // 4. If recording, accumulate distance & elevation
        if state == .recording {
            if let lastLoc = lastValidLocation {
                let deltaDistance = location.distance(from: lastLoc)
                
                // Plausibility check: filter out teleportation leaps (> 150 km/h for running/cycling)
                let timeDelta = timestamp.timeIntervalSince(lastLoc.timestamp)
                let calculatedSpeed = timeDelta > 0 ? (deltaDistance / timeDelta) : 0
                
                let speedCap = activityType == .ride ? 45.0 : 15.0 // m/s
                if calculatedSpeed <= speedCap && deltaDistance > 0.5 {
                    distanceMeters += deltaDistance
                    
                    // Elevation Gain calculation
                    let deltaAlt = location.altitude - lastLoc.altitude
                    if deltaAlt > 0.3 && deltaAlt < 50.0 { // ignore jitter < 30cm
                        totalElevationGainMeters += deltaAlt
                    }
                    
                    if speed > maxSpeedMps && speed <= speedCap {
                        maxSpeedMps = speed
                    }
                    
                    if let lastTime = lastRecordedPointTime {
                        let stepDuration = timestamp.timeIntervalSince(lastTime)
                        if stepDuration > 0 && stepDuration < 30.0 {
                            accumulatedMovingTimeSeconds += stepDuration
                        }
                    }
                    lastRecordedPointTime = timestamp
                }
            } else {
                lastRecordedPointTime = timestamp
            }
            
            lastValidLocation = location
            
            // 5. Append Telemetry Snapshot
            let snapshot = TelemetrySnapshot(
                timestamp: timestamp,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                altitude: location.altitude,
                speedMps: speed,
                horizontalAccuracy: location.horizontalAccuracy,
                heartRate: currentHeartRate
            )
            telemetrySnapshots.append(snapshot)
        }
        
        return currentMetrics()
    }
    
    // MARK: - Helper Computations
    
    private func updateMovingTimeOnPause() {
        if let lastTime = lastRecordedPointTime {
            let delta = Date().timeIntervalSince(lastTime)
            if delta > 0 && delta < 10.0 {
                accumulatedMovingTimeSeconds += delta
            }
        }
    }
    
    public func currentMetrics() -> LiveWorkoutMetrics {
        let now = Date()
        let totalElapsed: TimeInterval
        if let start = sessionStartTime {
            totalElapsed = (sessionEndTime ?? now).timeIntervalSince(start)
        } else {
            totalElapsed = 0.0
        }
        
        var liveMoving = accumulatedMovingTimeSeconds
        if state == .recording, let last = lastRecordedPointTime {
            let additional = max(0.0, now.timeIntervalSince(last))
            liveMoving += min(additional, 5.0)
        }
        
        let avgSpeed = liveMoving > 0 ? (distanceMeters / liveMoving) : 0.0
        let currentPace = currentSpeedMps > 0.2 ? (1000.0 / currentSpeedMps) : 0.0
        let avgPace = avgSpeed > 0.2 ? (1000.0 / avgSpeed) : 0.0
        
        let coords = telemetrySnapshots.map { $0.coordinate }
        
        return LiveWorkoutMetrics(
            state: state,
            distanceMeters: distanceMeters,
            elapsedTimeSeconds: totalElapsed,
            movingTimeSeconds: liveMoving,
            currentSpeedMps: currentSpeedMps,
            maxSpeedMps: maxSpeedMps,
            currentPaceSecondsPerKm: currentPace,
            averagePaceSecondsPerKm: avgPace,
            totalElevationGainMeters: totalElevationGainMeters,
            currentHeartRate: currentHeartRate,
            latestCoordinate: lastValidLocation?.coordinate,
            coordinates: coords
        )
    }
}

