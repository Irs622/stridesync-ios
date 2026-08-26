import SwiftUI

/// Notification Center screen displaying social interactions, Kudos, comments, and KOM updates.
public struct NotificationsView: View {
    @State public var viewModel: NotificationViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: NotificationViewModel = NotificationViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Segmented Control
                Picker("Filter", selection: $viewModel.selectedFilter) {
                    Text("Semua").tag(0)
                    Text("Belum Dibaca (\(viewModel.unreadCount))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                if viewModel.filteredNotifications.isEmpty {
                    emptyNotificationView
                } else {
                    List {
                        ForEach(viewModel.filteredNotifications) { notification in
                            notificationRow(notification: notification)
                                .listRowBackground(notification.isRead ? Color.clear : StrideTheme.primaryOrange.opacity(0.04))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.toggleRead(for: notification)
                                }
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                    .listStyle(.plain)
                }
            }
            .background(StrideTheme.groupedBackground)
            .navigationTitle("Notifikasi")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Tandai Semua") {
                        withAnimation {
                            viewModel.markAllAsRead()
                        }
                    }
                    .disabled(viewModel.unreadCount == 0)
                }
            }
        }
    }
    
    private func notificationRow(notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon Badge
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(notificationIconBackground(for: notification.type))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: notification.type.iconName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(notificationIconColor(for: notification.type))
                    }
                
                if !notification.isRead {
                    Circle()
                        .fill(StrideTheme.primaryOrange)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.system(.subheadline, design: .rounded, weight: notification.isRead ? .semibold : .heavy))
                    
                    Spacer()
                    
                    Text(timeAgo(from: notification.timestamp))
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(notification.isRead ? Color.secondary : Color.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var emptyNotificationView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.secondary.opacity(0.4))
            
            Text("Tidak Ada Notifikasi")
                .font(.system(.title3, design: .rounded, weight: .bold))
            
            Text("Anda sudah membaca semua pemberitahuan terbaru.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func notificationIconColor(for type: NotificationType) -> Color {
        switch type {
        case .kudos: return StrideTheme.primaryOrange
        case .comment: return Color.blue
        case .komLost: return Color.yellow
        case .challengeJoined: return StrideTheme.athleticGreen
        case .clubAnnouncement: return Color.purple
        case .weeklyDigest: return Color.indigo
        }
    }
    
    private func notificationIconBackground(for type: NotificationType) -> Color {
        notificationIconColor(for: type).opacity(0.15)
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "Baru saja" }
        if seconds < 3600 { return "\(seconds / 60)m lalu" }
        if seconds < 86400 { return "\(seconds / 3600)j lalu" }
        return "\(seconds / 86400)h lalu"
    }
}

