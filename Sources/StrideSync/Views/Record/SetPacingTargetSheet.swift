import SwiftUI

/// Modal sheet for selecting or customizing a pacing / race target prior to starting a workout.
public struct SetPacingTargetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding public var pacingTarget: PacingTarget?
    
    @State private var selectedDistanceKm: Double = 5.0
    @State private var targetHours: Int = 0
    @State private var targetMinutes: Int = 25
    @State private var targetSeconds: Int = 0
    
    public init(pacingTarget: Binding<PacingTarget?>) {
        self._pacingTarget = pacingTarget
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Presets Grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Target Balapan Populer")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            presetButton(title: "Sub-25m 5K", target: .sub25_5K)
                            presetButton(title: "Sub-20m 5K", target: .sub20_5K)
                            presetButton(title: "Sub-50m 10K", target: .sub50_10K)
                            presetButton(title: "Sub-1j45 HM", target: .sub1h45_HalfMarathon)
                            presetButton(title: "Sub-4j Marathon", target: .sub4h_Marathon)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Divider().padding(.horizontal, 20)
                    
                    // Custom Configuration Form
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Target Kustom")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Jarak Target:")
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(String(format: "%.1f km", selectedDistanceKm))
                                    .font(.subheadline.monospacedDigit().bold())
                                    .foregroundStyle(StrideTheme.primaryOrange)
                            }
                            
                            Slider(value: $selectedDistanceKm, in: 1.0...50.0, step: 0.5)
                                .tint(StrideTheme.primaryOrange)
                        }
                        .padding(14)
                        .background(StrideTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Waktu Selesai:")
                                .font(.subheadline.bold())
                            
                            HStack(spacing: 12) {
                                Picker("Jam", selection: $targetHours) {
                                    ForEach(0...12, id: \.self) { h in
                                        Text("\(h) jam").tag(h)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.primary)
                                
                                Picker("Menit", selection: $targetMinutes) {
                                    ForEach(0...59, id: \.self) { m in
                                        Text("\(m) mnt").tag(m)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.primary)
                                
                                Picker("Detik", selection: $targetSeconds) {
                                    ForEach(0...59, id: \.self) { s in
                                        Text("\(s) dtk").tag(s)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color.primary)
                            }
                            .padding(10)
                            .background(StrideTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        
                        // Calculated target pace indicator
                        let calculatedTarget = calculateCustomTarget()
                        HStack {
                            Text("Target Pace:")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                            Spacer()
                            Text(calculatedTarget.formattedTargetPace)
                                .font(.system(.headline, design: .rounded, weight: .heavy))
                                .foregroundStyle(StrideTheme.athleticGreen)
                        }
                        .padding(14)
                        .background(StrideTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 20)
                    
                    // Buttons
                    VStack(spacing: 10) {
                        Button {
                            pacingTarget = calculateCustomTarget()
                            dismiss()
                        } label: {
                            Text("Terapkan Target Lari")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(StrideTheme.primaryGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        
                        if pacingTarget != nil {
                            Button("Hapus Target (Mode Bebas)") {
                                pacingTarget = nil
                                dismiss()
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.red)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .background(StrideTheme.groupedBackground)
            .navigationTitle("Atur Target Lari")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
    
    private func presetButton(title: String, target: PacingTarget) -> some View {
        Button {
            pacingTarget = target
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text(target.formattedTargetPace)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(StrideTheme.primaryOrange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(StrideTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(StrideTheme.primaryOrange.opacity(pacingTarget == target ? 0.8 : 0.1), lineWidth: pacingTarget == target ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func calculateCustomTarget() -> PacingTarget {
        let totalSeconds = TimeInterval(targetHours * 3600 + targetMinutes * 60 + targetSeconds)
        let safeSeconds = max(60, totalSeconds)
        return PacingTarget(
            targetDistanceMeters: selectedDistanceKm * 1000.0,
            targetDurationSeconds: safeSeconds
        )
    }
}

