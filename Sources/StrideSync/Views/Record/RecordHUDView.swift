import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// Pro-grade live workout HUD recording screen with OLED dark theme, neon accents, and MapKit route view.
public struct RecordHUDView: View {
    @State public var viewModel: RecordViewModel
    public var onFinish: ((ActivityRecord, [TelemetrySnapshot], [SplitSnapshot], [SegmentEffort]) -> Void)?
    public var onDiscard: (() -> Void)?
    
    @State private var showingFinishConfirmation: Bool = false
    @State private var showingDiscardConfirmation: Bool = false
    @State private var showingPacingTargetSheet: Bool = false
    
    public init(
        viewModel: RecordViewModel = RecordViewModel(),
        onFinish: ((ActivityRecord, [TelemetrySnapshot], [SplitSnapshot], [SegmentEffort]) -> Void)? = nil,
        onDiscard: (() -> Void)? = nil
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onFinish = onFinish
        self.onDiscard = onDiscard
    }
    
    public var body: some View {
        ZStack {
            // Deep OLED athletic background
            StrideTheme.hudDark
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header: Activity Selector & Status
                topHeaderView
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                
                // Active Turn-by-Turn Navigation Banner (if route navigation active)
                if let guidance = viewModel.activeNavigationGuidance {
                    NavigationHUDCardView(guidance: guidance) {
                        viewModel.activeNavigationEngine = nil
                        viewModel.activeNavigationGuidance = nil
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                }
                
                // Active Virtual Ghost Runner Banner (if ghost runner active)
                if let ghostDelta = viewModel.ghostRunnerDelta, viewModel.trackingState == .recording {
                    GhostRunnerHUDCardView(delta: ghostDelta)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
                
                // Live Route Map Preview
                liveMapPreview
                    .frame(height: viewModel.activeNavigationGuidance != nil ? 150 : 190)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                
                // Primary Hero Metric: Distance & Pacing Coach Delta
                VStack(spacing: 2) {
                    Text(viewModel.formattedDistance)
                        .font(.system(size: 68, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.white)
                        .accessibilityIdentifier("hud_distance_text")
                    
                    HStack(spacing: 8) {
                        Text("KILOMETERS")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(StrideTheme.primaryOrange)
                            .tracking(3.0)
                        
                        if let feedback = viewModel.pacingFeedback, viewModel.trackingState == .recording {
                            Text(feedback.formattedDelta)
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(feedback.isAhead ? StrideTheme.athleticGreen.opacity(0.25) : StrideTheme.primaryOrange.opacity(0.25))
                                .foregroundStyle(feedback.isAhead ? StrideTheme.athleticGreen : StrideTheme.primaryOrange)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Distance: \(viewModel.formattedDistance) kilometers")
                
                // Secondary Metrics 2x2 Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    metricCard(
                        title: "TIME",
                        value: viewModel.formattedDuration,
                        unit: "",
                        icon: "stopwatch.fill"
                    )
                    metricCard(
                        title: "PACE",
                        value: viewModel.formattedCurrentPace,
                        unit: viewModel.paceOrSpeedUnit,
                        icon: "speedometer"
                    )
                    metricCard(
                        title: "ELEV GAIN",
                        value: String(format: "%.0f", viewModel.totalElevationGainMeters),
                        unit: "m",
                        icon: "mountain.2.fill"
                    )
                    metricCard(
                        title: "HEART RATE",
                        value: viewModel.currentHeartRate != nil ? "\(viewModel.currentHeartRate!)" : "--",
                        unit: "bpm",
                        icon: "heart.fill",
                        iconColor: .red
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Spacer()
                
                // Bottom Interactive Controls
                bottomControlsView
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
        .confirmationDialog("Selesaikan Latihan?", isPresented: $showingFinishConfirmation, titleVisibility: .visible) {
            Button("Simpan Latihan", role: .none) {
                Task {
                    if let result = await viewModel.finishWorkout() {
                        onFinish?(result.0, result.1, result.2, result.3)
                    }
                }
            }
            Button("Batal", role: .cancel) {}
        }
        .confirmationDialog("Buang Latihan Ini?", isPresented: $showingDiscardConfirmation, titleVisibility: .visible) {
            Button("Buang Latihan", role: .destructive) {
                viewModel.discardWorkout()
                onDiscard?()
            }
            Button("Lanjutkan Latihan", role: .cancel) {}
        }
        .sheet(isPresented: $showingPacingTargetSheet) {
            SetPacingTargetSheet(pacingTarget: $viewModel.pacingTarget)
        }
        .overlay {
            if FallDetectionEngine.shared.isCountdownActive {
                EmergencyAlertOverlayView()
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var topHeaderView: some View {
        HStack {
            if viewModel.trackingState == .idle {
                HStack(spacing: 8) {
                    Menu {
                        Picker("Pilih Aktivitas", selection: $viewModel.selectedActivityType) {
                            ForEach(ActivityType.allCases) { type in
                                Label(type.rawValue, systemImage: type.iconName).tag(type)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.selectedActivityType.iconName)
                                .foregroundStyle(StrideTheme.primaryOrange)
                            Text(viewModel.selectedActivityType.rawValue)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                            Image(systemName: "chevron.down")
                                .font(.caption.bold())
                                .foregroundStyle(Color.gray)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    Button {
                        showingPacingTargetSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.caption.bold())
                                .foregroundStyle(viewModel.pacingTarget != nil ? StrideTheme.athleticGreen : Color.gray)
                            if let target = viewModel.pacingTarget {
                                Text(target.formattedTargetPace)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(StrideTheme.athleticGreen)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.selectedActivityType.iconName)
                        .foregroundStyle(StrideTheme.primaryOrange)
                    Text(viewModel.selectedActivityType.rawValue)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
            
            Spacer()
            
            // Live Status Indicator
            if viewModel.trackingState == .autoPaused {
                HStack(spacing: 5) {
                    Circle().fill(Color.yellow).frame(width: 8, height: 8)
                    Text("AUTO-PAUSED")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.yellow)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.15))
                .clipShape(Capsule())
            } else if viewModel.trackingState == .recording {
                HStack(spacing: 5) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("REC")
                        .font(.caption2.bold())
                        .foregroundStyle(Color.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .clipShape(Capsule())
            }
        }
    }
    
    private var liveMapPreview: some View {
        Map {
            if viewModel.routeCoordinates.count >= 2 {
                MapPolyline(coordinates: viewModel.routeCoordinates)
                    .stroke(StrideTheme.primaryOrange, lineWidth: 5)
            }
            if let latest = viewModel.routeCoordinates.last {
                Marker("Posisi", coordinate: latest)
                    .tint(StrideTheme.primaryOrange)
            }
        }
    }
    
    private func metricCard(title: String, value: String, unit: String, icon: String, iconColor: Color = .gray) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2.bold())
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.gray)
                    .tracking(1.0)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.white)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.gray)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(StrideTheme.hudCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    
    private var bottomControlsView: some View {
        HStack(spacing: 20) {
            switch viewModel.trackingState {
            case .idle:
                Button {
                    viewModel.startWorkout()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.title3.bold())
                        Text("START WORKOUT")
                            .font(.system(.title3, design: .rounded, weight: .heavy))
                            .tracking(1.0)
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(StrideTheme.primaryGradient)
                    .clipShape(Capsule())
                    .shadow(color: StrideTheme.primaryOrange.opacity(0.4), radius: 14, y: 6)
                }
                .buttonStyle(.plain)
                
            case .recording:
                Button {
                    viewModel.pauseWorkout()
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.title.bold())
                        .foregroundStyle(Color.white)
                        .frame(width: 76, height: 76)
                        .background(StrideTheme.primaryOrange)
                        .clipShape(Circle())
                        .shadow(color: StrideTheme.primaryOrange.opacity(0.4), radius: 12, y: 4)
                }
                .buttonStyle(.plain)
                
            case .paused, .autoPaused:
                // Discard Button
                Button {
                    showingDiscardConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(Color.white)
                        .frame(width: 58, height: 58)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                // Resume Button
                Button {
                    viewModel.resumeWorkout()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.title.bold())
                        .foregroundStyle(Color.white)
                        .frame(width: 76, height: 76)
                        .background(StrideTheme.primaryOrange)
                        .clipShape(Circle())
                        .shadow(color: StrideTheme.primaryOrange.opacity(0.4), radius: 12, y: 4)
                }
                .buttonStyle(.plain)
                
                // Finish Button
                Button {
                    showingFinishConfirmation = true
                } label: {
                    Image(systemName: "flag.checkered")
                        .font(.title3.bold())
                        .foregroundStyle(Color.white)
                        .frame(width: 58, height: 58)
                        .background(StrideTheme.athleticGreen)
                        .clipShape(Circle())
                        .shadow(color: StrideTheme.athleticGreen.opacity(0.4), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                
            case .finished:
                EmptyView()
            }
        }
    }
}
