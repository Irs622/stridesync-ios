import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif

/// High-impact 9:16 social share card optimized for Instagram Stories and social media exports.
public struct SocialShareCardView: View {
    public let activity: ActivityRecord
    public let coordinates: [CLLocationCoordinate2D]
    
    public init(activity: ActivityRecord, coordinates: [CLLocationCoordinate2D] = []) {
        self.activity = activity
        self.coordinates = coordinates
    }
    
    public var body: some View {
        ZStack {
            // Dark gradient athletic backdrop
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.11, blue: 0.14), Color(red: 0.05, green: 0.05, blue: 0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 24) {
                // Top Brand Tag
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: activity.activityType.iconName)
                            .foregroundStyle(Color.orange)
                        Text("STRIDESYNC")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white)
                            .tracking(3.0)
                    }
                    Spacer()
                    Text(activity.startTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption.bold())
                        .foregroundStyle(Color.gray)
                }
                .padding(.horizontal, 28)
                .padding(.top, 40)
                
                // Map Polyline Visual Window
                if !coordinates.isEmpty {
                    Map {
                        MapPolyline(coordinates: coordinates)
                            .stroke(Color.orange, lineWidth: 5)
                    }
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                }
                
                // Activity Title
                Text(activity.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Hero Metrics Section
                VStack(spacing: 16) {
                    // Distance (Giant)
                    VStack(spacing: 2) {
                        Text(activity.formattedDistance)
                            .font(.system(size: 56, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.white)
                        Text("DISTANCE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orange)
                            .tracking(2.0)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 40)
                    
                    // Pace, Time, Elevation Triad
                    HStack(spacing: 32) {
                        statPill(title: "AVG PACE", value: activity.formattedAveragePace)
                        statPill(title: "TIME", value: activity.formattedMovingTime)
                        statPill(title: "ELEVATION", value: activity.formattedElevationGain)
                    }
                }
                
                Spacer()
                
                // Bottom Footer
                HStack {
                    Text("RECORDED WITH STRIDESYNC FOR IOS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.gray)
                        .tracking(1.5)
                }
                .padding(.bottom, 36)
            }
        }
        .frame(width: 360, height: 640)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: Color.black.opacity(0.5), radius: 20, y: 10)
    }
    
    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.gray)
                .tracking(1.0)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
        }
    }
}

