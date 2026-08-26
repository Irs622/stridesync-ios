import SwiftUI

#if os(iOS) && canImport(ActivityKit) && canImport(WidgetKit)
import ActivityKit
import WidgetKit

/// WidgetKit Live Activity & Dynamic Island UI presentation for active StrideSync workouts.
public struct WorkoutLiveActivityWidget: Widget {
    public init() {}
    
    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock Screen Banner UI
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: context.attributes.activityIconName)
                            .foregroundStyle(Color.orange)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.workoutTitle)
                        .font(.headline.bold())
                        .foregroundStyle(Color.white)
                    
                    HStack(spacing: 12) {
                        Text(context.state.formattedDistance)
                            .font(.title2.bold().monospacedDigit())
                            .foregroundStyle(Color.orange)
                        
                        Text(context.state.formattedDuration)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(Color.gray)
                        
                        Text(context.state.formattedPace)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(Color.gray)
                    }
                }
                
                Spacer()
                
                if context.state.isPaused {
                    Text("PAUSED")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundStyle(Color.yellow)
                        .clipShape(Capsule())
                } else {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(16)
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.orange)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: context.attributes.activityIconName)
                            .foregroundStyle(Color.orange)
                        Text(context.attributes.workoutTitle)
                            .font(.caption.bold())
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPaused {
                        Text("PAUSED")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.yellow)
                    } else {
                        HStack(spacing: 4) {
                            Circle().fill(Color.green).frame(width: 6, height: 6)
                            Text("REC")
                                .font(.caption2.bold())
                                .foregroundStyle(Color.green)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(context.state.formattedDistance)
                                .font(.title.bold().monospacedDigit())
                                .foregroundStyle(Color.orange)
                            Text("DISTANCE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.gray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 1) {
                            Text(context.state.formattedDuration)
                                .font(.title3.bold().monospacedDigit())
                            Text("TIME")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.gray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(context.state.formattedPace)
                                .font(.title3.bold().monospacedDigit())
                            Text("PACE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: context.attributes.activityIconName)
                    .foregroundStyle(Color.orange)
            } compactTrailing: {
                Text(context.state.formattedDistance)
                    .font(.caption2.bold().monospacedDigit())
                    .foregroundStyle(Color.orange)
            } minimal: {
                Image(systemName: context.attributes.activityIconName)
                    .foregroundStyle(Color.orange)
            }
        }
    }
}
#endif

