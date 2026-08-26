import SwiftUI

/// Screen displaying monthly, seasonal, and club fitness challenges with iOS native cards and progress bars.
public struct ChallengesView: View {
    @State public var challenges: [Challenge]
    
    public init(challenges: [Challenge] = Self.sampleChallenges()) {
        self._challenges = State(initialValue: challenges)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tantangan Bulan Ini")
                            .font(.system(.title2, design: .rounded, weight: .heavy))
                        Text("Dorong batas kemampuanmu dan raih lencana pencapaian eksklusif.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Challenges List
                    LazyVStack(spacing: 16) {
                        ForEach($challenges) { $challenge in
                            challengeCard(challenge: $challenge)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 28)
            }
            .background(StrideTheme.groupedBackground)
            .navigationTitle("Tantangan")
        }
    }
    
    private func challengeCard(challenge: Binding<Challenge>) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Circle()
                    .fill(challenge.wrappedValue.isCompleted ? Color.yellow.opacity(0.2) : StrideTheme.primaryOrange.opacity(0.15))
                    .frame(width: 54, height: 54)
                    .overlay {
                        Image(systemName: challenge.wrappedValue.badgeIconName)
                            .font(.title2.bold())
                            .foregroundStyle(challenge.wrappedValue.isCompleted ? Color.yellow : StrideTheme.primaryOrange)
                    }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(challenge.wrappedValue.title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text(challenge.wrappedValue.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if challenge.wrappedValue.isCompleted {
                    Text("SELESAI")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundStyle(Color.yellow)
                        .clipShape(Capsule())
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 8)
                        
                        if challenge.wrappedValue.isCompleted {
                            Capsule()
                                .fill(Color.yellow)
                                .frame(width: geo.size.width * CGFloat(challenge.wrappedValue.progressFraction), height: 8)
                        } else {
                            Capsule()
                                .fill(StrideTheme.primaryGradient)
                                .frame(width: geo.size.width * CGFloat(challenge.wrappedValue.progressFraction), height: 8)
                        }
                    }
                }
                .frame(height: 8)
                
                HStack {
                    let currentKm = challenge.wrappedValue.currentProgressMeters / 1000.0
                    let targetKm = challenge.wrappedValue.targetDistanceMeters / 1000.0
                    Text(String(format: "%.1f / %.1f km", currentKm, targetKm))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text(String(format: "%.0f%% Selesai", challenge.wrappedValue.progressFraction * 100))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
            }
            
            // Join / Joined Button
            Button {
                withAnimation(.spring()) {
                    challenge.wrappedValue.isJoined.toggle()
                }
            } label: {
                Text(challenge.wrappedValue.isJoined ? "Telah Diikuti ✓" : "Ikuti Tantangan")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(challenge.wrappedValue.isJoined ? Color.primary : Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(challenge.wrappedValue.isJoined ? Color.secondary.opacity(0.12) : StrideTheme.primaryOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
    }
    
    public static func sampleChallenges() -> [Challenge] {
        let now = Date()
        let endOfMonth = Calendar.current.date(byAdding: .day, value: 20, to: now) ?? now
        
        return [
            Challenge(
                title: "Tantangan Lari 100 km",
                subtitle: "Selesaikan total 100 kilometer lari dalam bulan ini.",
                targetDistanceMeters: 100_000.0,
                currentProgressMeters: 64_200.0,
                activityType: .run,
                startDate: now,
                endDate: endOfMonth,
                badgeIconName: "figure.run",
                isJoined: true
            ),
            Challenge(
                title: "Gran Fondo 100 km Sepeda",
                subtitle: "Gowes 100 kilometer dalam satu sesi latihan.",
                targetDistanceMeters: 100_000.0,
                currentProgressMeters: 100_000.0,
                activityType: .ride,
                startDate: now,
                endDate: endOfMonth,
                badgeIconName: "trophy.fill",
                isJoined: true
            ),
            Challenge(
                title: "Tantangan Elevasi 2000m",
                subtitle: "Taklukkan total 2.000 meter ketinggian tanjakan.",
                targetDistanceMeters: 2_000.0,
                currentProgressMeters: 850.0,
                activityType: .hike,
                startDate: now,
                endDate: endOfMonth,
                badgeIconName: "mountain.2.fill",
                isJoined: false
            )
        ]
    }
}
