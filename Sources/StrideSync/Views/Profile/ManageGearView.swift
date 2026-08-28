import SwiftUI
import SwiftData

/// Equipment management screen for adding and updating running shoes and bicycles.
public struct ManageGearView: View {
    public var modelContext: ModelContext?
    @State public var gearList: [GearItem]
    @State private var showingAddGearSheet: Bool = false
    @State private var newGearName: String = ""
    @State private var newGearBrand: String = ""
    @State private var newGearMaxKm: Double = 600.0
    @State private var newGearType: ActivityType = .run
    
    public init(gearList: [GearItem] = ProfileView.sampleGear(), modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        self._gearList = State(initialValue: gearList)
    }
    
    public var body: some View {
        Form {
            // Running Shoes
            Section("Sepatu Lari") {
                let shoes = gearList.filter { $0.activityType == .run }
                if shoes.isEmpty {
                    Text("Belum ada sepatu lari terdaftar")
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(shoes) { gear in
                        gearRow(gear: gear)
                    }
                }
            }
            
            // Bicycles
            Section("Sepeda") {
                let bikes = gearList.filter { $0.activityType == .ride }
                if bikes.isEmpty {
                    Text("Belum ada sepeda terdaftar")
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(bikes) { gear in
                        gearRow(gear: gear)
                    }
                }
            }
            
            Section {
                Button {
                    showingAddGearSheet = true
                } label: {
                    Label("Tambah Perlengkapan Baru", systemImage: "plus.circle.fill")
                        .foregroundStyle(StrideTheme.primaryOrange)
                }
            }
        }
        .navigationTitle("Perlengkapan (Gear)")
        .sheet(isPresented: $showingAddGearSheet) {
            NavigationStack {
                Form {
                    Section("Tipe Perlengkapan") {
                        Picker("Tipe", selection: $newGearType) {
                            Text("Sepatu Lari").tag(ActivityType.run)
                            Text("Sepeda").tag(ActivityType.ride)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section("Detail Perlengkapan") {
                        TextField("Merek (contoh: Nike, Specialized)", text: $newGearBrand)
                        TextField("Model (contoh: Vaporfly 3, Tarmac)", text: $newGearName)
                    }
                    
                    Section(header: Text("Batas Umur Pakai Rekomendasi"), footer: Text(newGearType == .run ? "Sepatu lari umumnya memiliki masa pakai optimal 500-800 km." : "Komponen sepeda disarankan dicek setiap 3000-5000 km.")) {
                        HStack {
                            Text("Maksimal Jarak:")
                            Spacer()
                            TextField("Km", value: $newGearMaxKm, format: .number)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("km")
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .navigationTitle("Tambah Gear")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Batal") { showingAddGearSheet = false }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Simpan") {
                            let item = GearItem(
                                name: newGearName,
                                brand: newGearBrand,
                                maxLifeDistanceMeters: newGearMaxKm * 1000.0,
                                currentDistanceMeters: 0,
                                isDefault: false,
                                activityType: newGearType
                            )
                            gearList.append(item)
                            if let context = modelContext {
                                context.insert(item)
                                try? context.save()
                            }
                            newGearName = ""
                            newGearBrand = ""
                            showingAddGearSheet = false
                        }
                        .disabled(newGearName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newGearBrand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func gearRow(gear: GearItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("\(gear.brand) \(gear.name)")
                        .font(.headline)
                    if gear.isDefault {
                        Text("DEFAULT")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(StrideTheme.primaryOrange.opacity(0.15))
                            .foregroundStyle(StrideTheme.primaryOrange)
                            .clipShape(Capsule())
                    }
                }
                Text(String(format: "%.0f km terpakai • Sisa: %.0f%%", gear.currentDistanceMeters / 1000.0, gear.lifeRemainingPercentage))
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Image(systemName: gear.activityType == .run ? "shoe.fill" : "bicycle")
                .foregroundStyle(StrideTheme.primaryOrange)
        }
        .padding(.vertical, 2)
    }
}

