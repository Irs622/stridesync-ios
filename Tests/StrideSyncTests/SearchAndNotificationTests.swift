import Testing
import Foundation
@testable import StrideSync

@Suite("Search and Notification Tests")
struct SearchAndNotificationTests {
    
    @Test("Test Notification ViewModel Unread Count and Mark All Read")
    @MainActor
    func testNotificationViewModel() throws {
        let vm = NotificationViewModel()
        #expect(vm.notifications.count > 0)
        #expect(vm.unreadCount > 0)
        
        vm.markAllAsRead()
        #expect(vm.unreadCount == 0)
        #expect(vm.filteredNotifications.allSatisfy { $0.isRead })
    }
    
    @Test("Test Search ViewModel Filters Athletes, Activities, and Clubs")
    @MainActor
    func testSearchViewModel() throws {
        let vm = SearchViewModel()
        
        // Search athlete
        vm.searchQuery = "Sarah"
        #expect(!vm.filteredAthletes.isEmpty)
        #expect(vm.filteredAthletes.first?.fullName.contains("Sarah") == true)
        
        // Search activity
        vm.searchQuery = "Tempo"
        #expect(!vm.filteredActivities.isEmpty)
        
        // Search segment
        vm.searchQuery = "Monas"
        #expect(!vm.filteredSegments.isEmpty)
        
        // Search club
        vm.searchQuery = "Jakarta"
        #expect(!vm.filteredClubs.isEmpty)
        
        // Test recent searches management
        vm.addRecentSearch("Marathon")
        #expect(vm.recentSearches.first == "Marathon")
        
        vm.removeRecentSearch("Marathon")
        #expect(vm.recentSearches.first != "Marathon")
    }
}

