import SwiftUI

/// Segment detail and competitive leaderboard view (KOM/QOM, Personal Records, and rankings).
public struct SegmentLeaderboardView: View {
    public let segment: Segment
    public let entries: [LeaderboardEntry]
    
    public init(segment: Segment, entries: [LeaderboardEntry] = []) {
        self.segment = segment
        self.entries = entries.isEmpty ? Self.sampleEntries() : entries
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Segment Header Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        HStack(spacing: 5) {
                            Image(systemName: segment.activityType.iconName)
                            Text(segment.activityType.rawValue.uppercased())
                        }
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(StrideTheme.primaryOrange)
                        
                        Spacer()
                        
                        Text("\(segment.totalEffortsCount) Total Percobaan")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Text(segment.name)
                        .font(.system(.title2, design: .rounded, weight: .heavy))
                    
                    // Segment Stats Triad
                    HStack(spacing: 20) {
                        statLabel(title: "JARAK", value: String(format: "%.2f km", segment.distanceMeters / 1000.0))
                        statLabel(title: "KEMIRINGAN", value: String(format: "%.1f%%", segment.averageGradePercent))
                        statLabel(title: "ELEVASI", value: String(format: "%.0f m", segment.elevationGainMeters))
                    }
                    .padding(.top, 4)
                }
                .padding(18)
                .background(StrideTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 16)
                
                // KOM Crown Holder Banner
                if let komTime = segment.komTimeSeconds, let komAthlete = segment.komAthleteName {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 52, height: 52)
                                .shadow(color: Color.yellow.opacity(0.4), radius: 8, y: 3)
                            
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundStyle(Color.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("KING OF THE MOUNTAIN (KOM)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(1.0)
                            Text(komAthlete)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                        }
                        
                        Spacer()
                        
                        let min = Int(komTime) / 60
                        let sec = Int(komTime) % 60
                        Text(String(format: "%d:%02d", min, sec))
                            .font(.system(.title3, design: .rounded, weight: .heavy))
                            .monospacedDigit()
                            .foregroundStyle(StrideTheme.primaryOrange)
                    }
                    .padding(16)
                    .background(Color.yellow.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                }
                
                // Leaderboard Table
                VStack(alignment: .leading, spacing: 12) {
                    Text("Papan Peringkat Keseluruhan")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        ForEach(entries) { entry in
                            HStack(spacing: 14) {
                                // Rank Badge
                                rankBadge(rank: entry.rank)
                                    .frame(width: 32)
                                
                                // Athlete Name
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text(entry.athleteName)
                                            .font(.system(.subheadline, design: .rounded, weight: entry.isCurrentUser ? .heavy : .bold))
                                            .foregroundStyle(entry.isCurrentUser ? StrideTheme.primaryOrange : Color.primary)
                                        
                                        if entry.isCrownHolder {
                                            Image(systemName: "crown.fill")
                                                .font(.caption2)
                                                .foregroundStyle(Color.yellow)
                                        }
                                    }
                                    Text(entry.dateFormatted)
                                        .font(.caption2)
                                        .foregroundStyle(Color.secondary)
                                }
                                
                                Spacer()
                                
                                // Time & Pace
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(entry.formattedTime)
                                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        .monospacedDigit()
                                    Text(entry.formattedSpeedOrPace)
                                        .font(.caption2.monospacedDigit())
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            
                            if entry.id != entries.last?.id {
                                Divider().padding(.leading, 62)
                            }
                        }
                    }
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .background(StrideTheme.groupedBackground)
        .navigationTitle("Segmen")
    }
    
    private func statLabel(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
        }
    }
    
    private func rankBadge(rank: Int) -> some View {
        Group {
            switch rank {
            case 1:
                Text("🥇").font(.title3)
            case 2:
                Text("🥈").font(.title3)
            case 3:
                Text("🥉").font(.title3)
            default:
                Text("\(rank)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
    
    private static func sampleEntries() -> [LeaderboardEntry] {
        [
            LeaderboardEntry(rank: 1, athleteName: "Marcus Vance", formattedTime: "2:45", formattedSpeedOrPace: "2:17 /km", dateFormatted: "12 Ags 2026", isCrownHolder: true),
            LeaderboardEntry(rank: 2, athleteName: "Elena Rostova", formattedTime: "2:52", formattedSpeedOrPace: "2:23 /km", dateFormatted: "18 Ags 2026"),
            LeaderboardEntry(rank: 3, athleteName: "David Chen", formattedTime: "3:01", formattedSpeedOrPace: "2:30 /km", dateFormatted: "21 Ags 2026"),
            LeaderboardEntry(rank: 4, athleteName: "Budi Santoso (You)", formattedTime: "3:14", formattedSpeedOrPace: "2:41 /km", dateFormatted: "Kemarin", isCurrentUser: true),
            LeaderboardEntry(rank: 5, athleteName: "Sarah Jenkins", formattedTime: "3:22", formattedSpeedOrPace: "2:48 /km", dateFormatted: "10 Ags 2026")
        ]
    }
}
