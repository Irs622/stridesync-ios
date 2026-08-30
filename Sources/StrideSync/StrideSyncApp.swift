import SwiftUI
import SwiftData

/// Root application view for StrideSync with ModelContainer initialization and onboarding gateway.
public struct StrideSyncRootView: View {
    public let container: ModelContainer
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    public init() {
        do {
            let schema = Schema([
                ActivityRecord.self,
                Segment.self,
                GearItem.self,
                TelemetryPoint.self,
                DistanceSplit.self
            ])
            self.container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }
    
    public init(container: ModelContainer) {
        self.container = container
    }
    
    public var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(modelContext: container.mainContext)
            } else {
                OnboardingView {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
    }
}
