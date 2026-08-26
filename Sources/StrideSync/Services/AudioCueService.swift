import Foundation
import AVFAudio

/// Voice feedback service that speaks out split metrics and workout status using AVSpeechSynthesizer.
public final class AudioCueService: NSObject, @unchecked Sendable {
    public static let shared = AudioCueService()
    
    private let synthesizer = AVSpeechSynthesizer()
    public var isEnabled: Bool = true
    public var languageCode: String = "id-ID" // Default Indonesian, fallback to en-US
    
    public override init() {
        super.init()
    }
    
    /// Speaks split milestone announcement (e.g. "Kilometer 1, pace 5 menit 12 detik, waktu total 5 menit 12 detik").
    public func speakSplitAnnouncement(split: SplitSnapshot, totalDuration: TimeInterval) {
        guard isEnabled else { return }
        
        let splitIndex = split.splitIndex
        let paceMin = Int(split.averagePaceSecondsPerKm) / 60
        let paceSec = Int(split.averagePaceSecondsPerKm) % 60
        
        let totalMin = Int(totalDuration) / 60
        let totalSec = Int(totalDuration) % 60
        
        let message: String
        if languageCode.hasPrefix("id") {
            message = "Kilometer \(splitIndex). Pace \(paceMin) menit \(paceSec) detik. Waktu \(totalMin) menit \(totalSec) detik."
        } else {
            message = "Kilometer \(splitIndex). Pace \(paceMin) minutes \(paceSec) seconds. Total time \(totalMin) minutes \(totalSec) seconds."
        }
        
        speak(text: message)
    }
    
    /// Speaks state change updates (e.g. "Workout started", "Workout paused", "Workout resumed").
    public func speakWorkoutStatus(text: String) {
        guard isEnabled else { return }
        speak(text: text)
    }
    
    private func speak(text: String) {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Audio session setup error fallback
        }
        #endif
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode) ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
}

