import SwiftUI
#if canImport(WidgetKit)
import WidgetKit

public struct WeeklyMileageEntry: TimelineEntry {
    public let date: Date
    public let weeklyDistanceKm: Double
    public let targetDistanceKm: Double
    
    public init(date: Date, weeklyDistanceKm: Double, targetDistanceKm: Double) {
        self.date = date
        self.weeklyDistanceKm = weeklyDistanceKm
        self.targetDistanceKm = targetDistanceKm
    }
}

public struct WeeklyMileageProvider: TimelineProvider {
    public init() {}
    
    public func placeholder(in context: Context) -> WeeklyMileageEntry {
        WeeklyMileageEntry(date: Date(), weeklyDistanceKm: 42.5, targetDistanceKm: 50.0)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (WeeklyMileageEntry) -> Void) {
        completion(WeeklyMileageEntry(date: Date(), weeklyDistanceKm: 42.5, targetDistanceKm: 50.0))
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyMileageEntry>) -> Void) {
        let entry = WeeklyMileageEntry(date: Date(), weeklyDistanceKm: 42.5, targetDistanceKm: 50.0)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

public struct WeeklyMileageWidgetView: View {
    public var entry: WeeklyMileageEntry
    
    public init(entry: WeeklyMileageEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.run")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("Weekly Distance")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            Text(String(format: "%.1f km", entry.weeklyDistanceKm))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            ProgressView(value: min(entry.weeklyDistanceKm / entry.targetDistanceKm, 1.0))
                .tint(.orange)
            
            Text(String(format: "Target: %.0f km", entry.targetDistanceKm))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Weekly distance: \(String(format: "%.1f", entry.weeklyDistanceKm)) kilometers of \(String(format: "%.0f", entry.targetDistanceKm)) kilometers target")
    }
}

public struct QuickStartWorkoutWidgetView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "play.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Start Workout")
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding()
        .accessibilityLabel("Start Workout Shortcut")
    }
}
#endif
