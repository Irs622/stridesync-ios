import SwiftUI

/// Ultra-compact OLED dark theme workout HUD designed specifically for Apple Watch display.
public struct WatchWorkoutHUDView: View {
    @State private var engine = WatchWorkoutEngine.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Heart Rate with pulsing icon
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(Color.red)
                Text(engine.heartRateBpm > 0 ? "\(engine.heartRateBpm)" : "--")
                    .font(.system(.title3, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color.white)
                Text("BPM")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.gray)
                
                Spacer()
                
                // Status pill
                Text(engine.state.rawValue)
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(engine.state == .running ? StrideTheme.athleticGreen.opacity(0.2) : Color.yellow.opacity(0.2))
                    .foregroundStyle(engine.state == .running ? StrideTheme.athleticGreen : Color.yellow)
                    .clipShape(Capsule())
            }
            
            // Distance (Primary Metric)
            VStack(alignment: .leading, spacing: 0) {
                Text(String(format: "%.2f", engine.distanceMeters / 1000.0))
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(StrideTheme.primaryOrange)
                Text("KILOMETERS")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Color.gray)
            }
            
            // Time & Pace Dual Grid
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("TIME")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.gray)
                    Text(engine.formattedDuration)
                        .font(.system(.headline, design: .rounded, weight: .heavy))
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text("PACE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.gray)
                    Text("\(engine.formattedPace)/km")
                        .font(.system(.headline, design: .rounded, weight: .heavy))
                        .foregroundStyle(Color.white)
                }
            }
            
            Spacer()
            
            // Action Control Row
            HStack(spacing: 8) {
                if engine.state == .notStarted {
                    Button {
                        engine.startStandaloneWorkout()
                    } label: {
                        Text("START")
                            .font(.system(.caption, design: .rounded, weight: .heavy))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(StrideTheme.primaryGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                } else if engine.state == .running {
                    Button {
                        engine.pauseStandaloneWorkout()
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(.caption.bold())
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Color.yellow.opacity(0.8))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                } else if engine.state == .paused {
                    Button {
                        engine.resumeStandaloneWorkout()
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.caption.bold())
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(StrideTheme.athleticGreen)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        _ = engine.finishStandaloneWorkout()
                    } label: {
                        Image(systemName: "flag.checkered")
                            .font(.caption.bold())
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(StrideTheme.primaryOrange)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(8)
        .background(Color.black)
    }
}

