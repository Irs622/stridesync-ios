import Foundation
import CoreLocation

/// Engine monitoring motion spikes for hard fall/crash incident detection during cycling or running workouts.
@Observable
@MainActor
public final class FallDetectionEngine {
    public static let shared = FallDetectionEngine()
    
    public var isMonitoring: Bool = false
    public var isCountdownActive: Bool = false
    public var countdownSecondsRemaining: Int = 30
    public var detectedIncident: IncidentEvent?
    public var isSOSSent: Bool = false
    
    public var onEmergencySOSTriggered: ((IncidentEvent) -> Void)?
    
    private var countdownTimer: Task<Void, Never>?
    
    public init() {}
    
    public func startMonitoring() {
        isMonitoring = true
        isCountdownActive = false
        isSOSSent = false
    }
    
    public func stopMonitoring() {
        isMonitoring = false
        cancelCountdown()
    }
    
    /// Evaluates raw acceleration vector magnitude for crash/fall spikes.
    /// Threshold: G-Force > 3.5g (where 1g ≈ 9.81 m/s²).
    public func evaluateAcceleration(x: Double, y: Double, z: Double, currentCoordinate: CLLocationCoordinate2D) {
        guard isMonitoring, !isCountdownActive, !isSOSSent else { return }
        
        let magnitude = sqrt(x*x + y*y + z*z)
        let gForce = magnitude / 9.81
        
        if gForce >= 3.5 {
            triggerFallDetected(gForce: gForce, coordinate: currentCoordinate)
        }
    }
    
    /// Explicitly triggers fall detection (used for sensor ingestion or manual simulation).
    public func triggerFallDetected(gForce: Double, coordinate: CLLocationCoordinate2D) {
        let incident = IncidentEvent(
            timestamp: Date(),
            coordinate: coordinate,
            peakGForce: gForce,
            isResolvedByUser: false
        )
        self.detectedIncident = incident
        self.isCountdownActive = true
        self.countdownSecondsRemaining = 30
        
        // Haptic & Audio Alert
        HapticFeedbackService.shared.playNotification(.error)
        AudioCueService.shared.speakWorkoutStatus(text: "Peringatan! Benturan keras terdeteksi. Sinyal darurat akan dikirim dalam 30 detik.")
        
        startCountdown()
    }
    
    /// Athlete confirms they are fine, aborting the emergency broadcast.
    public func dismissIncident() {
        cancelCountdown()
        if var incident = detectedIncident {
            incident.isResolvedByUser = true
            self.detectedIncident = incident
        }
        self.isCountdownActive = false
        AudioCueService.shared.speakWorkoutStatus(text: "Sinyal darurat dibatalkan. Selamat berolahraga kembali.")
    }
    
    private func startCountdown() {
        countdownTimer?.cancel()
        countdownTimer = Task { @MainActor in
            while countdownSecondsRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                self.countdownSecondsRemaining -= 1
                
                if self.countdownSecondsRemaining == 10 || self.countdownSecondsRemaining == 5 {
                    AudioCueService.shared.speakWorkoutStatus(text: "\(self.countdownSecondsRemaining) detik tersisa.")
                }
            }
            
            // Countdown expired without athlete dismissing -> Broadcast SOS
            self.sendEmergencySOS()
        }
    }
    
    private func cancelCountdown() {
        countdownTimer?.cancel()
        countdownTimer = nil
        isCountdownActive = false
    }
    
    private func sendEmergencySOS() {
        guard let incident = detectedIncident else { return }
        self.isCountdownActive = false
        self.isSOSSent = true
        
        LiveSafetyBeaconService.shared.triggerEmergencyAlert(at: incident.coordinate)
        onEmergencySOSTriggered?(incident)
    }
}
