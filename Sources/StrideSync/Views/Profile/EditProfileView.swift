import SwiftUI

/// Form screen for editing personal athlete details, body metrics, and bio.
public struct EditProfileView: View {
    @Bindable public var settings: UserSettingsManager
    @Environment(\.dismiss) private var dismiss
    
    public init(settings: UserSettingsManager = .shared) {
        self.settings = settings
    }
    
    public var body: some View {
        Form {
            // Profile Photo Header
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(StrideTheme.primaryGradient)
                                .frame(width: 90, height: 90)
                                .overlay {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundStyle(Color.white)
                                }
                            
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.white)
                                }
                        }
                        
                        Text("Ubah Foto Profil")
                            .font(.subheadline.bold())
                            .foregroundStyle(StrideTheme.primaryOrange)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            
            // Basic Info
            Section("Informasi Dasar") {
                HStack {
                    Text("Nama Lengkap")
                        .frame(width: 120, alignment: .leading)
                    TextField("Nama Lengkap", text: $settings.fullName)
                }
                
                HStack {
                    Text("Username")
                        .frame(width: 120, alignment: .leading)
                    TextField("Username", text: $settings.username)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                
                HStack {
                    Text("Lokasi")
                        .frame(width: 120, alignment: .leading)
                    TextField("Kota, Negara", text: $settings.location)
                }
            }
            
            // Bio
            Section("Bio / Deskripsi") {
                TextField("Tulis tentang target lari atau motivasimu...", text: $settings.bio, axis: .vertical)
                    .lineLimit(3...5)
            }
            
            // Body Metrics for Calorie & VO2 Max Accuracy
            Section(header: Text("Metrik Fisik"), footer: Text("Data ini digunakan untuk menghitung estimasi pembakaran kalori yang akurat.")) {
                HStack {
                    Text("Berat Badan")
                    Spacer()
                    TextField("Berat", value: $settings.weightKg, format: .number)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg")
                        .foregroundStyle(Color.secondary)
                }
                
                HStack {
                    Text("Tinggi Badan")
                    Spacer()
                    TextField("Tinggi", value: $settings.heightCm, format: .number)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("cm")
                        .foregroundStyle(Color.secondary)
                }
                
                Picker("Jenis Kelamin", selection: $settings.gender) {
                    Text("Pria").tag("Pria")
                    Text("Wanita").tag("Wanita")
                    Text("Lainnya").tag("Lainnya")
                }
            }
        }
        .navigationTitle("Edit Profil")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Selesai") {
                    dismiss()
                }
                .font(.headline.bold())
                .foregroundStyle(StrideTheme.primaryOrange)
            }
        }
    }
}

