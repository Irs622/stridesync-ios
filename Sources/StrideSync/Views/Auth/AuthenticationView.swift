import SwiftUI
import AuthenticationServices

/// Authentication gateway screen presenting Sign in with Apple, Email login, and offline Guest mode.
public struct AuthenticationView: View {
    @State public var authManager: AuthManager = .shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingEmailForm: Bool = false
    
    public init(authManager: AuthManager = .shared) {
        self._authManager = State(initialValue: authManager)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        StrideTheme.primaryOrange.opacity(0.12),
                        StrideTheme.groupedBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 28) {
                    Spacer()
                    
                    // Brand Icon & Hero Title
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(StrideTheme.primaryGradient)
                                .frame(width: 90, height: 90)
                                .shadow(color: StrideTheme.primaryOrange.opacity(0.4), radius: 16, y: 6)
                            
                            Image(systemName: "figure.run")
                                .font(.system(size: 44, weight: .black))
                                .foregroundStyle(Color.white)
                        }
                        
                        Text("StrideSync")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .tracking(0.5)
                        
                        Text("Komunitas Atlet, Rute GPS & Performa Lari")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                    
                    // Auth Actions
                    VStack(spacing: 14) {
                        // Sign in with Apple Button
                        #if os(iOS)
                        Button {
                            // Native trigger or mock Apple login
                            Task {
                                let mockToken = "token_apple_\(UUID().uuidString)"
                                KeychainManager.shared.save(key: "com.stridesync.auth.token", value: mockToken)
                                let profile = CloudUserProfile(
                                    email: "apple.user@stridesync.app",
                                    username: "apple_runner",
                                    fullName: "Atlet Apple"
                                )
                                authManager.restoreSession()
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "apple.logo")
                                    .font(.title3)
                                Text("Masuk dengan Apple")
                                    .font(.headline.bold())
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.primary)
                            .foregroundStyle(StrideTheme.groupedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 3)
                        }
                        #endif
                        
                        // Email Login Option
                        if showingEmailForm {
                            VStack(spacing: 12) {
                                TextField("Email", text: $email)
                                    #if os(iOS)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                    .autocorrectionDisabled()
                                    .padding(14)
                                    .background(StrideTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                
                                SecureField("Kata Sandi", text: $password)
                                    .padding(14)
                                    .background(StrideTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                
                                Button {
                                    Task {
                                        let success = await authManager.loginWithEmail(email: email, password: password)
                                        if success {
                                            dismiss()
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if authManager.isLoading {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Text("Masuk dengan Email")
                                                .font(.headline.bold())
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(StrideTheme.primaryOrange)
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    showingEmailForm = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text("Lanjutkan dengan Email")
                                        .font(.headline.bold())
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(StrideTheme.cardBackground)
                                .foregroundStyle(Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                }
                            }
                        }
                        
                        // Guest Mode Button
                        Button {
                            authManager.continueAsGuest()
                            dismiss()
                        } label: {
                            Text("Gunakan Mode Tamu (Offline)")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
    }
}
