import Foundation
import SwiftUI

/// ViewModel managing athlete notifications, unread counts, and interactions.
@Observable
@MainActor
public final class NotificationViewModel {
    public var notifications: [AppNotification] = []
    public var selectedFilter: Int = 0 // 0: All, 1: Unread
    
    public var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    public var filteredNotifications: [AppNotification] {
        if selectedFilter == 1 {
            return notifications.filter { !$0.isRead }
        }
        return notifications
    }
    
    public init(notifications: [AppNotification] = []) {
        if notifications.isEmpty {
            self.notifications = Self.sampleNotifications()
        } else {
            self.notifications = notifications
        }
    }
    
    public func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
    
    public func toggleRead(for notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead.toggle()
        }
    }
    
    public func delete(at indexSet: IndexSet) {
        let itemsToDelete = indexSet.map { filteredNotifications[$0] }
        notifications.removeAll { item in
            itemsToDelete.contains { $0.id == item.id }
        }
    }
    
    public func clearAll() {
        notifications.removeAll()
    }
    
    public static func sampleNotifications() -> [AppNotification] {
        let now = Date()
        return [
            AppNotification(
                type: .kudos,
                title: "Kudos Baru",
                message: "Sarah Jenkins dan 3 orang lainnya memberi Kudos pada 'Morning 10K Tempo Run'.",
                actorName: "Sarah Jenkins",
                timestamp: now.addingTimeInterval(-900), // 15 mins ago
                isRead: false
            ),
            AppNotification(
                type: .comment,
                title: "Komentar Baru",
                message: "David Chen mengomentari: 'Pace gila mantap bro! 🔥'",
                actorName: "David Chen",
                timestamp: now.addingTimeInterval(-3600), // 1 hour ago
                isRead: false
            ),
            AppNotification(
                type: .komLost,
                title: "Rekor KOM Anda Tergeser!",
                message: "Marcus Vance baru saja mencetak rekor 2:45 di segmen 'Monas North Sprint'.",
                actorName: "Marcus Vance",
                timestamp: now.addingTimeInterval(-14400), // 4 hours ago
                isRead: false
            ),
            AppNotification(
                type: .challengeJoined,
                title: "Progres Tantangan",
                message: "Selamat! Anda telah menyelesaikan 64% dari 'Tantangan Lari 100 km'.",
                actorName: "StrideSync Challenges",
                timestamp: now.addingTimeInterval(-86400), // 1 day ago
                isRead: true
            ),
            AppNotification(
                type: .weeklyDigest,
                title: "Ringkasan Mingguan",
                message: "Minggu ini Anda telah berlari sejauh 38.5 km dengan total waktu 2j 54m.",
                actorName: "StrideSync Analytics",
                timestamp: now.addingTimeInterval(-172800), // 2 days ago
                isRead: true
            )
        ]
    }
}

