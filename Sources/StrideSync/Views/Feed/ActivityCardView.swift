import SwiftUI
import MapKit

/// Community social card with iOS native styling, rich typography, and interactive Kudos.
public struct ActivityCardView: View {
    public let activity: ActivityRecord
    public var onKudosTapped: (() -> Void)?
    public var onCommentTapped: (() -> Void)?
    public var onShareTapped: (() -> Void)?
    
    @State private var isKudosAnimating: Bool = false
    
    public init(
        activity: ActivityRecord,
        onKudosTapped: (() -> Void)? = nil,
        onCommentTapped: (() -> Void)? = nil,
        onShareTapped: (() -> Void)? = nil
    ) {
        self.activity = activity
        self.onKudosTapped = onKudosTapped
        self.onCommentTapped = onCommentTapped
        self.onShareTapped = onShareTapped
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Athlete Avatar, Name, Timestamp & Activity Badge
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(StrideTheme.primaryGradient)
                        .frame(width: 46, height: 46)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    
                    // Small sport icon badge on avatar
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                        .overlay {
                            Image(systemName: activity.activityType.iconName)
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(StrideTheme.primaryOrange)
                        }
                        .offset(x: 2, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Budi Santoso")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.blue)
                    }
                    
                    HStack(spacing: 4) {
                        Text(activity.startTime.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                        Text("Jakarta, ID")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Spacer()
                
                // Visibility or Type Pill
                HStack(spacing: 4) {
                    Image(systemName: activity.activityType.iconName)
                        .font(.caption.bold())
                    Text(activity.activityType.rawValue)
                        .font(.caption.bold())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(StrideTheme.primaryOrange.opacity(0.12))
                .foregroundStyle(StrideTheme.primaryOrange)
                .clipShape(Capsule())
            }
            
            // Title & User Notes
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.primary)
                
                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                }
            }
            
            // Key Metrics Card Grid
            HStack(spacing: 0) {
                metricCell(title: "JARAK", value: activity.formattedDistance, isPrimary: true)
                Divider().frame(height: 36).padding(.horizontal, 8)
                metricCell(title: "PACE", value: activity.formattedAveragePace, isPrimary: false)
                Divider().frame(height: 36).padding(.horizontal, 8)
                metricCell(title: "WAKTU", value: activity.formattedMovingTime, isPrimary: false)
                if activity.totalElevationGainMeters > 0 {
                    Divider().frame(height: 36).padding(.horizontal, 8)
                    metricCell(title: "ELEVASI", value: activity.formattedElevationGain, isPrimary: false)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.primary.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // Optional Gear Tag
            if let gear = activity.gearName, !gear.isEmpty {
                HStack(spacing: 5) {
                    Image(systemName: activity.activityType == .run ? "shoe.fill" : "bicycle")
                        .font(.caption2)
                    Text(gear)
                        .font(.caption.bold())
                }
                .foregroundStyle(Color.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            
            Divider()
                .padding(.top, 2)
            
            // Footer: Kudos, Comments, and Share Bar
            HStack(spacing: 24) {
                // Kudos Button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        isKudosAnimating = true
                        onKudosTapped?()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isKudosAnimating = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: activity.isLikedByCurrentUser ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(activity.isLikedByCurrentUser ? StrideTheme.primaryOrange : Color.secondary)
                            .scaleEffect(isKudosAnimating ? 1.3 : 1.0)
                        
                        Text("\(activity.kudosCount)")
                            .font(.subheadline.bold())
                            .foregroundStyle(activity.isLikedByCurrentUser ? StrideTheme.primaryOrange : Color.primary)
                    }
                }
                .buttonStyle(.plain)
                
                // Comment Button
                Button {
                    onCommentTapped?()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        
                        Text("\(activity.commentsCount)")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.primary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Share Button
                Button {
                    onShareTapped?()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(StrideTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
    }
    
    private func metricCell(title: String, value: String, isPrimary: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: isPrimary ? 16 : 14, weight: .heavy, design: .rounded))
                .foregroundStyle(isPrimary ? StrideTheme.primaryOrange : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
