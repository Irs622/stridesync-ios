import SwiftUI

/// Global search screen for finding athletes, workouts, segments, and community clubs.
public struct GlobalSearchView: View {
    @State public var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var followedAthleteIds: Set<UUID> = []
    @State private var joinedClubIds: Set<UUID> = []
    
    public init(viewModel: SearchViewModel = SearchViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Input Bar
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.secondary)
                        TextField("Cari atlet, rute, segmen, atau klub...", text: $viewModel.searchQuery)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                viewModel.addRecentSearch(viewModel.searchQuery)
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(StrideTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Scope Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SearchScope.allCases) { scope in
                            Button {
                                viewModel.selectedScope = scope
                            } label: {
                                Text(scope.rawValue)
                                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(viewModel.selectedScope == scope ? StrideTheme.primaryOrange : StrideTheme.cardBackground)
                                    .foregroundStyle(viewModel.selectedScope == scope ? Color.white : Color.primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                
                Divider()
                
                // Content Area
                if viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    recentSearchesView
                } else if !viewModel.hasResults {
                    noResultsView
                } else {
                    searchResultsListView
                }
            }
            .background(StrideTheme.groupedBackground)
            .navigationTitle("Pencarian")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !viewModel.recentSearches.isEmpty {
                HStack {
                    Text("Pencarian Terakhir")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Spacer()
                    Button("Hapus Semua") {
                        viewModel.clearRecentSearches()
                    }
                    .font(.caption.bold())
                    .foregroundStyle(StrideTheme.primaryOrange)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.recentSearches, id: \.self) { search in
                        Button {
                            viewModel.searchQuery = search
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption2)
                                Text(search)
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(StrideTheme.cardBackground)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
    
    private var searchResultsListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // Athletes Section
                if (viewModel.selectedScope == .all || viewModel.selectedScope == .athletes) && !viewModel.filteredAthletes.isEmpty {
                    sectionHeader("Atlet (\(viewModel.filteredAthletes.count))")
                    ForEach(viewModel.filteredAthletes) { athlete in
                        athleteResultCard(athlete: athlete)
                            .padding(.horizontal, 16)
                    }
                }
                
                // Activities Section
                if (viewModel.selectedScope == .all || viewModel.selectedScope == .activities) && !viewModel.filteredActivities.isEmpty {
                    sectionHeader("Aktivitas (\(viewModel.filteredActivities.count))")
                    ForEach(viewModel.filteredActivities) { activity in
                        ActivityCardView(activity: activity)
                            .padding(.horizontal, 16)
                    }
                }
                
                // Segments Section
                if (viewModel.selectedScope == .all || viewModel.selectedScope == .segments) && !viewModel.filteredSegments.isEmpty {
                    sectionHeader("Segmen (\(viewModel.filteredSegments.count))")
                    ForEach(viewModel.filteredSegments) { segment in
                        NavigationLink(destination: SegmentLeaderboardView(segment: segment)) {
                            segmentResultCard(segment: segment)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Clubs Section
                if (viewModel.selectedScope == .all || viewModel.selectedScope == .clubs) && !viewModel.filteredClubs.isEmpty {
                    sectionHeader("Klub Komunitas (\(viewModel.filteredClubs.count))")
                    ForEach(viewModel.filteredClubs) { club in
                        clubResultCard(club: club)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(.headline, design: .rounded, weight: .heavy))
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 20)
            .padding(.top, 6)
    }
    
    private func athleteResultCard(athlete: AthleteProfile) -> some View {
        let isFollowing = followedAthleteIds.contains(athlete.id)
        return HStack(spacing: 12) {
            Circle()
                .fill(StrideTheme.primaryGradient)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.white)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(athlete.fullName)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.blue)
                }
                Text("@\(athlete.username)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            Button(isFollowing ? "Mengikuti" : "Ikuti") {
                if isFollowing {
                    followedAthleteIds.remove(athlete.id)
                    HapticFeedbackService.shared.playImpact(.light)
                } else {
                    followedAthleteIds.insert(athlete.id)
                    HapticFeedbackService.shared.playNotification(.success)
                }
            }
            .font(.caption.bold())
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(isFollowing ? Color.secondary.opacity(0.15) : StrideTheme.primaryOrange)
            .foregroundStyle(isFollowing ? Color.primary : Color.white)
            .clipShape(Capsule())
        }
        .padding(14)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func segmentResultCard(segment: Segment) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: segment.activityType.iconName)
                        .font(.caption.bold())
                    Text(segment.activityType.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(StrideTheme.primaryOrange)
                
                Text(segment.name)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                
                Text(String(format: "%.1f km • Elevasi +%.0f m", segment.distanceMeters / 1000.0, segment.elevationGainMeters))
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color.secondary)
        }
        .padding(14)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func clubResultCard(club: ClubItem) -> some View {
        let isJoined = joinedClubIds.contains(club.id)
        return HStack(spacing: 12) {
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(Color.purple)
                }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(club.name)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                Text("\(club.memberCount + (isJoined ? 1 : 0)) Anggota • \(club.location)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            Button(isJoined ? "Tergabung" : "Gabung") {
                if isJoined {
                    joinedClubIds.remove(club.id)
                    HapticFeedbackService.shared.playImpact(.light)
                } else {
                    joinedClubIds.insert(club.id)
                    HapticFeedbackService.shared.playNotification(.success)
                }
            }
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isJoined ? StrideTheme.athleticGreen.opacity(0.15) : Color.secondary.opacity(0.12))
            .foregroundStyle(isJoined ? StrideTheme.athleticGreen : Color.primary)
            .clipShape(Capsule())
        }
        .padding(14)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 52))
                .foregroundStyle(Color.secondary.opacity(0.4))
            
            Text("Tidak Ditemukan Hasil")
                .font(.system(.title3, design: .rounded, weight: .bold))
            
            Text("Coba cari dengan kata kunci lain atau periksa ejaan Anda.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// Helper FlowLayout for wrapping tags in multiple horizontal lines.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        height = y + maxHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}

