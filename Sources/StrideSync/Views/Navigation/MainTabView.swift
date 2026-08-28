import SwiftUI
import SwiftData

/// Root Tab Navigation container connecting the 5 primary pillars of the StrideSync application.
public struct MainTabView: View {
    public var modelContext: ModelContext?
    @State private var selectedTab: Int = 1
    @State private var isShowingRecordSheet: Bool = false
    @State private var finishedWorkoutData: (ActivityRecord, [TelemetrySnapshot], [SplitSnapshot], [SegmentEffort])? = nil
    @State private var isShowingSummarySheet: Bool = false
    @State private var isShowingShareSheet: Bool = false
    
    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Community Feed
            FeedView(modelContext: modelContext)
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
                NavigationStack {
                    ActivitySummaryView(
                        activity: data.0,
                        splits: data.2,
                        telemetryPoints: data.1,
                        segmentEfforts: data.3,
                        onSave: {
                            // Persist to SwiftData if context available
                            if let context = modelContext {
                                let record = data.0
                                
                                // Map snapshots into SwiftData models
                                for pt in data.1 {
                                    let modelPt = TelemetryPoint(
                                        timestamp: pt.timestamp,
                                        latitude: pt.latitude,
                                        longitude: pt.longitude,
                                        altitude: pt.altitude,
                                        speedMps: pt.speedMps,
                                        horizontalAccuracy: pt.horizontalAccuracy,
                                        heartRate: pt.heartRate,
                                        cadence: pt.cadence
                                    )
                                    record.telemetryPoints.append(modelPt)
                                }
                                
                                for sp in data.2 {
                                    let modelSp = DistanceSplit(
                                        splitIndex: sp.splitIndex,
                                        distanceMeters: sp.distanceMeters,
                                        durationSeconds: sp.durationSeconds,
                                        averagePaceSecondsPerKm: sp.averagePaceSecondsPerKm,
                                        elevationChangeMeters: sp.elevationChangeMeters,
                                        averageHeartRate: sp.averageHeartRate
                                    )
                                    record.splits.append(modelSp)
                                }
                                
                                context.insert(record)
                                
                                // Update Gear mileage
                                if let gearName = record.gearName, !gearName.isEmpty {
                                    let descriptor = FetchDescriptor<GearItem>()
                                    if let gears = try? context.fetch(descriptor) {
                                        for gear in gears where "\(gear.brand) \(gear.name)" == gearName || gear.name == gearName {
                                            gear.currentDistanceMeters += record.distanceMeters
                                        }
                                    }
                                }
                                
                                // Update Segment attempts & KOM records
                                for effort in data.3 {
                                    let segmentId = effort.segmentId
                                    let descriptor = FetchDescriptor<Segment>(predicate: #Predicate { $0.id == segmentId })
                                    if let matchedSegments = try? context.fetch(descriptor), let seg = matchedSegments.first {
                                        seg.totalEffortsCount += 1
                                        if effort.isKOM || seg.komTimeSeconds == nil || effort.elapsedTimeSeconds < (seg.komTimeSeconds ?? .infinity) {
                                            seg.komTimeSeconds = effort.elapsedTimeSeconds
                                            seg.komAthleteName = effort.athleteName
                                        }
                                    }
                                }
                                
                                try? context.save()
                            }
                            
                            // Enqueue for offline sync
                            BackgroundSyncManager.shared.enqueueForUpload(recordID: data.0.id)
                            AnalyticsService.shared.logEvent(.workoutFinished(
                                distanceKm: data.0.distanceMeters / 1000.0,
                                durationSec: data.0.durationSeconds
                            ))
                            
                            // HealthKit async save
                            if UserSettingsManager.shared.healthKitSyncEnabled {
                                Task {
                                    _ = await HealthKitManager.shared.saveWorkout(
                                        activityType: data.0.activityType,
                                        startDate: data.0.startTime,
                                        endDate: data.0.endTime,
                                        distanceMeters: data.0.distanceMeters,
                                        caloriesBurned: data.0.caloriesBurned
                                    )
                                }
                            }
                            
                            isShowingSummarySheet = false
                            finishedWorkoutData = nil
                            selectedTab = 0 // Go to Feed
                        },
                        onShare: {
                            isShowingShareSheet = true
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let data = finishedWorkoutData {
                NavigationStack {
                    ScrollView {
                        SocialShareCardView(
                            activity: data.0,
                            coordinates: data.1.map { $0.coordinate }
                        )
                        .padding(.vertical, 20)
                    }
                    .navigationTitle("Bagikan Story")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Selesai") {
                                isShowingShareSheet = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var recordHUDSheetView: some View {
        RecordHUDView(
            onFinish: { record, points, splits, efforts in
                isShowingRecordSheet = false
                finishedWorkoutData = (record, points, splits, efforts)
                isShowingSummarySheet = true
            },
            onDiscard: {
                isShowingRecordSheet = false
            }
        )
    }
}
