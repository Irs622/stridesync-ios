import Foundation
import CoreLocation
import SwiftUI

#if os(iOS) && canImport(ActivityKit)
@preconcurrency import ActivityKit
#endif

/// Observable ViewModel managing active workout recording, HUD telemetry streams, Live Activities, and hardware GPS.
@Observable
@MainActor
public final class RecordViewModel {
    public var selectedActivityType: ActivityType = .run
    public var trackingState: TrackingState = .idle
    public var distanceMeters: Double = 0.0
    public var elapsedTimeSeconds: TimeInterval = 0.0
    public var movingTimeSeconds: TimeInterval = 0.0
    public var currentSpeedMps: Double = 0.0
    public var currentPaceSecondsPerKm: Double = 0.0
    public var averagePaceSecondsPerKm: Double = 0.0
    public var totalElevationGainMeters: Double = 0.0
    public var currentHeartRate: Int? = nil
    public var routeCoordinates: [CLLocationCoordinate2D] = []
    public var autoPauseEnabled: Bool = true
    public var isAudioCueEnabled: Bool = true
    
    public let liveLocationManager: LiveLocationManager
    private var locationEngine: LocationEngine?
    private var timerTask: Task<Void, Never>?
    private var lastAnnouncedKm: Int = 0
    
    #if os(iOS) && canImport(ActivityKit)
    private var liveActivity: Activity<WorkoutActivityAttributes>?
    #endif
    
    public init(
        activityType: ActivityType = .run,
        liveLocationManager: LiveLocationManager = LiveLocationManager()
    ) {
        self.selectedActivityType = activityType
        self.liveLocationManager = liveLocationManager
        
        self.liveLocationManager.onLocationUpdate = { [weak self] location in
            self?.ingestLocation(location)
        }
    }
    
    // MARK: - Workout Controls
    
    public func startWorkout(registeredSegments: [Segment] = []) {
        guard trackingState == .idle else { return }
        
        let engine = LocationEngine(
            activityType: selectedActivityType,
            autoPauseEnabled: autoPauseEnabled,
            initialState: .recording
        )
        self.locationEngine = engine
        self.trackingState = .recording
        
        // Request GPS authorization and start hardware updates
        liveLocationManager.requestAuthorization()
        liveLocationManager.startUpdatingLocation()
        
        HapticFeedbackService.shared.playNotification(.success)
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan dimulai")
        self.startTimer()
        self.startLiveActivity()
        
        Task {
            // Request HealthKit if enabled
            if UserSettingsManager.shared.healthKitSyncEnabled {
                _ = await HealthKitManager.shared.requestAuthorization()
            }
            await engine.start()
        }
    }
    
    public func pauseWorkout() {
        guard trackingState == .recording || trackingState == .autoPaused else { return }
        self.trackingState = .paused
        HapticFeedbackService.shared.playImpact(.heavy)
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan dijeda")
        self.updateLiveActivity()
        
        Task {
            await locationEngine?.pause()
        }
    }
    
    public func resumeWorkout() {
        guard trackingState == .paused || trackingState == .autoPaused else { return }
        self.trackingState = .recording
        HapticFeedbackService.shared.playImpact(.medium)
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan dilanjutkan")
        self.updateLiveActivity()
        
        Task {
            await locationEngine?.resume()
        }
    }
    
    public func finishWorkout(
        registeredSegments: [Segment] = ExploreView.sampleSegments(),
        athleteId: UUID = UUID(),
        athleteName: String = "Budi Santoso (You)"
    ) async -> (ActivityRecord, [TelemetrySnapshot], [SplitSnapshot], [SegmentEffort])? {
        guard let engine = locationEngine else { return nil }
        
        stopTimer()
        liveLocationManager.stopUpdatingLocation()
        endLiveActivity()
        
        let (summary, points) = await engine.finish()
        self.trackingState = .finished
        HapticFeedbackService.shared.playNotification(.success)
        
        let record = ActivityRecord(from: summary)
        
        // Calculate splits
        let calculator = SplitCalculator()
        let splits = calculator.calculateSplits(from: points)
        
        // Match segments
        let matcher = SegmentMatcher()
        let efforts = matcher.matchSegments(
            activityPoints: points,
            segments: registeredSegments,
            athleteId: athleteId,
            athleteName: athleteName
        )
        
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan selesai. Kerja bagus!")
        return (record, points, splits, efforts)
    }
    
    public func discardWorkout() {
        stopTimer()
        liveLocationManager.stopUpdatingLocation()
        endLiveActivity()
        
        trackingState = .idle
        distanceMeters = 0.0
        elapsedTimeSeconds = 0.0
        movingTimeSeconds = 0.0
        routeCoordinates.removeAll()
        locationEngine = nil
    }
    
    // MARK: - Ingestion of Coordinates
    
    public func ingestLocation(_ location: CLLocation) {
        Task {
            await ingestLocationAsync(location)
        }
    }
    
    public func ingestLocationAsync(_ location: CLLocation) async {
        guard let engine = locationEngine else { return }
        
        let metrics = await engine.processLocation(location)
        self.distanceMeters = metrics.distanceMeters
        self.movingTimeSeconds = metrics.movingTimeSeconds
        self.currentSpeedMps = metrics.currentSpeedMps
        self.currentPaceSecondsPerKm = metrics.currentPaceSecondsPerKm
        self.averagePaceSecondsPerKm = metrics.averagePaceSecondsPerKm
        self.totalElevationGainMeters = metrics.totalElevationGainMeters
        self.trackingState = metrics.state
        self.routeCoordinates = metrics.coordinates
        
        self.updateLiveActivity()
        
        // Check for 1km audio announcement
        let currentKm = Int(metrics.distanceMeters / 1000.0)
        if currentKm > self.lastAnnouncedKm && self.isAudioCueEnabled {
            self.lastAnnouncedKm = currentKm
            let points = await engine.telemetrySnapshots
            let splits = SplitCalculator().calculateSplits(from: points)
            if let lastSplit = splits.last {
                AudioCueService.shared.speakSplitAnnouncement(
                    split: lastSplit,
                    totalDuration: metrics.elapsedTimeSeconds
                )
            }
        }
    }
    
    public func updateHeartRate(_ hr: Int) {
        self.currentHeartRate = hr
        Task {
            await locationEngine?.updateHeartRate(hr)
            self.updateLiveActivity()
        }
    }
    
    // MARK: - Live Activity Integration
    
    private func startLiveActivity() {
        #if os(iOS) && canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = WorkoutActivityAttributes(
            workoutTitle: "\(selectedActivityType.rawValue) Workout",
            activityType: selectedActivityType
        )
        let initialContent = WorkoutActivityAttributes.ContentState(
            formattedDistance: formattedDistance + " km",
            formattedDuration: formattedDuration,
            formattedPace: formattedCurrentPace + " " + paceOrSpeedUnit,
            heartRate: currentHeartRate,
            isPaused: false
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialContent, staleDate: nil)
            )
            self.liveActivity = activity
        } catch {
            // Live Activity unavailable or disabled
        }
        #endif
    }
    
    private func updateLiveActivity() {
        #if os(iOS) && canImport(ActivityKit)
        guard let activity = liveActivity else { return }
        let updatedState = WorkoutActivityAttributes.ContentState(
            formattedDistance: formattedDistance + " km",
            formattedDuration: formattedDuration,
            formattedPace: formattedCurrentPace + " " + paceOrSpeedUnit,
            heartRate: currentHeartRate,
            isPaused: (trackingState == .paused || trackingState == .autoPaused)
        )
        Task { @MainActor in
            await activity.update(.init(state: updatedState, staleDate: nil))
        }
        #endif
    }
    
    private func endLiveActivity() {
        #if os(iOS) && canImport(ActivityKit)
        guard let activity = liveActivity else { return }
        let finalState = WorkoutActivityAttributes.ContentState(
            formattedDistance: formattedDistance + " km",
            formattedDuration: formattedDuration,
            formattedPace: formattedCurrentPace + " " + paceOrSpeedUnit,
            heartRate: currentHeartRate,
            isPaused: true
        )
        Task { @MainActor in
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            self.liveActivity = nil
        }
        #endif
    }
    
    // MARK: - Timer & Formatting
    
    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self = self else { break }
                self.tickTimer()
            }
        }
    }
    
    private func tickTimer() {
        if trackingState == .recording {
            elapsedTimeSeconds += 1.0
            movingTimeSeconds += 1.0
            if Int(elapsedTimeSeconds) % 5 == 0 {
                updateLiveActivity()
            }
        } else if trackingState == .paused || trackingState == .autoPaused {
            elapsedTimeSeconds += 1.0
        }
    }
    
    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
    
    public var formattedDistance: String {
        let km = distanceMeters / 1000.0
        return String(format: "%.2f", km)
    }
    
    public var formattedDuration: String {
        let totalSeconds = Int(elapsedTimeSeconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    public var formattedCurrentPace: String {
        if selectedActivityType.prefersPaceFormat {
            guard currentPaceSecondsPerKm > 0 && currentPaceSecondsPerKm < 3600 else { return "-:--" }
            let min = Int(currentPaceSecondsPerKm) / 60
            let sec = Int(currentPaceSecondsPerKm) % 60
            return String(format: "%d:%02d", min, sec)
        } else {
            let kmh = currentSpeedMps * 3.6
            return String(format: "%.1f", kmh)
        }
    }
    
    public var paceOrSpeedUnit: String {
        selectedActivityType.prefersPaceFormat ? "/km" : "km/h"
    }
}

