import Foundation

/// Engine providing rhythmic audio and haptic cadence clicks to help runners maintain target steps-per-minute (SPM).
public final class CadenceMetronomeEngine: @unchecked Sendable {
    public static let shared = CadenceMetronomeEngine()
    
    private(set) public var isRunning: Bool = false
    public var targetCadenceSPM: Int = 180 {
        didSet {
            targetCadenceSPM = min(220, max(120, targetCadenceSPM))
            if isRunning {
                restartTimer()
            }
        }
    }
    
    public var isAudioClickEnabled: Bool = true
    public var isHapticTapEnabled: Bool = true
    
    private var timerTask: Task<Void, Never>?
    public var onBeat: (@Sendable (Int) -> Void)?
    private var beatCount: Int = 0
    
    public init(targetCadenceSPM: Int = 180) {
        self.targetCadenceSPM = targetCadenceSPM
    }
    
    /// Interval in seconds between consecutive beats: 60 / SPM.
    public var beatIntervalSeconds: TimeInterval {
        60.0 / Double(max(1, targetCadenceSPM))
    }
    
    /// Starts the metronome loop.
    public func start() {
        guard !isRunning else { return }
        isRunning = true
        beatCount = 0
        restartTimer()
    }
    
    /// Stops the metronome loop.
    public func stop() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }
    
    /// Toggles the running state.
    public func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
    
    private func restartTimer() {
        timerTask?.cancel()
        let intervalNanos = UInt64(beatIntervalSeconds * 1_000_000_000)
        
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: intervalNanos)
                guard let self = self, self.isRunning else { break }
                
                self.beatCount += 1
                let currentBeat = self.beatCount
                
                if self.isHapticTapEnabled {
                    Task { @MainActor in
                        HapticFeedbackService.shared.playImpact(.light)
                    }
                }
                
                self.onBeat?(currentBeat)
            }
        }
    }
    
    /// Evaluates if an athlete's measured cadence is within target tolerance (+- 5 SPM).
    public func evaluateCadenceDeviation(actualCadenceSPM: Int) -> (isLocked: Bool, deltaSPM: Int, advice: String) {
        let delta = actualCadenceSPM - targetCadenceSPM
        if abs(delta) <= 4 {
            return (true, delta, "Cadence terkunci sempurna pada \(actualCadenceSPM) SPM 🎯")
        } else if delta < -4 {
            return (false, delta, "Tingkatkan frekuensi langkah +\(abs(delta)) SPM ⚡️")
        } else {
            return (false, delta, "Perpanjang langkah & kurangi frekuensi \(delta) SPM 🏃")
        }
    }
}

