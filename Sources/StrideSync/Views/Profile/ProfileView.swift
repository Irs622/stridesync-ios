import SwiftUI

/// Athlete profile screen with iOS segmented sections, statistics, trophy cases, and gear tracker.
public struct ProfileView: View {
    public var athlete: AthleteProfile
    public var gearList: [GearItem]
    
    @State private var selectedSection: Int = 0
    @State private var showingSettingsSheet: Bool = false
    
    public init(
        athlete: AthleteProfile = Self.sampleAthlete(),
        gearList: [GearItem] = Self.sampleGear()
    ) {
        self.athlete = athlete
        self.gearList = gearList
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(StrideTheme.primaryGradient)
                                .frame(width: 86, height: 86)
                                .shadow(color: StrideTheme.primaryOrange.opacity(0.3), radius: 10, y: 4)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Text(athlete.fullName)
                                    .font(.system(.title2, design: .rounded, weight: .heavy))
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Color.blue)
                            }
                            
                            Text("@\(athlete.username)")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            
                            if let bio = athlete.bio {
                                Text(bio)
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 28)
                                    .padding(.top, 2)
                            }
                        }
                        
                        // Follower & Activity Counter Trio
                        HStack(spacing: 36) {
                            statFollow(title: "Mengikuti", count: athlete.followingCount)
                            statFollow(title: "Pengikut", count: athlete.followersCount)
                            statFollow(title: "Aktivitas", count: athlete.totalActivitiesCount)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.top, 10)
                    
                    // Segmented Control
                    Picker("Kategori", selection: $selectedSection) {
                        Text("Statistik").tag(0)
                        Text("Gear Tracker").tag(1)
                        Text("Piala (\(athlete.trophyBadges.count))").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    
                    if selectedSection == 0 {
                        statisticsSection
                    } else if selectedSection == 1 {
                        gearTrackerSection
                    } else {
                        trophyCaseSection
                    }
                }
                .padding(.bottom, 32)
            }
            .background(StrideTheme.groupedBackground)
            .navigationTitle("Profil")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profil")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                ProfileSettingsView()
            }
        }
    }
    
    // MARK: - Sections
    
    private var statisticsSection: some View {
        VStack(spacing: 14) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statBlock(title: "TOTAL JARAK", value: athlete.formattedTotalDistance, icon: "figure.run", color: StrideTheme.primaryOrange)
                statBlock(title: "TOTAL ELEVASI", value: String(format: "%.0f m", athlete.totalElevationGainMeters), icon: "mountain.2.fill", color: .purple)
                statBlock(title: "TOTAL WAKTU", value: athlete.totalActivitiesCount == 0 ? "0j 0m" : "42j 15m", icon: "clock.fill", color: .blue)
                statBlock(title: "RATA-RATA PACE", value: athlete.totalDistanceMeters == 0 ? "--:--" : "4:35 /km", icon: "speedometer", color: StrideTheme.athleticGreen)
            }
            .padding(.horizontal, 16)
            
            // Physiological Recovery & Readiness Gauge
            RecoveryGaugeView()
                .padding(.horizontal, 16)
            
            // Annual 52-Week Activity Heatmap Matrix
            annualHeatmapCard
            
            // Feature Shortcuts (Personal Global Heatmap & BLE Sensors)
            VStack(spacing: 10) {
                NavigationLink {
                    PersonalGlobalHeatmapView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .foregroundStyle(StrideTheme.primaryOrange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Heatmap Global Pribadi")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.primary)
                            Text("Lihat jejak rute seumur hidup di peta satelit")
                                .font(.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(14)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    VO2MaxPredictorView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "lungs.fill")
                            .foregroundStyle(StrideTheme.primaryOrange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("VO2 Max & Prediksi Lomba")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.primary)
                            Text("Kapasitas aerobik & estimasi waktu finish 5K, 10K, 21K, 42K")
                                .font(.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(14)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    SafetyBeaconSettingsView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundStyle(Color.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Live Safety Beacon & Kontak Darurat")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.primary)
                            Text("Bagikan link live tracking & deteksi jatuh keras")
                                .font(.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(14)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    BLESensorsSettingsView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sensor.fill")
                            .foregroundStyle(StrideTheme.athleticGreen)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sensor Eksternal (Bluetooth BLE)")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.primary)
                            Text("Hubungkan Garmin HRM, Polar, Power Meter")
                                .font(.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(14)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            
            // Weekly Progress Bar Chart Simulation
            VStack(alignment: .leading, spacing: 12) {
                Text("Aktivitas 7 Hari Terakhir")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"], id: \.self) { day in
                        let height: CGFloat = athlete.totalActivitiesCount == 0 ? 8 : (day == "Sab" ? 90 : (day == "Rab" ? 65 : (day == "Min" ? 80 : 35)))
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(athlete.totalActivitiesCount == 0 ? Color.secondary.opacity(0.15) : (day == "Sab" || day == "Min" ? StrideTheme.primaryOrange : StrideTheme.primaryOrange.opacity(0.35)))
                                .frame(height: height)
                            
                            Text(day)
                                .font(.caption2.bold())
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 110)
                .padding(.top, 8)
            }
            .padding(16)
            .background(StrideTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal, 16)
        }
    }
    
    private var gearTrackerSection: some View {
        VStack(spacing: 12) {
            if gearList.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "shoe.2.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(StrideTheme.primaryOrange.opacity(0.6))
                    Text("Belum Ada Gear Terdaftar")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text("Daftarkan sepatu lari atau sepeda untuk memantau jarak tempuh pemakaian.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(StrideTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ForEach(gearList) { gear in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: gear.activityType == .run ? "shoe.fill" : "bicycle")
                                .foregroundStyle(StrideTheme.primaryOrange)
                            Text("\(gear.brand) \(gear.name)")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            
                            Spacer()
                            
                            Text(String(format: "%.0f / %.0f km", gear.currentDistanceMeters / 1000.0, gear.maxLifeDistanceMeters / 1000.0))
                                .font(.caption.monospacedDigit().bold())
                                .foregroundStyle(Color.secondary)
                        }
                        
                        // Progress bar
                        GeometryReader { geo in
                            let progress = min(1.0, gear.currentDistanceMeters / gear.maxLifeDistanceMeters)
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 8)
                                Capsule()
                                    .fill(progress > 0.85 ? Color.red : StrideTheme.primaryOrange)
                                    .frame(width: geo.size.width * CGFloat(progress), height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        HStack {
                            Text(String(format: "Sisa umur pakai: %.0f%%", gear.lifeRemainingPercentage))
                                .font(.caption2.bold())
                                .foregroundStyle(gear.lifeRemainingPercentage < 20 ? Color.red : Color.secondary)
                            Spacer()
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
                    }
                    .padding(16)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var trophyCaseSection: some View {
        VStack(spacing: 20) {
            if athlete.trophyBadges.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.yellow.opacity(0.7))
                    Text("Lemari Piala Masih Kosong")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text("Selesaikan tantangan bulanan atau pecahkan rekor jarak untuk mengoleksi lencana piala di sini.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(StrideTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                // Achievement Badges
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(Color.yellow)
                        Text("Lencana Prestasi Komunitas")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(athlete.trophyBadges, id: \.self) { badge in
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color.yellow.opacity(0.15))
                                    .frame(width: 70, height: 70)
                                    .overlay {
                                        Image(systemName: "trophy.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.yellow)
                                    }
                                Text(badge)
                                    .font(.caption2.bold())
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(16)
                .background(StrideTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var annualHeatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Log Konsistensi Tahunan")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Spacer()
                Text("\(athlete.totalActivitiesCount) Sesi")
                    .font(.caption.bold())
                    .foregroundStyle(StrideTheme.primaryOrange)
            }
            
            // 52-Column Grid Simulation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(0..<52, id: \.self) { week in
                        VStack(spacing: 3) {
                            ForEach(0..<7, id: \.self) { day in
                                let intensity = heatmapIntensity(week: week, day: day)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(heatmapColor(for: intensity))
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            HStack {
                Text("Kurang")
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                HStack(spacing: 3) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(heatmapColor(for: level))
                            .frame(width: 8, height: 8)
                    }
                }
                Text("Banyak")
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
    }
    
    private func heatmapIntensity(week: Int, day: Int) -> Int {
        guard athlete.totalActivitiesCount > 0 else { return 0 }
        let seed = (week * 7 + day) % 31
        if seed % 7 == 0 || seed % 11 == 0 {
            return 0 // Rest day
        } else if seed % 5 == 0 {
            return 4 // Long run / race
        } else if seed % 3 == 0 {
            return 3 // Tempo
        } else if seed % 2 == 0 {
            return 2 // Easy run
        } else {
            return 1 // Recovery
        }
    }
    
    private func heatmapColor(for intensity: Int) -> Color {
        switch intensity {
        case 0: return Color.secondary.opacity(0.12)
        case 1: return StrideTheme.primaryOrange.opacity(0.3)
        case 2: return StrideTheme.primaryOrange.opacity(0.55)
        case 3: return StrideTheme.primaryOrange.opacity(0.8)
        case 4: return StrideTheme.primaryOrange
        default: return Color.secondary.opacity(0.12)
        }
    }
    
    private func statBlock(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .heavy))
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .tracking(0.5)
        }
        .padding(14)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func statFollow(title: String, count: Int) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(.headline, design: .rounded, weight: .bold))
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.secondary)
        }
    }
    
    public static func sampleAthlete() -> AthleteProfile {
        AthleteProfile(
            username: "athlete",
            fullName: "Atlet StrideSync",
            bio: "Selamat datang di StrideSync! Mulai lari untuk memecahkan rekor pertamamu.",
            totalDistanceMeters: 0.0,
            totalActivitiesCount: 0,
            totalElevationGainMeters: 0.0,
            followersCount: 0,
            followingCount: 0,
            trophyBadges: []
        )
    }
    
    public static func sampleGear() -> [GearItem] {
        []
    }
}
