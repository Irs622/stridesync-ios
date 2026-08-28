import SwiftUI

/// Settings view for managing Live Safety Beacon web sharing and emergency contacts.
public struct SafetyBeaconSettingsView: View {
    @State private var beaconService = LiveSafetyBeaconService.shared
    @State private var newContactName: String = ""
    @State private var newContactPhone: String = ""
    @State private var newContactRelation: String = "Keluarga"
    @State private var showingAddContactSheet: Bool = false
    @State private var copiedTokenAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        Form {
            // Live Status Section
            Section {
                HStack(spacing: 14) {
                    Image(systemName: beaconService.isBeaconActive ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                        .font(.title2.bold())
                        .foregroundStyle(beaconService.isBeaconActive ? StrideTheme.athleticGreen : Color.secondary)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(beaconService.isBeaconActive ? "Safety Beacon Sedang Aktif" : "Safety Beacon Siap Digunakan")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        Text(beaconService.isBeaconActive ? "Lokasi real-time sedang disiarkan ke kontak darurat." : "Otomatis membagikan link live GPS ke kontak pilihan.")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .padding(.vertical, 4)
                
                if let session = beaconService.currentSession, session.isLive {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tautan Web Live Pelacakan:")
                            .font(.caption.bold())
                            .foregroundStyle(Color.secondary)
                        
                        HStack {
                            Text(session.shareableURLString)
                                .font(.system(size: 11, design: .monospaced))
                                .lineLimit(1)
                                .foregroundStyle(StrideTheme.primaryOrange)
                            
                            Spacer()
                            
                            Button {
                                #if os(iOS)
                                UIPasteboard.general.string = session.shareableURLString
                                #endif
                                copiedTokenAlert = true
                            } label: {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.caption.bold())
                            }
                        }
                    }
                }
            } header: {
                Text("Status Siaran Langsung")
            }
            
            // Emergency Contacts Section
            Section {
                ForEach(beaconService.emergencyContacts) { contact in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(contact.name)
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                Text("(\(contact.relationship))")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                            Text(contact.phoneNumber)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                        
                        Spacer()
                        
                        if contact.autoNotifyOnStart {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(StrideTheme.athleticGreen)
                        }
                    }
                }
                .onDelete { indexSet in
                    beaconService.emergencyContacts.remove(atOffsets: indexSet)
                }
                
                Button {
                    showingAddContactSheet = true
                } label: {
                    Label("Tambah Kontak Darurat", systemImage: "person.badge.plus")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(StrideTheme.primaryOrange)
                }
            } header: {
                Text("Kontak Darurat Terverifikasi")
            } footer: {
                Text("Kontak dengan tanda centang hijau akan menerima SMS otomatis berisi link pemantauan setiap kali Anda memulai latihan.")
            }
            
            // Incident Fall Detection Info
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "shield.checkered")
                        .font(.title3)
                        .foregroundStyle(StrideTheme.primaryOrange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Deteksi Insiden & Jatuh Keras")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        Text("Mendeteksi benturan keras (G > 3.5g) dan mengaktifkan hitung mundur alarm darurat 30 detik.")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
            } header: {
                Text("Keamanan Atlet Otomatis")
            }
        }
        .background(StrideTheme.groupedBackground)
        .navigationTitle("Live Safety Beacon")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showingAddContactSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Nama Lengkap", text: $newContactName)
                        TextField("Nomor Telepon (+62)", text: $newContactPhone)
                        TextField("Hubungan (Pasangan, Orang Tua, dll)", text: $newContactRelation)
                    } header: {
                        Text("Informasi Kontak")
                    }
                }
                .navigationTitle("Kontak Baru")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Batal") { showingAddContactSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Simpan") {
                            guard !newContactName.isEmpty, !newContactPhone.isEmpty else { return }
                            let contact = EmergencyContact(
                                name: newContactName,
                                phoneNumber: newContactPhone,
                                relationship: newContactRelation,
                                autoNotifyOnStart: true
                            )
                            beaconService.emergencyContacts.append(contact)
                            newContactName = ""
                            newContactPhone = ""
                            showingAddContactSheet = false
                        }
                    }
                }
            }
        }
        .alert("Tautan Berhasil Disalin", isPresented: $copiedTokenAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Link siaran langsung aman telah disalin ke clipboard.")
        }
    }
}
