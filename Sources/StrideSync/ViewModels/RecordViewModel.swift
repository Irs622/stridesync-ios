import Foundation
import CoreLocation
import SwiftUI

/// Observable ViewModel managing active workout recording, HUD telemetry streams, and timer tickers.
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
    
    private var locationEngine: LocationEngine?
    private var timerTask: Task<Void, Never>?
    private var lastAnnouncedKm: Int = 0
    
    public init(activityType: ActivityType = .run) {
        self.selectedActivityType = activityType
    }
    
    // MARK: - Workout Controls
    
    public func startWorkout() {
        guard trackingState == .idle else { return }
        
        let engine = LocationEngine(
            activityType: selectedActivityType,
            autoPauseEnabled: autoPauseEnabled
        )
        self.locationEngine = engine
        
        Task {
            await engine.start()
            self.trackingState = .recording
            AudioCueService.shared.speakWorkoutStatus(text: "Latihan dimulai")
            self.startTimer()
        }
    }
    
    public func pauseWorkout() {
        guard trackingState == .recording || trackingState == .autoPaused else { return }
        Task {
            await locationEngine?.pause()
            self.trackingState = .paused
            AudioCueService.shared.speakWorkoutStatus(text: "Latihan dijeda")
        }
    }
    
    public func resumeWorkout() {
        guard trackingState == .paused || trackingState == .autoPaused else { return }
        Task {
            await locationEngine?.resume()
            self.trackingState = .recording
            AudioCueService.shared.speakWorkoutStatus(text: "Latihan dilanjutkan")
        }
    }
    
    public func finishWorkout() async -> (ActivityRecord, [TelemetrySnapshot], [SplitSnapshot])? {
        guard let engine = locationEngine else { return nil }
        
        stopTimer()
        let (summary, points) = await engine.finish()
        self.trackingState = .finished
        
        let record = ActivityRecord(from: summary)
        
        // Calculate splits
        let calculator = SplitCalculator()
        let splits = calculator.calculateSplits(from: points)
        
        AudioCueService.shared.speakWorkoutStatus(text: "Latihan selesai. Kerja bagus!")
        return (record, points, splits)
    }
    
    public func discardWorkout() {
        stopTimer()
        trackingState = .idle
        distanceMeters = 0.0
        elapsedTimeSeconds = 0.0
        movingTimeSeconds = 0.0
        routeCoordinates.removeAll()
        locationEngine = nil
    }
    
    // MARK: - Ingestion of Coordinates
    
    public func ingestLocation(_ location: CLLocation) {
        guard let engine = locationEngine else { return }
        
        Task {
            let metrics = await engine.processLocation(location)
            self.distanceMeters = metrics.distanceMeters
            self.currentSpeedMps = metrics.currentSpeedMps
            self.currentPaceSecondsPerKm = metrics.currentPaceSecondsPerKm
            self.averagePaceSecondsPerKm = metrics.averagePaceSecondsPerKm
            self.totalElevationGainMeters = metrics.totalElevationGainMeters
            self.trackingState = metrics.state
            self.routeCoordinates = metrics.coordinates
            
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

