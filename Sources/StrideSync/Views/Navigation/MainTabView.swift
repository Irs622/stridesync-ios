import SwiftUI
import SwiftData

/// Root Tab Navigation container connecting the 5 primary pillars of the StrideSync application.
public struct MainTabView: View {
    public var modelContext: ModelContext?
    @State private var selectedTab: Int = 1
    @State private var isShowingRecordSheet: Bool = false
    @State private var finishedWorkoutData: (ActivityRecord, [TelemetrySnapshot], [SplitSnapshot])? = nil
    @State private var isShowingSummarySheet: Bool = false
    
    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Community Feed
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "newspaper.fill")
                }
                .tag(0)
            
            // Tab 2: Explore Maps & Segments
            ExploreView()
                .tabItem {
                    Label("Maps", systemImage: "map.fill")
                }
                .tag(1)
            
            // Tab 3: Record Center Action Trigger
            Color.clear
                .tabItem {
                    Label("Record", systemImage: "record.circle.fill")
                }
                .tag(2)
            
            // Tab 4: Challenges & Badges
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: "trophy.fill")
                }
                .tag(3)
            
            // Tab 5: Athlete Profile & Gear
            ProfileView()
                .tabItem {
                    Label("You", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(StrideTheme.primaryOrange)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                // Intercept center Record tab and present full HUD sheet
                isShowingRecordSheet = true
                selectedTab = oldValue
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $isShowingRecordSheet) {
            recordHUDSheetView
        }
        #else
        .sheet(isPresented: $isShowingRecordSheet) {
            recordHUDSheetView
        }
        #endif
        .sheet(isPresented: $isShowingSummarySheet) {
            if let data = finishedWorkoutData {
                ActivitySummaryView(
                    activity: data.0,
                    splits: data.2,
                    telemetryPoints: data.1,
                    onSave: {
                        // Persist to SwiftData if context available
                        if let context = modelContext {
                            context.insert(data.0)
                            try? context.save()
                        }
                        isShowingSummarySheet = false
                        finishedWorkoutData = nil
                        selectedTab = 0 // Go to Feed
                    },
                    onShare: {
                        // Action for sharing card
                    }
                )
            }
        }
    }
    
    private var recordHUDSheetView: some View {
        RecordHUDView(
            onFinish: { record, points, splits in
                isShowingRecordSheet = false
                finishedWorkoutData = (record, points, splits)
                isShowingSummarySheet = true
            },
            onDiscard: {
                isShowingRecordSheet = false
            }
        )
    }
}
