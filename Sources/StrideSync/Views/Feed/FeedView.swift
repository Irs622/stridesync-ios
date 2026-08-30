import SwiftUI
import SwiftData

/// Main Community Feed screen with refined iOS navigation, search, and notification center integration.
public struct FeedView: View {
    public var modelContext: ModelContext?
    @State public var viewModel: FeedViewModel
    @State private var selectedActivityForComments: ActivityRecord?
    @State private var newCommentText: String = ""
    @State private var selectedShareActivity: ActivityRecord?
    @State private var showingSearchSheet: Bool = false
    @State private var showingNotificationsSheet: Bool = false
    
    @MainActor
    public init(viewModel: FeedViewModel? = nil, modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        self._viewModel = State(initialValue: viewModel ?? FeedViewModel())
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Category Filter Pills
                    filterChipsSection
                        .padding(.top, 6)
                    
                    if viewModel.filteredActivities.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredActivities) { activity in
                                ActivityCardView(
                                    activity: activity,
                                    onKudosTapped: {
                                        viewModel.toggleKudos(for: activity)
                                    },
                                    onCommentTapped: {
                                        selectedActivityForComments = activity
                                    },
                                    onShareTapped: {
                                        selectedShareActivity = activity
                                    }
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.bottom, 28)
            }
            .background(StrideTheme.groupedBackground)
            .navigationTitle("Community Feed")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 14) {
                        Button {
                            showingSearchSheet = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.primary)
                        }
                        
                        Button {
                            showingNotificationsSheet = true
                        } label: {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSearchSheet) {
                GlobalSearchView()
            }
            .sheet(isPresented: $showingNotificationsSheet) {
                NotificationsView()
            }
            .sheet(item: $selectedActivityForComments) { activity in
                commentsSheet(for: activity)
            }
            .sheet(item: $selectedShareActivity) { activity in
                NavigationStack {
                    ScrollView {
                        SocialShareCardView(activity: activity)
                            .padding(.vertical, 20)
                    }
                    .navigationTitle("Bagikan Story")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Selesai") {
                                selectedShareActivity = nil
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.refresh(from: modelContext)
            }
        }
    }
    
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "Semua", icon: "sparkles", isSelected: viewModel.selectedFilter == nil) {
                    viewModel.selectedFilter = nil
                }
                ForEach(ActivityType.allCases) { type in
                    filterChip(title: type.rawValue, icon: type.iconName, isSelected: viewModel.selectedFilter == type) {
                        viewModel.selectedFilter = type
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func filterChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? StrideTheme.primaryOrange : StrideTheme.cardBackground)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
            .shadow(color: isSelected ? StrideTheme.primaryOrange.opacity(0.3) : Color.black.opacity(0.02), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 68))
                .foregroundStyle(StrideTheme.primaryOrange.opacity(0.6))
            
            Text("Belum Ada Aktivitas")
                .font(.system(.title3, design: .rounded, weight: .bold))
            
            Text("Mulai rekam latihan pertamamu atau ikuti teman untuk melihat aktivitas mereka di linimasa ini.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func commentsSheet(for activity: ActivityRecord) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                let comments = viewModel.commentsByActivityId[activity.id] ?? []
                if comments.isEmpty {
                    VStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.secondary.opacity(0.5))
                        Text("Belum Ada Komentar")
                            .font(.headline)
                        Text("Jadilah yang pertama memberikan semangat!")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                    }
                } else {
                    List(comments) { comment in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(StrideTheme.primaryOrange.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Text(comment.athleteName.prefix(1))
                                        .font(.subheadline.bold())
                                        .foregroundStyle(StrideTheme.primaryOrange)
                                }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(comment.athleteName)
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text(comment.createdAt.formatted(date: .omitted, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(Color.secondary)
                                }
                                Text(comment.message)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
                
                Divider()
                
                // Comment Input Bar
                HStack(spacing: 12) {
                    TextField("Beri semangat atau komentar...", text: $newCommentText)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Button {
                        viewModel.addComment(to: activity, athleteName: "You", message: newCommentText)
                        newCommentText = ""
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.secondary.opacity(0.3) : StrideTheme.primaryOrange)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .navigationTitle("Komentar")
        }
        .presentationDetents([.medium, .large])
    }
}
