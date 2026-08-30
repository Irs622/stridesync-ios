import SwiftUI
import CoreLocation

/// Modern 3-step interactive onboarding walkthrough for first-time athletes.
public struct OnboardingView: View {
    public var onFinished: () -> Void
    
    @State private var currentStep: Int = 0
    @State private var isLocationGranted: Bool = false
    @State private var isHealthKitGranted: Bool = false
    
    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }
    
    public var body: some View {
        ZStack {
            // Background Theme
            StrideTheme.groupedBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Progress Bar
                HStack(spacing: 8) {
                    ForEach(0..<3) { step in
                        Capsule()
                            .fill(step <= currentStep ? StrideTheme.primaryOrange : Color.secondary.opacity(0.2))
                            .frame(height: 5)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Slide Content
                TabView(selection: $currentStep) {
                    slideView(
                        icon: "location.fill",
                        iconColor: StrideTheme.primaryOrange,
                        badge: "AKURASI GPS TINGGI",
                        title: "Pelacakan Rute & 3D Flyover",
                        description: "Rekam setiap kilometer dengan presisi tinggi, visualisasikan rute dalam animasi 3D satelit, dan jelajahi heatmap seumur hidupmu.",
                        actionTitle: isLocationGranted ? "Izin GPS Aktif ✓" : "Izinkan Akses Lokasi (GPS)",
                        actionIcon: "location.circle.fill",
                        isActionCompleted: isLocationGranted,
                        onAction: {
                            requestLocation()
                        }
                    )
                    .tag(0)
                    
                    slideView(
                        icon: "waveform.path.ecg",
                        iconColor: StrideTheme.athleticGreen,
                        badge: "PANDUAN BIOMETRIK",
                        title: "Pelatih Suara & Apple Health",
                        description: "Dengarkan waktu split kilometer di earphone secara otomatis saat berlari dan pantau zona detak jantung serta waktu pemulihan tubuh.",
                        actionTitle: isHealthKitGranted ? "Apple Health Terhubung ✓" : "Hubungkan Apple Health",
                        actionIcon: "heart.fill",
                        isActionCompleted: isHealthKitGranted,
                        onAction: {
                            requestHealthKit()
                        }
                    )
                    .tag(1)
                    
                    slideView(
                        icon: "trophy.fill",
                        iconColor: Color.yellow,
                        badge: "KOMUNITAS GLOBAL",
                        title: "Tantangan & Radar Teman",
                        description: "Bersaing di segmen tanjakan populer, raih lencana pencapaian bulanan, dan pantau posisi teman lari di Live Buddy Radar.",
                        actionTitle: "Mulai Petualangan Lari 🏃‍♂️",
                        actionIcon: "arrow.right.circle.fill",
                        isActionCompleted: false,
                        onAction: {
                            completeOnboarding()
                        }
                    )
                    .tag(2)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                
                Spacer()
                
                // Bottom Navigation Buttons
                HStack {
                    if currentStep < 2 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Lewati")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.leading, 24)
                    }
                    
                    Spacer()
                    
                    Button {
                        if currentStep < 2 {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                currentStep += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(currentStep == 2 ? "Mulai Sekarang" : "Lanjut")
                                .font(.headline.bold())
                            Image(systemName: "arrow.right")
                                .font(.headline.bold())
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(StrideTheme.primaryOrange)
                        .foregroundStyle(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: StrideTheme.primaryOrange.opacity(0.35), radius: 10, y: 4)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Slide Component
    
    private func slideView(
        icon: String,
        iconColor: Color,
        badge: String,
        title: String,
        description: String,
        actionTitle: String,
        actionIcon: String,
        isActionCompleted: Bool,
        onAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 24) {
            // Icon Hero Badge
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(StrideTheme.cardBackground)
                    .frame(width: 96, height: 96)
                    .shadow(color: iconColor.opacity(0.2), radius: 12, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                Text(badge)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(StrideTheme.primaryOrange)
                    .tracking(1.0)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(StrideTheme.primaryOrange.opacity(0.12))
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
            }
            
            // Primary Permission / Trigger Button
            Button(action: onAction) {
                HStack(spacing: 10) {
                    Image(systemName: actionIcon)
                        .font(.headline)
                    Text(actionTitle)
                        .font(.headline.bold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(isActionCompleted ? StrideTheme.athleticGreen.opacity(0.15) : StrideTheme.cardBackground)
                .foregroundStyle(isActionCompleted ? StrideTheme.athleticGreen : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isActionCompleted ? StrideTheme.athleticGreen : Color.secondary.opacity(0.25), lineWidth: 1.5)
                }
                .padding(.horizontal, 28)
            }
            .disabled(isActionCompleted)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Handlers
    
    private func requestLocation() {
        LiveLocationManager().requestAuthorization()
        withAnimation {
            isLocationGranted = true
        }
    }
    
    private func requestHealthKit() {
        Task {
            _ = await HealthKitManager.shared.requestAuthorization()
            await MainActor.run {
                withAnimation {
                    isHealthKitGranted = true
                }
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onFinished()
    }
}

