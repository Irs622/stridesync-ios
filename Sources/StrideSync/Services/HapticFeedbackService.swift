import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Service providing tactical haptic feedback for workout events and user interactions.
public final class HapticFeedbackService: Sendable {
    public static let shared = HapticFeedbackService()
    
    public init() {}
    
    @MainActor
    public func playImpact(_ style: ImpactStyle = .medium) {
        #if os(iOS)
        let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: feedbackStyle = .light
        case .medium: feedbackStyle = .medium
        case .heavy: feedbackStyle = .heavy
        case .rigid: feedbackStyle = .rigid
        case .soft: feedbackStyle = .soft
        }
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    @MainActor
    public func playNotification(_ type: NotificationFeedbackType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        switch type {
        case .success: generator.notificationOccurred(.success)
        case .warning: generator.notificationOccurred(.warning)
        case .error: generator.notificationOccurred(.error)
        }
        #endif
    }
    
    @MainActor
    public func playSelection() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }
    
    public enum ImpactStyle: Sendable {
        case light, medium, heavy, rigid, soft
    }
    
    public enum NotificationFeedbackType: Sendable {
        case success, warning, error
    }
}
