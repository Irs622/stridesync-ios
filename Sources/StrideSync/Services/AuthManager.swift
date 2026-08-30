import Foundation
import SwiftUI
import AuthenticationServices

public enum AuthState: Equatable, Sendable {
    case unauthenticated
    case authenticating
    case authenticated(CloudUserProfile)
    case guestMode
}

/// Centralized authentication coordinator managing Sign in with Apple, Email login, Keychain sessions, and guest accounts.
@Observable
@MainActor
public final class AuthManager: NSObject, Sendable {
    public static let shared = AuthManager()
    
    public private(set) var authState: AuthState = .unauthenticated
    public private(set) var currentUser: CloudUserProfile? = nil
    public var errorMessage: String? = nil
    public var isLoading: Bool = false
    
    private let keychainTokenKey = "com.stridesync.auth.token"
    private let keychainRefreshTokenKey = "com.stridesync.auth.refresh_token"
    private let userProfileDefaultsKey = "com.stridesync.auth.user_profile"
    
    public override init() {
        super.init()
        restoreSession()
    }
    
    // MARK: - Session Restoration
    
    public func restoreSession() {
        guard let token = KeychainManager.shared.getAuthToken(), !token.isEmpty else {
            self.authState = .unauthenticated
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: userProfileDefaultsKey),
           let profile = try? JSONDecoder().decode(CloudUserProfile.self, from: data) {
            self.currentUser = profile
            self.authState = .authenticated(profile)
        } else {
            // Default active session fallback
            let fallbackProfile = CloudUserProfile(
                email: "athlete@stridesync.app",
                username: "athlete",
                fullName: "Atlet StrideSync"
            )
            self.currentUser = fallbackProfile
            self.authState = .authenticated(fallbackProfile)
        }
    }
    
    // MARK: - Sign In with Apple Handler
    
    public func handleAppleAuthorization(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                self.errorMessage = "Kredensial Apple ID tidak valid"
                self.isLoading = false
                return
            }
            
            let userIdentifier = appleIDCredential.user
            _ = appleIDCredential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            _ = appleIDCredential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            
            var fullNameString = "Atlet Apple"
            if let fullName = appleIDCredential.fullName {
                let given = fullName.givenName ?? ""
                let family = fullName.familyName ?? ""
                let combined = "\(given) \(family)".trimmingCharacters(in: .whitespaces)
                if !combined.isEmpty {
                    fullNameString = combined
                }
            }
            
            let emailString = appleIDCredential.email ?? "\(userIdentifier.prefix(8))@privaterelay.appleid.com"
            
            // Persist to Keychain & Local State
            let mockToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.apple_\(UUID().uuidString)"
            KeychainManager.shared.save(key: keychainTokenKey, value: mockToken)
            
            let profile = CloudUserProfile(
                email: emailString,
                username: fullNameString.lowercased().replacingOccurrences(of: " ", with: "_"),
                fullName: fullNameString
            )
            
            saveProfileLocally(profile)
            self.currentUser = profile
            self.authState = .authenticated(profile)
            self.isLoading = false
            
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    // MARK: - Email / Password Login
    
    public func loginWithEmail(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Email dan password wajib diisi"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulates network latency
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        let token = "token_\(UUID().uuidString)"
        KeychainManager.shared.save(key: keychainTokenKey, value: token)
        
        let username = email.components(separatedBy: "@").first ?? "athlete"
        let profile = CloudUserProfile(
            email: email,
            username: username,
            fullName: username.capitalized
        )
        
        saveProfileLocally(profile)
        self.currentUser = profile
        self.authState = .authenticated(profile)
        self.isLoading = false
        return true
    }
    
    // MARK: - Guest Mode (Offline)
    
    public func continueAsGuest() {
        self.authState = .guestMode
    }
    
    // MARK: - Sign Out
    
    public func signOut() {
        KeychainManager.shared.delete(key: keychainTokenKey)
        KeychainManager.shared.delete(key: keychainRefreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userProfileDefaultsKey)
        self.currentUser = nil
        self.authState = .unauthenticated
    }
    
    private func saveProfileLocally(_ profile: CloudUserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userProfileDefaultsKey)
        }
    }
}

