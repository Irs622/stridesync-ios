import SwiftUI
import SwiftData

/// Root application view for StrideSync with ModelContainer initialization.
public struct StrideSyncRootView: View {
    public let container: ModelContainer
    
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
        MainTabView(modelContext: container.mainContext)
    }
}

