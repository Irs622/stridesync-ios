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
            .toolbar {
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
                statBlock(title: "TOTAL WAKTU", value: "42j 15m", icon: "clock.fill", color: .blue)
                statBlock(title: "RATA-RATA PACE", value: "4:35 /km", icon: "speedometer", color: StrideTheme.athleticGreen)
            }
            .padding(.horizontal, 16)
            
            // Weekly Progress Bar Chart Simulation
            VStack(alignment: .leading, spacing: 12) {
                Text("Aktivitas 7 Hari Terakhir")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"], id: \.self) { day in
                        let height: CGFloat = day == "Sab" ? 90 : (day == "Rab" ? 65 : (day == "Min" ? 80 : 35))
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(day == "Sab" || day == "Min" ? StrideTheme.primaryOrange : StrideTheme.primaryOrange.opacity(0.35))
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
        .padding(.horizontal, 16)
    }
    
    private var trophyCaseSection: some View {
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
        .padding(16)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
    }
    
    private func statFollow(title: String, count: Int) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(.headline, design: .rounded, weight: .heavy))
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.secondary)
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
    
    public static func sampleAthlete() -> AthleteProfile {
        AthleteProfile(
            username: "budisport",
            fullName: "Budi Santoso",
            bio: "Marathon runner in training 🏃‍♂️ | 5K PB: 19:42 | Jakarta, Indonesia",
            totalDistanceMeters: 452_000.0,
            totalActivitiesCount: 48,
            totalElevationGainMeters: 3_420.0,
            followersCount: 184,
            followingCount: 129,
            trophyBadges: ["Marathon Finisher", "March 100K", "KOM Monas", "Early Bird 5AM", "Century Ride"]
        )
    }
    
    public static func sampleGear() -> [GearItem] {
        [
            GearItem(name: "Vaporfly 3", brand: "Nike", maxLifeDistanceMeters: 600_000, currentDistanceMeters: 240_000, isDefault: true, activityType: .run),
            GearItem(name: "Tarmac SL7", brand: "Specialized", maxLifeDistanceMeters: 5_000_000, currentDistanceMeters: 1_850_000, isDefault: false, activityType: .ride)
        ]
    }
}
