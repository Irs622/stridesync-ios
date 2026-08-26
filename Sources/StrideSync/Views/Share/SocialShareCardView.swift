import SwiftUI
import MapKit
#if canImport(_MapKit_SwiftUI)
import _MapKit_SwiftUI
#endif
#if canImport(UIKit)
import UIKit
#endif

/// High-impact 9:16 social share card optimized for Instagram Stories and social media exports.
public struct SocialShareCardView: View {
    public let activity: ActivityRecord
    public let coordinates: [CLLocationCoordinate2D]
    
    @State private var showingSavedAlert: Bool = false
    
    public init(activity: ActivityRecord, coordinates: [CLLocationCoordinate2D] = []) {
        self.activity = activity
        self.coordinates = coordinates
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Rendered 9:16 Story Card
            storyCardView
                .frame(width: 340, height: 600)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.black.opacity(0.4), radius: 18, y: 8)
            
            // Share & Export Actions Bar
            VStack(spacing: 12) {
                #if canImport(UIKit)
                if let renderedImage = renderCardImage() {
                    ShareLink(
                        item: Image(uiImage: renderedImage),
                        preview: SharePreview("StrideSync Story: \(activity.title)", image: Image(uiImage: renderedImage))
                    ) {
                        Label("Bagikan ke Story / Media Sosial", systemImage: "square.and.arrow.up")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: 340)
                            .frame(height: 52)
                            .background(StrideTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: StrideTheme.primaryOrange.opacity(0.35), radius: 8, y: 4)
                    }
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(renderedImage, nil, nil, nil)
                        HapticFeedbackService.shared.playNotification(.success)
                        showingSavedAlert = true
                    } label: {
                        Label("Simpan ke Galeri Foto", systemImage: "arrow.down.to.line.compact")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: 340)
                            .frame(height: 48)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                #endif
            }
        }
        .alert("Gambar Tersimpan! 📸", isPresented: $showingSavedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Kartu Story aktivitas berhasil disimpan ke galeri foto Anda.")
        }
    }
    
    // MARK: - 9:16 Card View
    
    private var storyCardView: some View {
        ZStack {
            // Dark gradient athletic backdrop
            LinearGradient(
                colors: [Color(red: 0.11, green: 0.12, blue: 0.15), Color(red: 0.04, green: 0.04, blue: 0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                // Top Brand Tag
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: activity.activityType.iconName)
                            .foregroundStyle(StrideTheme.primaryOrange)
                        Text("STRIDESYNC")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white)
                            .tracking(2.5)
                    }
                    Spacer()
                    Text(activity.startTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption.bold())
                        .foregroundStyle(Color.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                // Map Polyline Visual Window
                if !coordinates.isEmpty {
                    Map {
                        MapPolyline(coordinates: coordinates)
                            .stroke(StrideTheme.primaryOrange, lineWidth: 5)
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                
                // Activity Title
                Text(activity.title)
                    .font(.system(.title3, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
                
                // Hero Metrics Section
                VStack(spacing: 14) {
                    // Distance (Giant)
                    VStack(spacing: 1) {
                        Text(activity.formattedDistance)
                            .font(.system(size: 52, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.white)
                            .monospacedDigit()
                        Text("DISTANCE")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(StrideTheme.primaryOrange)
                            .tracking(2.0)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.15))
                        .padding(.horizontal, 36)
                    
                    // Pace, Time, Elevation Triad
                    HStack(spacing: 26) {
                        statPill(title: "AVG PACE", value: activity.formattedAveragePace)
                        statPill(title: "TIME", value: activity.formattedMovingTime)
                        statPill(title: "ELEVATION", value: activity.formattedElevationGain)
                    }
                }
                
                Spacer()
                
                // Bottom Footer
                HStack {
                    Text("RECORDED WITH STRIDESYNC FOR IOS")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.gray.opacity(0.8))
                        .tracking(1.5)
                }
                .padding(.bottom, 28)
            }
        }
    }
    
    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.gray)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white)
                .monospacedDigit()
        }
    }
    
    #if canImport(UIKit)
    @MainActor
    private func renderCardImage() -> UIImage? {
        let renderer = ImageRenderer(content: storyCardView.frame(width: 360, height: 640))
        renderer.scale = 3.0 // High-res export
        return renderer.uiImage
    }
    #endif
}

