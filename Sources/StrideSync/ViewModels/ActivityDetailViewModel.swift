import Foundation
import SwiftUI

/// Observable ViewModel preparing detailed analytics, splits comparison, and share options for an activity.
@Observable
@MainActor
public final class ActivityDetailViewModel {
    public let activity: ActivityRecord
    public var splits: [SplitSnapshot]
    public var telemetryPoints: [TelemetrySnapshot]
    public var isShowingShareSheet: Bool = false
    public var isShowingGPXExport: Bool = false
    
    public init(
        activity: ActivityRecord,
        splits: [SplitSnapshot] = [],
        telemetryPoints: [TelemetrySnapshot] = []
    ) {
        self.activity = activity
        self.splits = splits
        self.telemetryPoints = telemetryPoints
        
        if splits.isEmpty && !telemetryPoints.isEmpty {
            self.splits = SplitCalculator().calculateSplits(from: telemetryPoints)
        }
    }
    
    /// Finds the index of the fastest kilometer split.
    public var fastestSplitIndex: Int? {
        splits.min(by: { $0.averagePaceSecondsPerKm < $1.averagePaceSecondsPerKm })?.splitIndex
    }
    
    /// Exports the current activity data as a GPX XML string.
    public func exportGPX() -> String {
        GPXService().exportToGPX(activity: activity, points: telemetryPoints)
    }
}

