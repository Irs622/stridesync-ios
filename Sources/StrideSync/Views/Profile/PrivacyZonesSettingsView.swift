import SwiftUI

/// Privacy configuration screen managing privacy geofences (home/work radius) and activity visibility.
public struct PrivacyZonesSettingsView: View {
    @Bindable public var settings: UserSettingsManager
    @State private var showingAddZoneSheet: Bool = false
    @State private var newZoneName: String = ""
    @State private var newZoneRadius: Double = 500.0
    
    @MainActor
    public init(settings: UserSettingsManager? = nil) {
        self.settings = settings ?? .shared
    }
    
    public var body: some View {
        Form {
            // Default Visibility
            Section(header: Text("Visibilitas Standar"), footer: Text("Menentukan siapa yang dapat melihat rute dan waktu latihan barumu secara default.")) {
                Picker("Visibilitas Aktivitas", selection: $settings.defaultVisibility) {
                    ForEach(VisibilityType.allCases) { type in
                        Label(type.rawValue, systemImage: type.iconName).tag(type)
                    }
                }
            }
            
            // Privacy Zones (Hide Home / Work)
            Section(header: Text("Zona Privasi Peta"), footer: Text("Titik awal dan akhir latihan yang berada di dalam radius zona ini akan otomatis disembunyikan dari peta publik untuk melindungi alamat rumah Anda.")) {
                if settings.privacyZones.isEmpty {
                    Text("Belum ada zona privasi")
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(settings.privacyZones) { zone in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(zone.name)
                                    .font(.headline)
                                Text("Radius: \(Int(zone.radiusMeters)) meter")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                            Spacer()
                            Image(systemName: "shield.fill")
                                .foregroundStyle(Color.green)
                        }
                    }
                    .onDelete(perform: settings.removePrivacyZone)
                }
                
                Button {
                    showingAddZoneSheet = true
                } label: {
                    Label("Tambah Zona Privasi Baru", systemImage: "plus.circle.fill")
                        .foregroundStyle(StrideTheme.primaryOrange)
                }
            }
            
            // Health Data Privacy
            Section("Privasi Data Kesehatan") {
                Toggle("Sembunyikan Denyut Jantung dari Publik", isOn: $settings.hideHeartRateData)
                Toggle("Sembunyikan Titik Start/Finish Otomatis", isOn: $settings.hideStartFinishPoints)
            }
        }
        .navigationTitle("Privasi & Keamanan")
        .sheet(isPresented: $showingAddZoneSheet) {
            NavigationStack {
                Form {
                    Section("Nama Zona") {
                        TextField("Contoh: Rumah, Kantor, Gym", text: $newZoneName)
                    }
                    
                    Section("Radius Perlindungan") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(Int(newZoneRadius)) meter")
                                .font(.headline.bold())
                                .foregroundStyle(StrideTheme.primaryOrange)
                            
                            Slider(value: $newZoneRadius, in: 100...1000, step: 50)
                                .tint(StrideTheme.primaryOrange)
                        }
                    }
                }
                .navigationTitle("Zona Baru")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Batal") { showingAddZoneSheet = false }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Simpan") {
                            let name = newZoneName.isEmpty ? "Zona Privasi" : newZoneName
                            settings.addPrivacyZone(name: name, latitude: -6.175392, longitude: 106.827153, radiusMeters: newZoneRadius)
                            newZoneName = ""
                            showingAddZoneSheet = false
                        }
                        .disabled(newZoneName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

