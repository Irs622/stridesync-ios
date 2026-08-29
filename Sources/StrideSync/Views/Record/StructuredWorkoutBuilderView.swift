import SwiftUI

/// Screen allowing athletes to select interval presets or configure custom structured workout programs.
public struct StructuredWorkoutBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    public var onSelectPlan: ((StructuredWorkoutPlan) -> Void)?
    
    @State private var selectedPlan: StructuredWorkoutPlan?
    @State private var customTitle: String = "Latihan Interval Kustom"
    @State private var customSteps: [WorkoutStep] = [
        WorkoutStep(orderIndex: 0, stepType: .warmup, targetType: .distance, targetValue: 1000),
        WorkoutStep(orderIndex: 1, stepType: .intervalWork, targetType: .distance, targetValue: 400, targetPaceSecondsPerKm: 240),
        WorkoutStep(orderIndex: 2, stepType: .recoveryRest, targetType: .duration, targetValue: 60),
        WorkoutStep(orderIndex: 3, stepType: .cooldown, targetType: .distance, targetValue: 1000)
    ]
    
    public init(onSelectPlan: ((StructuredWorkoutPlan) -> Void)? = nil) {
        self.onSelectPlan = onSelectPlan
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Preset Program Latihan") {
                    ForEach(StructuredWorkoutPlan.standardPresets) { plan in
                        Button {
                            onSelectPlan?(plan)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(plan.title)
                                        .font(.system(.headline, design: .rounded, weight: .bold))
                                        .foregroundStyle(Color.primary)
                                    Spacer()
                                    Text("\(plan.steps.count) Fase")
                                        .font(.caption.bold())
                                        .foregroundStyle(StrideTheme.primaryOrange)
                                }
                                
                                Text(plan.workoutDescription)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                
                                // Step previews
                                HStack(spacing: 4) {
                                    ForEach(plan.steps) { step in
                                        Circle()
                                            .fill(step.stepType == .intervalWork ? StrideTheme.primaryOrange : (step.stepType == .recoveryRest ? StrideTheme.athleticGreen : Color.blue))
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .padding(.top, 2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section("Program Kustom") {
                    TextField("Judul Latihan", text: $customTitle)
                    
                    ForEach(customSteps) { step in
                        HStack {
                            Image(systemName: step.stepType.iconName)
                                .foregroundStyle(step.stepType == .intervalWork ? StrideTheme.primaryOrange : Color.blue)
                            Text(step.stepType.rawValue)
                                .font(.subheadline.bold())
                            Spacer()
                            Text(step.formattedTarget)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    
                    Button {
                        let newPlan = StructuredWorkoutPlan(
                            title: customTitle,
                            workoutDescription: "Latihan kustom dengan \(customSteps.count) langkah",
                            steps: customSteps
                        )
                        onSelectPlan?(newPlan)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Gunakan Latihan Kustom Ini")
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(StrideTheme.primaryOrange)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Program Interval")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}

