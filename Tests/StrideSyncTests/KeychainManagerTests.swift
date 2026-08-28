import Testing
import Foundation
@testable import StrideSync

@Suite("KeychainManager Tests")
struct KeychainManagerTests {
    
    @Test("Test Keychain Save, Get, and Delete")
    func testKeychainOperations() throws {
        let keychain = KeychainManager.shared
        let testKey = "test_auth_token_key"
        let testToken = "mock_auth_token_sample_value"
        
        // Clean initial state
        keychain.delete(key: testKey)
        
        // Save
        let saved = keychain.save(key: testKey, value: testToken)
        #expect(saved == true)
        
        // Read back
        let retrieved = keychain.get(key: testKey)
        #expect(retrieved == testToken)
        
        // Delete
        let deleted = keychain.delete(key: testKey)
        #expect(deleted == true)
        
        // Verify deletion
        let retrievedAfterDelete = keychain.get(key: testKey)
        #expect(retrievedAfterDelete == nil)
    }
}
