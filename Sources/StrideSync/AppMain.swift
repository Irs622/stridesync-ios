import SwiftUI
import SwiftData

#if os(iOS)
/// SwiftUI App Entry Point for the iOS application.
@main
public struct StrideSyncApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            StrideSyncRootView()
        }
    }
}
#endif

