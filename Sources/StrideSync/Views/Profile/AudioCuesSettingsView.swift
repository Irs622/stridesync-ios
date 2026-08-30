import SwiftUI

/// Audio voice feedback configuration screen (cues, pace announcements, language, and frequency).
public struct AudioCuesSettingsView: View {
    @Bindable public var settings: UserSettingsManager
    
    @MainActor
    public init(settings: UserSettingsManager? = nil) {
        self.settings = settings ?? .shared
    }
    
    public var body: some View {
        Form {
            Section {
                Toggle("Aktifkan Umpan Balik Suara (Voice Cues)", isOn: $settings.isAudioCueEnabled)
            }
            
            if settings.isAudioCueEnabled {
                Section("Bahasa Suara") {
                    Picker("Bahasa", selection: $settings.audioCueLanguage) {
                        Text("Bahasa Indonesia (id-ID)").tag("id-ID")
                        Text("English (en-US)").tag("en-US")
                    }
                }
                
                Section("Frekuensi Pengumuman") {
                    Picker("Interval Jarak", selection: $settings.audioCueIntervalMeters) {
                        Text("Setiap 500 meter").tag(500.0)
                        Text("Setiap 1 kilometer (Standar)").tag(1000.0)
                        Text("Setiap 2 kilometer").tag(2000.0)
                        Text("Setiap 1 mil (1.6 km)").tag(1609.34)
                    }
                }
                
                Section(header: Text("Metrik yang Diumumkan"), footer: Text("Suara akan otomatis membacakan metrik pilihan Anda saat melewati setiap interval jarak.")) {
                    Toggle("Pace Split Terakhir", isOn: $settings.announceSplitPace)
                    Toggle("Total Waktu Latihan", isOn: $settings.announceTotalTime)
                    Toggle("Denyut Jantung Saat Ini", isOn: $settings.announceHeartRate)
                }
            }
        }
        .navigationTitle("Umpan Balik Suara")
    }
}

