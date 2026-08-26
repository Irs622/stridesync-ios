import SwiftUI

/// Design System & Styling constants for StrideSync following iOS Human Interface Guidelines.
public enum StrideTheme {
    // Brand Colors
    public static let primaryOrange = Color(red: 252/255, green: 82/255, blue: 0/255) // Strava athletic orange #FC5200
    public static let accentOrange = Color(red: 255/255, green: 110/255, blue: 39/255)
    public static let athleticGreen = Color(red: 46/255, green: 204/255, blue: 113/255)
    public static let hudDark = Color(red: 14/255, green: 16/255, blue: 20/255)
    public static let hudCard = Color(red: 24/255, green: 27/255, blue: 34/255)
    
    // Gradients
    public static let primaryGradient = LinearGradient(
        colors: [primaryOrange, accentOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let hudGradient = LinearGradient(
        colors: [Color(red: 20/255, green: 23/255, blue: 29/255), Color(red: 11/255, green: 13/255, blue: 17/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Universal Card Background
    public static var cardBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .secondarySystemBackground)
        #else
        return Color.secondary.opacity(0.12)
        #endif
    }
    
    public static var groupedBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .systemGroupedBackground)
        #else
        return Color.secondary.opacity(0.06)
        #endif
    }
}

