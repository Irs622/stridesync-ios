import SwiftUI

/// Master Settings screen integrating profile edits, privacy zones, sensors, audio cues, gear, cloud sync, and notifications.
public struct ProfileSettingsView: View {
    @Bindable public var settings: UserSettingsManager
    @State public var authManager: AuthManager = .shared
    @State public var syncEngine: CloudSyncEngine = .shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSignOutAlert: Bool = false
    @State private var showingCacheClearedAlert: Bool = false
    @State private var showingGPXBackupAlert: Bool = false
    @State private var showingAuthSheet: Bool = false
    
    public init(settings: UserSettingsManager = .shared) {
        self.settings = settings
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: User Account Header Link
                Section {
                    if let user = authManager.currentUser {
                        NavigationLink(destination: EditProfileView(settings: settings)) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(StrideTheme.primaryGradient)
                                    .frame(width: 54, height: 54)
                                    .overlay {
                                        Image(systemName: "person.fill")
                                            .font(.title3.bold())
                                            .foregroundStyle(Color.white)
                                    }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(settings.fullName.isEmpty ? user.fullName : settings.fullName)
                                        .font(.headline.bold())
                                    Text("@\(settings.username.isEmpty ? user.username : settings.username) • \(settings.location)")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } else {
                        Button {
                            showingAuthSheet = true
                        } label: {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Image(systemName: "person.badge.key.fill")
                                            .font(.title3)
                                            .foregroundStyle(StrideTheme.primaryOrange)
                                    }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Masuk / Buat Akun Cloud")
                                        .font(.headline.bold())
                                        .foregroundStyle(Color.primary)
                                    Text("Sinkronkan latihan antar perangkat & ikuti komunitas")
                                        .font(.caption2)
                                        .foregroundStyle(Color.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Section 2: Cloud Sync & Backup Status
                Section("Sinkronisasi Cloud & Multi-User") {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Status Cloud Database")
                                .font(.subheadline.bold())
                            if let last = syncEngine.lastSyncTimestamp {
                                Text("Terakhir sinkron: \(last.formatted(date: .omitted, time: .standard))")
                                    .font(.caption2)
                                    .foregroundStyle(Color.secondary)
                            } else {
                                Text("Belum ada sinkronisasi terbaru")
                                    .font(.caption2)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            Task {
                                await syncEngine.syncAll(with: nil)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Sinkron")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(StrideTheme.primaryOrange.opacity(0.15))
                            .foregroundStyle(StrideTheme.primaryOrange)
                            .clipShape(Capsule())
                        }
                    }
                }
                
                // Section 3: Workout & Tracking Preferences
                Section("Preferensi Latihan & Sensor") {
                    Picker("Aktivitas Default", selection: $settings.defaultActivityType) {
                        ForEach(ActivityType.allCases) { type in
                            Label(type.rawValue, systemImage: type.iconName).tag(type)
                        }
                    }
                    
                    Picker("Satuan Jarak & Kecepatan", selection: $settings.isMetricUnits) {
                        Text("Metrik (km, min/km, meter)").tag(true)
                        Text("Imperial (miles, min/mi, kaki)").tag(false)
                    }
                    
                    Toggle("Auto-Pause Saat Berhenti", isOn: $settings.autoPauseEnabled)
                    Toggle("Sinkronisasi Apple HealthKit", isOn: $settings.healthKitSyncEnabled)
                    Toggle("Sinkronisasi Apple Watch", isOn: $settings.appleWatchSyncEnabled)
                    
                    NavigationLink(destination: AudioCuesSettingsView(settings: settings)) {
                        Label("Umpan Balik Suara (Audio Cues)", systemImage: "speaker.wave.2.fill")
                    }
                }
                
                // Section 4: Privacy & Gear
                Section("Privasi & Perlengkapan") {
                    NavigationLink(destination: PrivacyZonesSettingsView(settings: settings)) {
                        Label("Zona Privasi Peta & Keamanan", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink(destination: ManageGearView()) {
                        Label("Sepatu & Sepeda (Gear Tracker)", systemImage: "shoe.fill")
                    }
                }
                
                // Section 5: Notifications
                Section("Notifikasi Push") {
                    Toggle("Kudos yang Diterima", isOn: $settings.notifyKudos)
                    Toggle("Komentar Baru", isOn: $settings.notifyComments)
                    Toggle("Pemberitahuan Rekor KOM Hilang", isOn: $settings.notifySegmentLoss)
                    Toggle("Ringkasan Statistik Mingguan", isOn: $settings.notifyWeeklyDigest)
                }
                
                // Section 6: Data Management & Cache
                Section("Data & Penyimpanan") {
                    Button {
                        showingCacheClearedAlert = true
                    } label: {
                        Text("Bersihkan Cache Peta Offline")
                            .foregroundStyle(Color.primary)
                    }
                    
                    Button {
                        showingGPXBackupAlert = true
                    } label: {
                        Label("Ekspor Semua Riwayat Latihan (GPX Backup)", systemImage: "square.and.arrow.down")
                            .foregroundStyle(StrideTheme.primaryOrange)
                    }
                }
                
                // Section 7: About & Version
                Section("Tentang Aplikasi") {
                    HStack {
                        Text("Versi StrideSync")
                        Spacer()
                        Text("1.0.0 (Build 2026.1)")
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Link("Kebijakan Privasi", destination: URL(string: "https://stridesync.app/privacy")!)
                    Link("Ketentuan Layanan", destination: URL(string: "https://stridesync.app/terms")!)
                }
                
                // Section 8: Account Actions
                if authManager.currentUser != nil {
                    Section {
                        Button(role: .destructive) {
                            showingSignOutAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Keluar dari Akun")
                                    .font(.headline)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pengaturan")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Selesai") {
                        dismiss()
                    }
                    .font(.headline.bold())
                    .foregroundStyle(StrideTheme.primaryOrange)
                }
            }
            .sheet(isPresented: $showingAuthSheet) {
                AuthenticationView(authManager: authManager)
            }
            .alert("Cache Berhasil Dibersihkan", isPresented: $showingCacheClearedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Semua cache peta sementara telah dibersihkan untuk menghemat ruang memori.")
            }
            .alert("Backup GPX Berhasil Disiapkan", isPresented: $showingGPXBackupAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Arsip seluruh riwayat latihan dalam format GPX 1.1 XML siap dibagikan dan diekspor.")
            }
            .confirmationDialog("Yakin Ingin Keluar?", isPresented: $showingSignOutAlert, titleVisibility: .visible) {
                Button("Keluar", role: .destructive) {
                    authManager.signOut()
                    dismiss()
                }
                Button("Batal", role: .cancel) {}
            }
        }
    }
}
