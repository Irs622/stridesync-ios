import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// Interactive 3D aerial flyover replay view simulating a drone camera flying over the recorded workout route.
public struct FlyoverVideoPlayerView: View {
    public let telemetryPoints: [TelemetrySnapshot]
    public let activityTitle: String
    public let totalDistanceMeters: Double
    
    @State private var isPlaying: Bool = true
    @State private var playbackSpeed: Double = 2.0
    @State private var currentFrameIndex: Int = 0
    @State private var milestones: [FlyoverMilestone] = []
    @State private var activeMilestone: FlyoverMilestone?
    @State private var cameraFrames: [FlyoverCameraAngle] = []
    
    @State private var mapPosition: MapCameraPosition = .automatic
    @Environment(\.dismiss) private var dismiss
    
    public init(
        telemetryPoints: [TelemetrySnapshot],
        activityTitle: String = "Latihan Outdoor",
        totalDistanceMeters: Double = 5000.0
    ) {
        self.telemetryPoints = telemetryPoints
        self.activityTitle = activityTitle
        self.totalDistanceMeters = totalDistanceMeters
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 3D Map View
                Map(position: $mapPosition) {
                    MapPolyline(coordinates: telemetryPoints.map { $0.coordinate })
                        .stroke(
                            LinearGradient(
                                colors: [StrideTheme.primaryOrange, StrideTheme.athleticGreen, Color.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 6
                        )
                    
                    if let active = activeMilestone {
                        Marker(active.title, coordinate: active.coordinate)
                            .tint(StrideTheme.primaryOrange)
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .ignoresSafeArea(edges: .all)
                
                // Top HUD Header
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("3D FLYOVER REPLAY 🚁")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(StrideTheme.primaryOrange)
                            Text(activityTitle)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.white.opacity(0.8))
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    // Active Milestone Popup
                    if let milestone = activeMilestone {
                        HStack(spacing: 12) {
                            Image(systemName: milestone.iconName)
                                .font(.title2.bold())
                                .foregroundStyle(StrideTheme.primaryOrange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(milestone.title)
                                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                                    .foregroundStyle(Color.white)
                                Text(milestone.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(Color.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.black.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(StrideTheme.primaryOrange.opacity(0.4), lineWidth: 1.5)
                        )
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                
                // Bottom Playback Controller Card
                VStack(spacing: 16) {
                    // Timeline Scrubber
                    VStack(spacing: 6) {
                        ProgressView(value: Double(currentFrameIndex), total: Double(max(1, cameraFrames.count - 1)))
                            .tint(StrideTheme.primaryOrange)
                        
                        HStack {
                            Text("0:00")
                                .font(.caption2.bold())
                                .foregroundStyle(Color.white.opacity(0.7))
                            Spacer()
                            let progress = cameraFrames.isEmpty ? 0 : Int((Double(currentFrameIndex) / Double(cameraFrames.count)) * 100)
                            Text("\(progress)% Rute")
                                .font(.caption2.bold())
                                .foregroundStyle(StrideTheme.primaryOrange)
                            Spacer()
                            Text(String(format: "%.1f km", totalDistanceMeters / 1000.0))
                                .font(.caption2.bold())
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                    }
                    
                    // Controls Row
                    HStack(spacing: 24) {
                        // Speed Switcher
                        Button {
                            toggleSpeed()
                        } label: {
                            Text(String(format: "%.0fx", playbackSpeed))
                                .font(.system(.caption, design: .rounded, weight: .heavy))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundStyle(Color.white)
                        }
                        
                        // Rewind
                        Button {
                            currentFrameIndex = 0
                            updateCameraPosition()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title3)
                                .foregroundStyle(Color.white)
                        }
                        
                        // Play/Pause Button
                        Button {
                            withAnimation(.snappy) {
                                isPlaying.toggle()
                            }
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(StrideTheme.primaryOrange)
                        }
                        
                        // Export Video Button
                        Button {
                            HapticFeedbackService.shared.playNotification(.success)
                        } label: {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.title3)
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("3D Flyover")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .onAppear {
                setupEngine()
            }
            .task {
                await runPlaybackLoop()
            }
        }
    }
    
    private func setupEngine() {
        let engine = FlyoverReplayEngine()
        let coords = telemetryPoints.map { $0.coordinate }
        self.cameraFrames = engine.generateCameraFrames(from: coords)
        self.milestones = engine.generateMilestones(from: telemetryPoints, totalDistanceMeters: totalDistanceMeters)
        updateCameraPosition()
    }
    
    private func toggleSpeed() {
        if playbackSpeed == 1.0 {
            playbackSpeed = 2.0
        } else if playbackSpeed == 2.0 {
            playbackSpeed = 4.0
        } else {
            playbackSpeed = 1.0
        }
    }
    
    private func updateCameraPosition() {
        guard !cameraFrames.isEmpty, currentFrameIndex < cameraFrames.count else { return }
        let frame = cameraFrames[currentFrameIndex]
        
        let camera = MapCamera(
            centerCoordinate: frame.centerCoordinate,
            distance: frame.altitudeMeters,
            heading: frame.headingDegrees,
            pitch: frame.pitchDegrees
        )
        self.mapPosition = .camera(camera)
        
        // Milestone checking
        let fraction = Double(currentFrameIndex) / Double(max(1, cameraFrames.count - 1))
        if let matched = milestones.first(where: { abs($0.progressFraction - fraction) < 0.05 }) {
            withAnimation(.snappy) {
                self.activeMilestone = matched
            }
        }
    }
    
    private func runPlaybackLoop() async {
        while !Task.isCancelled {
            let sleepNs = UInt64(100_000_000 / playbackSpeed) // Smooth 10 FPS keyframe transition
            try? await Task.sleep(nanoseconds: sleepNs)
            
            if isPlaying && !cameraFrames.isEmpty {
                await MainActor.run {
                    if currentFrameIndex < cameraFrames.count - 1 {
                        currentFrameIndex += 1
                        updateCameraPosition()
                    } else {
                        isPlaying = false
                    }
                }
            }
        }
    }
}
